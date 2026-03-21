#!/bin/bash
# Upload one or more images to GitHub
# Usage: upload-image.sh <repo_id> <agent_browser_session> <file_path> [file_path...]
# Returns JSON array with the upload results for each file.

set -e

if [ $# -lt 3 ]; then
  echo '{"error": "Usage: upload-image.sh <repo_id> <agent_browser_session> <file_path> [file_path...]"}' >&2
  exit 1
fi

REPO_ID="$1"
AB_SESSION="$2"
shift 2

# Extract cookies from agent-browser session
COOKIE_OUTPUT=$(agent-browser --session "$AB_SESSION" cookies 2>/dev/null)

USER_SESSION=$(echo "$COOKIE_OUTPUT" | grep '^user_session=' | head -1 | cut -d= -f2-)
DEVICE_ID=$(echo "$COOKIE_OUTPUT" | grep '^_device_id=' | head -1 | cut -d= -f2-)

if [ -z "$USER_SESSION" ]; then
  echo '{"error": "Could not extract user_session cookie. Ensure you are logged in to GitHub."}' >&2
  exit 1
fi

USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# Function to upload a single file
upload_single_file() {
  local FILE_PATH="$1"

  if [ ! -f "$FILE_PATH" ]; then
    jq -n --arg err "File not found: $FILE_PATH" --arg file "$FILE_PATH" '{error: $err, file: $file}'
    return
  fi

  # Auto-detect file metadata
  local FILENAME=$(basename "$FILE_PATH")
  local FILE_SIZE=$(stat -f%z "$FILE_PATH" 2>/dev/null || stat -c%s "$FILE_PATH")
  local MIME_TYPE=$(file --mime-type -b "$FILE_PATH")

  # Validate mime type
  case "$MIME_TYPE" in
    image/png|image/jpeg|image/gif|image/webp)
      ;;
    *)
      jq -n --arg err "Unsupported file type: $MIME_TYPE" --arg file "$FILE_PATH" '{error: $err, file: $file}'
      return
      ;;
  esac

  # Step 1: Get upload policy
  local POLICY_RESPONSE=$(curl -s -X POST "https://github.com/upload/policies/assets" \
    -H "User-Agent: $USER_AGENT" \
    -H "X-Requested-With: XMLHttpRequest" \
    -H "Github-Verified-Fetch: true" \
    -H "Origin: https://github.com" \
    -H "Accept: application/json" \
    -H "Cookie: user_session=${USER_SESSION}; __Host-user_session_same_site=${USER_SESSION}; _device_id=${DEVICE_ID}" \
    -F "repository_id=${REPO_ID}" \
    -F "name=${FILENAME}" \
    -F "size=${FILE_SIZE}" \
    -F "content_type=${MIME_TYPE}")

  # Check for error in policy response
  if echo "$POLICY_RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
    echo "$POLICY_RESPONSE" | jq --arg file "$FILE_PATH" '{error: .error, file: $file}'
    return
  fi

  # Validate policy response has required fields
  if ! echo "$POLICY_RESPONSE" | jq -e '.upload_url and .form and .asset_upload_url' > /dev/null 2>&1; then
    jq -n --arg file "$FILE_PATH" '{error: "Invalid response from GitHub upload policy API", file: $file}'
    return
  fi

  # Extract fields from policy
  local UPLOAD_URL=$(echo "$POLICY_RESPONSE" | jq -r '.upload_url')
  local FORM_KEY=$(echo "$POLICY_RESPONSE" | jq -r '.form.key')
  local FORM_ACL=$(echo "$POLICY_RESPONSE" | jq -r '.form.acl')
  local FORM_POLICY=$(echo "$POLICY_RESPONSE" | jq -r '.form.policy')
  local FORM_ALGORITHM=$(echo "$POLICY_RESPONSE" | jq -r '.form["X-Amz-Algorithm"]')
  local FORM_CREDENTIAL=$(echo "$POLICY_RESPONSE" | jq -r '.form["X-Amz-Credential"]')
  local FORM_DATE=$(echo "$POLICY_RESPONSE" | jq -r '.form["X-Amz-Date"]')
  local FORM_SIGNATURE=$(echo "$POLICY_RESPONSE" | jq -r '.form["X-Amz-Signature"]')
  local FORM_CONTENT_TYPE=$(echo "$POLICY_RESPONSE" | jq -r '.form["Content-Type"]')
  local FORM_CACHE_CONTROL=$(echo "$POLICY_RESPONSE" | jq -r '.form["Cache-Control"]')
  local FORM_SURROGATE=$(echo "$POLICY_RESPONSE" | jq -r '.form["x-amz-meta-Surrogate-Control"]')
  local ASSET_UPLOAD_URL=$(echo "$POLICY_RESPONSE" | jq -r '.asset_upload_url')
  local AUTHENTICITY_TOKEN=$(echo "$POLICY_RESPONSE" | jq -r '.asset_upload_authenticity_token')

  # Step 2: Upload to S3
  local HTTP_CODE=$(curl -s -X POST "$UPLOAD_URL" \
    -F "key=${FORM_KEY}" \
    -F "acl=${FORM_ACL}" \
    -F "policy=${FORM_POLICY}" \
    -F "X-Amz-Algorithm=${FORM_ALGORITHM}" \
    -F "X-Amz-Credential=${FORM_CREDENTIAL}" \
    -F "X-Amz-Date=${FORM_DATE}" \
    -F "X-Amz-Signature=${FORM_SIGNATURE}" \
    -F "Content-Type=${FORM_CONTENT_TYPE}" \
    -F "Cache-Control=${FORM_CACHE_CONTROL}" \
    -F "x-amz-meta-Surrogate-Control=${FORM_SURROGATE}" \
    -F "file=@${FILE_PATH}" \
    -w "%{http_code}" -o /dev/null)

  if [ "$HTTP_CODE" != "204" ]; then
    jq -n --arg err "S3 upload failed with HTTP $HTTP_CODE" --arg file "$FILE_PATH" '{error: $err, file: $file}'
    return
  fi

  # Step 3: Finalize upload
  local FINAL_RESPONSE=$(curl -s -X PUT "https://github.com${ASSET_UPLOAD_URL}" \
    -H "User-Agent: $USER_AGENT" \
    -H "X-Requested-With: XMLHttpRequest" \
    -H "Github-Verified-Fetch: true" \
    -H "Origin: https://github.com" \
    -H "Accept: application/json" \
    -H "Cookie: user_session=${USER_SESSION}; __Host-user_session_same_site=${USER_SESSION}; _device_id=${DEVICE_ID}" \
    -F "authenticity_token=${AUTHENTICITY_TOKEN}")

  # Validate final response has href
  if ! echo "$FINAL_RESPONSE" | jq -e '.href' > /dev/null 2>&1; then
    jq -n --arg file "$FILE_PATH" '{error: "Finalization failed", file: $file}'
    return
  fi

  # Add original file path to response
  echo "$FINAL_RESPONSE" | jq --arg file "$FILE_PATH" '. + {file: $file}'
}

# Process all files and collect results
RESULTS="["
FIRST=true

for FILE_PATH in "$@"; do
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    RESULTS="${RESULTS},"
  fi
  RESULT=$(upload_single_file "$FILE_PATH")
  RESULTS="${RESULTS}${RESULT}"
done

RESULTS="${RESULTS}]"

echo "$RESULTS"
