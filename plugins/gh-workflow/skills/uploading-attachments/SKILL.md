---
name: uploading-attachments
description: >-
  Attach local images or videos to GitHub issues, pull requests, or comments with
  GitHub CLI --attach, without committing media. Use when asked to attach a
  screenshot, upload PR evidence, add a video to an issue, or get an attachment URL.
compatibility: GitHub CLI v2.99.0+, GitHub.com or GitHub Enterprise Cloud, and push access to the target repository.
argument-hint: <issue-or-pr-url> <file-path> [file-path...]
agent: general-purpose
model: haiku
---

# Uploading attachments

Use first-party `gh --attach` with existing CLI authentication. Read the [official attachment guide](https://gh.io/gh-attach) and the chosen command's `--help` when needed.

## 1. Resolve the target and validate

Read the target repository's instructions and PR-description requirements. Identify the repository, issue or PR, files, and requested operation: create, edit the body, or add a comment. If the target or operation is missing, ask rather than inferring a new publication from file paths alone.

Check `gh --version` (v2.99.0 or later), `gh auth status`, and push access to the target repository. If the CLI is missing or old, ask the user to install or upgrade it; if authentication is missing, ask them to run `gh auth login`. If push access is missing or the host is unsupported, stop and report the limitation. Use CLI authentication rather than browser login, cookie extraction, or the retired upload scripts.

Verify each file exists, is a supported image or video, and is safe to share. Inspect the media for secrets, personal data, private filenames, or unrelated browser content. Keep artifacts outside tracked source. GitHub CLI validates supported types and sizes; at most 50 files can be attached per command.

**Done:** the target, operation, files, authentication, and permission are known.

## 2. Prepare and approve the publication

For an existing body, read it first with `gh pr view` or `gh issue view`; preserve unrelated content. Prepare the proposed body or comment outside tracked source. To place an image inline, reference its absolute local path:

```markdown
![The saved state](/tmp/evidence/ready.png)
```

For a video player, put its reference in its own paragraph:

```markdown
![](/tmp/evidence/walkthrough.mp4)
```

Pass the same file with `--attach`. GitHub CLI rewrites the reference to the uploaded asset and keeps the image's Markdown alt text. Unreferenced attachments are appended in flag order. For an appended image, supply alt text after `#`, such as `--attach '/tmp/evidence/ready.png#The saved state'`. Videos do not support alt text.

`--attach` uploads and publishes or edits content together; it does not stage a URL-only upload. For a URL-only request, explain this and ask which publication, if any, the user authorizes. Never create a placeholder issue, PR, or comment just to obtain an asset URL.

Show the target, proposed content, and files. Obtain explicit approval and pass any runtime confirmation gate immediately before the mutation. Permission to log in, push code, or prepare evidence is not publication approval. If approval is declined or unavailable, leave the draft and artifacts local; do not switch tools or APIs to bypass it.

**Done:** the exact publication and files are approved, or work stops locally.

## 3. Attach with the authorized command

Repeat `--attach` for each file. Use `--repo OWNER/REPO` to make the target explicit. For example, after approval:

```bash
gh pr edit <PR> --repo OWNER/REPO --body-file /tmp/pr-body.md \
  --attach /tmp/evidence/ready.png --attach /tmp/evidence/walkthrough.mp4
```

Use only the requested operation:

| Operation | Command |
|-----------|---------|
| Create an issue | `gh issue create --repo OWNER/REPO --title <title> --body-file <body> --attach <file>` |
| Edit an issue body | `gh issue edit <issue> --repo OWNER/REPO --body-file <body> --attach <file>` |
| Comment on an issue | `gh issue comment <issue> --repo OWNER/REPO --body-file <body> --attach <file>` |
| Create a PR | `gh pr create --repo OWNER/REPO --base <base> --head <head> --title <title> --body-file <body> --attach <file>` |
| Edit a PR body | `gh pr edit <PR> --repo OWNER/REPO --body-file <body> --attach <file>` |
| Comment on a PR | `gh pr comment <PR> --repo OWNER/REPO --body-file <body> --attach <file>` |

For an approved append-only edit, omit `--body` and `--body-file`: the existing issue or PR body is retained and attachments are appended. Preserve existing asset URLs rather than uploading unchanged media again.

## 4. Verify and report

A nonzero exit can still mean content was published with some successful attachments. Inspect stdout for the issue, PR, or comment URL and read back the published content before proposing a retry. Never blindly rerun a create or comment command; retry only missing attachments after checking the actual state and obtaining fresh approval.

Read back the published body or comment and verify that each intended attachment is present and renders. Report the publication link and any missing files or rendering checks you could not perform. For a requested asset URL, return only the stable GitHub attachment URL found in the published content, never cookies, credentials, or signed download URLs.

If attachment access is unavailable, show the local artifact paths and ask whether to wait or publish written evidence with an explicit visual-evidence gap. Use another upload route only if the user explicitly chooses it and its authorization requirements are met; never silently fall back to browser automation or public storage.
