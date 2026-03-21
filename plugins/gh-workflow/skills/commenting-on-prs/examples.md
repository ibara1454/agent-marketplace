# Examples: Real API Transcripts

## Multi-comment review (PR #328)

Two inline comments on `tsconfig.json` files explaining why `esModuleInterop: true` was added.

### Request

```bash
gh api repos/my-org/my-repo/pulls/328/reviews \
  --input - <<EOF
{
  "commit_id": "3f7a2e9c1d8b4f6e0a5c7d9b2e4f6a8c1d3e5f7a",
  "event": "COMMENT",
  "comments": [
    {
      "path": "apps/foo/tsconfig.json",
      "line": 6,
      "side": "RIGHT",
      "body": "Next.js 15 automatically injects `esModuleInterop: true` into `tsconfig.json` when it detects it's missing (during `next build` or `next dev`). This auto-modification reformats the entire file and causes Biome lint failures. Adding it upfront prevents Next.js from touching the file."
    },
    {
      "path": "apps/bar/tsconfig.json",
      "line": 6,
      "side": "RIGHT",
      "body": "Same as above — prevents Next.js 15 from auto-modifying this file."
    }
  ]
}
EOF
```

### Response (key fields)

```json
{
  "id": 3935079512,
  "state": "COMMENTED",
  "html_url": "https://github.com/my-org/my-repo/pull/328#pullrequestreview-3935079512",
  "submitted_at": "2026-03-12T09:24:13Z"
}
```

### Notes

- `commit_id` is the full 40-character SHA of the PR head commit (`headRefOid`)
- Both comments were posted as a single review — one API call, one notification
- Line 6 in both files corresponds to the added `"esModuleInterop": true` line in the diff
- `side: "RIGHT"` because these are added lines (appear with `+` in the diff)
