# gh-workflow

GitHub workflow automation skills for Claude Code.

## Skills

| Skill | Description |
|-------|-------------|
| `drafting-pr` | Creates draft PRs with the project's PR template |
| `commenting-on-prs` | Posts inline review comments on PR diffs |
| `uploading-attachments` | Uploads images to GitHub's CDN for PRs without committing |
| `agent-browser` | Browser automation CLI for AI agents |
| `dogfood` | Exploratory web app testing with structured reports |

## drafting-pr

Creates a draft pull request from current working changes. Handles branching, committing, pushing, and opening the PR following the project's PR template.

**Key behaviors:**
- Proactively explores the codebase for non-trivial changes (3+ files, public API changes) to catch issues before the PR is created
- Consolidates all clarifying questions into a single prompt to minimize back-and-forth
- Uses conventional commit format with `Co-Authored-By: Claude <noreply@anthropic.com>`
- Dynamically reads `.github/PULL_REQUEST_TEMPLATE.md` at runtime
- Detects remote branch name collisions and auto-appends numeric suffixes
- Creates a branch only if currently on main/master

**Triggers:** "create a draft PR", "open a draft pull request", "push my changes and open a PR", "ship this as a PR", "PR this"

## commenting-on-prs

Posts inline review comments on GitHub pull request diffs. Batches multiple comments into a single review API call (one notification instead of N).

**Key behaviors:**
- Uses the Reviews endpoint with intuitive absolute line numbers (not diff hunk positions)
- Supports GitHub Flavored Markdown in comment bodies
- Auto-retries once on HTTP 422 by re-examining the diff for correct line/path values
- Defaults to `COMMENT` event (won't `REQUEST_CHANGES` or `APPROVE` unless explicitly asked)

**Triggers:** "add a comment on line 42 of app.tsx", "leave inline feedback on the PR", "post review comments on this diff"

## uploading-attachments

Uploads image attachments to GitHub's asset CDN and returns markdown-ready URLs. Images are uploaded without committing them to the repository.

**Key behaviors:**
- Supports PNG, JPEG, GIF, and WebP formats
- Uses `agent-browser` for browser-based GitHub authentication
- Handles the full 3-step GitHub upload flow (get policy, upload to S3, finalize)
- Returns results as a markdown table with ready-to-paste image syntax
- Uploaded images **cannot be deleted** from GitHub's CDN (undocumented API caveat)

**Usage:** `/uploading-attachments <file-path> [file-path...]`

**Triggers:** "upload this image to the PR", "attach this screenshot to the pull request", "get a CDN URL for this image"

## agent-browser

Browser automation via the [`agent-browser`](https://github.com/vercel-labs/agent-browser) CLI, which uses Chrome/Chromium through CDP.

> Sourced from [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser).

**Key behaviors:**
- Snapshot-based element references (`@e1`, `@e2`) that reduce token usage to 200-400 tokens vs. 3000-5000 for full DOM
- Five authentication methods: auto-connect from user's browser, persistent profiles, session persistence, auth vault, manual state
- Named sessions for isolation and parallel browsing
- Video recording of browser sessions (WebM)
- Iframe content automatically inlined in snapshots
- Supports Chrome and Lightpanda (10x faster, 10x less memory)

**Triggers:** "open a website", "fill out a form", "take a screenshot", "scrape data from a page", "test this web app", "automate browser actions"

## dogfood

Systematically explores and tests a web application to find bugs, UX issues, and other problems. Produces a structured Markdown report with full reproduction evidence for every finding.

> Sourced from [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser).

**Key behaviors:**
- Only the target URL is required; sensible defaults for everything else
- Two evidence tiers: interactive issues get video + step-by-step screenshots; static issues get a single annotated screenshot
- Issues are written to the report immediately as found (nothing lost if interrupted)
- Covers 7 issue categories (Visual/UI, Functional, UX, Content, Performance, Console/Errors, Accessibility) across 4 severity levels
- Targets 5-10 well-documented issues per session (depth over quantity)

**Triggers:** "dogfood vercel.com", "QA this app", "exploratory test", "find issues", "bug hunt", "test this site"

## Requirements

| Dependency | Required by | Install |
|------------|-------------|---------|
| [`gh`](https://cli.github.com/) | drafting-pr, commenting-on-prs, uploading-attachments | `brew install gh` then `gh auth login` |
| [`agent-browser`](https://github.com/vercel-labs/agent-browser) | uploading-attachments, agent-browser, dogfood | `npm i -g agent-browser` then `agent-browser install` |
| `jq` | uploading-attachments | `brew install jq` |
