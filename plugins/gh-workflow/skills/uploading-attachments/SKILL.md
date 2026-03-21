---
name: uploading-attachments
description: >-
  Upload one or more image attachments to GitHub PRs without commits. Supports single
  or multiple file paths. Uses browser login for authentication. Triggers on requests like
  "upload this image to the PR," "attach this screenshot to the pull request," "add this
  image to GitHub without committing," "get a CDN URL for this image," "upload assets for
  the PR comment," or any variation of uploading images or attachments to GitHub.
argument-hint: <file-path> [file-path...]
agent: general-purpose
model: haiku
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/skills/uploading-attachments/scripts/*) Bash(gh:*) Bash(agent-browser:*open*) Bash(agent-browser:*close*) Bash(agent-browser:*snapshot*) Read
---

# Uploading Attachments

**IMPORTANT:** The workflow described below is the only way to upload attachments to GitHub. Do not explore or attempt any alternative approaches.

Upload the image(s) at `$ARGUMENTS` to GitHub's asset CDN and return markdown-ready URLs.

**Heads up:** This uses an undocumented GitHub API — uploaded images **cannot be deleted** from GitHub's CDN. The user should be aware of this before uploading sensitive screenshots.

## Repository Context

!`${CLAUDE_PLUGIN_ROOT}/skills/uploading-attachments/scripts/get-repo-info.sh`

## Input Validation

Before starting the workflow, verify preconditions:

- **No arguments provided:** If `$ARGUMENTS` is empty, stop and tell the user: "Please provide one or more image file paths to upload."
- **agent-browser not installed:** Run `agent-browser --version`. If it fails, tell the user: "agent-browser is not installed. Install it with `npm install -g agent-browser`."
- **gh not authenticated:** If `gh auth status` fails, stop and tell the user: "GitHub CLI is not authenticated. Run `gh auth login` first."

Do not proceed with the workflow if any validation fails.

## Workflow

Copy this checklist and track progress:

```
- [ ] Step 1: Authenticate via browser
- [ ] Step 2: Upload image(s)
- [ ] Step 3: Return results
```

### 1. Authenticate via Browser

First, clean up any stale session from a previous failed run:

```bash
agent-browser --session gh-upload close || true
```

Open the repository in the browser using a dedicated session. If a known auth method is available for GitHub (e.g., `--profile`, `--state`), include it:

```bash
agent-browser --session gh-upload [auth flags] open "$REPO_URL"
```

Where `$REPO_URL` is the `repo_url` from the repository context above.

Take a snapshot to check login status:

```bash
agent-browser --session gh-upload snapshot -i
```

Check the snapshot for login indicators:
- "Sign in" link visible → user NOT logged in
- User avatar/profile menu visible → user IS logged in

If user is not logged in:

1. Close the headless session:
   ```bash
   agent-browser --session gh-upload close
   ```
2. Open in headed mode with `--profile` so the login persists for future runs. GitHub uses OAuth, so `--profile` is required — `--state` and `--session-name` only capture cookies for the current origin, not third-party OAuth providers:
   ```bash
   agent-browser --session gh-upload --headed --profile <profile_path> open https://github.com/login
   ```
3. Ask the user: "Please log in to GitHub in the browser window. Let me know when you're done."
4. Wait for user confirmation
5. Take a snapshot to verify login succeeded:
   ```bash
   agent-browser --session gh-upload snapshot -i
   ```
6. Close the headed session to save the profile:
   ```bash
   agent-browser --session gh-upload close
   ```
7. Reopen headless with the now-authenticated profile:
   ```bash
   agent-browser --session gh-upload --profile <profile_path> open "$REPO_URL"
   ```

### 2. Upload Image(s)

Call the upload script with the session name — it extracts cookies internally:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/uploading-attachments/scripts/upload-image.sh \
  "$REPO_ID" "gh-upload" $ARGUMENTS
```

Use `repo_id` from the repository context above.

This script handles all upload steps for each file:
- Extracts session cookies from agent-browser automatically
- Validates file exists and checks mime type (png, jpeg, gif, webp)
- Gets upload policy from GitHub
- Uploads file to S3
- Finalizes upload

Returns a JSON array with results for each file.

Then close the browser session:

```bash
agent-browser --session gh-upload close
```

### 3. Return Results

Parse the JSON array response and output for each successful upload:

```
Upload successful!

| File | URL |
|------|-----|
| image1.png | https://github.com/user-attachments/assets/xxx |
| image2.png | https://github.com/user-attachments/assets/yyy |

Markdown:
![image1](https://github.com/user-attachments/assets/xxx)
![image2](https://github.com/user-attachments/assets/yyy)
```

## Error Handling

| Error | Resolution |
|-------|------------|
| File not found | Verify file path |
| Unsupported file type | Use PNG, JPEG, GIF, or WebP |
| Cookie extraction failed | Ensure login completed, then retry |
| Upload / finalization failed | Session may have expired — re-run the skill to re-authenticate |
