---
name: commenting-on-prs
description: >-
  Posts inline review comments on GitHub pull request diffs using the GitHub reviews API.
  Handles requests to add code review comments, inline feedback, line-level annotations,
  or inline notes to specific lines of a pull request diff. Applicable when a user wants
  to comment on code changes, annotate a diff, leave review feedback on a PR, post a pull
  request review, or add line comments to changed files. Accepts file path, line number,
  and comment body for each comment; batches multiple comments into a single review API call.
allowed-tools: Bash(gh pr view:*) Bash(gh pr diff:*) Bash(gh api:*)
model: haiku
agent: general-purpose
---

# Commenting on PRs

Post inline review comments on GitHub PR diffs using the reviews API.

## PR Context

### Current PR
```
!`gh pr view --json number,headRefOid,url 2>&1 || echo "ERROR: No open PR for current branch"`
```

### Diff
```diff
!`gh pr diff 2>&1 || echo "No diff available"`
```

## Input validation

If no input arguments are provided (no comments specified), return an error message to the caller:
> "Error: arguments required. Provide the desired comments — each with file path, line number, and comment body."

Do not proceed with the workflow.

## Workflow

### 1. Verify PR exists

If the PR Context above shows `ERROR`, stop and inform the user.

### 2. Post review comments

Use the reviews endpoint (NOT the single-comment endpoint):

```bash
gh api \
  --method POST \
  "repos/{owner}/{repo}/pulls/{number}/reviews" \
  --input - <<'EOF'
{
  "commit_id": "<full 40-char SHA from headRefOid>",
  "event": "COMMENT",
  "comments": [
    {
      "path": "path/to/file.ts",
      "line": 42,
      "side": "RIGHT",
      "body": "Your comment here (supports GitHub Flavored Markdown)."
    }
  ]
}
EOF
```

Use `{owner}` and `{repo}` from the PR URL. Batch multiple comments into the `comments` array — one review with N comments is preferred over N separate API calls.

If the API returns 422, re-examine the diff for the correct `line`/`path` values and retry once. If it fails again, report the raw error to the user and stop.

### 3. Confirm success

A successful response returns HTTP 200. Output the `html_url` from the response.

## Determining `path`, `line`, and `side`

From the diff in PR Context:
- **`path`**: The file path from the diff header (`diff --git a/... b/...`). Use the `b/` path without the `b/` prefix.
- **`line`**: Absolute line number in the file. Must be within a changed hunk visible in the diff.
- **`side`**: `"RIGHT"` for added/modified lines (`+` prefix in diff). `"LEFT"` for deleted lines (`-` prefix).

## Why the reviews endpoint

| Endpoint | Line field | Behavior |
|----------|-----------|----------|
| `POST .../pulls/{pr}/comments` | `position` (diff hunk offset) | Hard to compute; `line`/`side` fields are **rejected** with HTTP 422 |
| `POST .../pulls/{pr}/reviews` | `line` (absolute file line number) | Intuitive; supports `side` for left/right |

**Always use the reviews endpoint.**

## Examples

See [examples.md](examples.md) for real API call transcripts.

## Important notes

- `commit_id` must be the **full 40-character SHA** from `headRefOid`. Short SHAs return 422.
- `line` must be within a changed hunk in the diff. Lines outside the diff return 422.
- `path` must exactly match the diff header. Invalid paths return 422.
- Use `event: "COMMENT"` only. Do not use `"REQUEST_CHANGES"` or `"APPROVE"` unless the user explicitly asks.