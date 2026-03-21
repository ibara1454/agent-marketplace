#!/bin/bash
# Gets repository URL and ID from current git directory
# Usage: get-repo-info.sh

set -e

# Get remote URL and convert to HTTPS format
REPO_URL=$(git remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')

if [ -z "$REPO_URL" ]; then
  echo '{"error": "Not a git repository or no origin remote"}' >&2
  exit 1
fi

# Extract owner/repo
OWNER_REPO=$(echo "$REPO_URL" | sed 's|https://github.com/||')

# Get repository ID via GitHub API
REPO_ID=$(gh api "repos/${OWNER_REPO}" --jq '.id' 2>/dev/null)

if [ -z "$REPO_ID" ]; then
  echo "{\"error\": \"Failed to get repository ID for $OWNER_REPO\"}" >&2
  exit 1
fi

# Output JSON
cat <<EOF
{
  "repo_url": "$REPO_URL",
  "owner_repo": "$OWNER_REPO",
  "repo_id": $REPO_ID
}
EOF
