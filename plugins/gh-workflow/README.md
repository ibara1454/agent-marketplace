# gh-workflow

GitHub workflow automation skills for Claude Code.

## Skills

| Skill | Description |
|-------|-------------|
| `drafting-pr` | Creates draft PRs with the project's PR template |
| `commenting-on-prs` | Posts inline review comments on PR diffs |
| `uploading-attachments` | Attaches images and videos to issues, PRs, and comments with `gh --attach` |
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

Attaches local images and videos to issues, pull requests, or comments using first-party [`gh --attach`](https://gh.io/gh-attach), without committing media.

**Key behaviors:**
- Requires GitHub CLI v2.99.0+, CLI authentication, and push access to the target repository on GitHub.com or GitHub Enterprise Cloud
- Supports all six issue/PR create, edit, and comment commands, with up to 50 attachments per command
- Rewrites local Markdown references in place, preserving image alt text; appends unreferenced files
- Publishes or edits content together with the upload, so the target, content, and files require approval; runtime confirmation gates remain in force
- Checks published state after partial failures before retrying, avoiding duplicate PRs or comments
- Uses no browser login, cookie extraction, or custom upload scripts

**Usage:** `/uploading-attachments <issue-or-pr-url> <file-path> [file-path...]`; specify whether to edit the body or add a comment. For new issues or PRs, provide the target repository and requested create operation.

**Triggers:** "upload this image to the PR", "attach this screenshot to the pull request", "add this video to the issue", "get an attachment URL for this image"

A URL-only request requires clarification: `--attach` is not a standalone staging upload, and the skill will not create placeholder content to obtain a URL.

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
| [`gh`](https://cli.github.com/) | drafting-pr, commenting-on-prs, uploading-attachments (v2.99.0+) | `brew install gh` (or `brew upgrade gh`) then `gh auth login` |
| [`agent-browser`](https://github.com/vercel-labs/agent-browser) | agent-browser, dogfood | `npm i -g agent-browser` then `agent-browser install` |
