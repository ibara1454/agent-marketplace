---
name: drafting-pr
description: Creates a draft pull request from current working changes. Handles branching, committing, pushing, and opening the PR with the project's PR template. Triggers on requests like "create a draft PR," "open a draft pull request," "push my changes and open a PR," "ship this as a PR," "submit a draft for review," "PR this," or any variation of branching and opening a draft PR against main.
allowed-tools: Bash(git checkout:*) Bash(git add:*) Bash(git commit:*) Bash(git push:*) Bash(gh pr create:*) Bash(gh auth:*) Bash(git rev-parse:*) Bash(git fetch:*) Bash(git ls-remote:*) Bash(cat:*) Bash(xargs:*) Bash(git diff:*) Bash(git log:*) Read Grep Glob LSP Task AskUserQuestion
---

# Draft PR

Creates a draft pull request from current working changes: analyzes changes, explores the codebase if needed, asks clarifying questions, then creates a branch (if on main), stages and commits, pushes, and opens a draft PR following the project's PR template.

## Repository Context

### Current Branch
!`git branch --show-current`

### Git Status
```
!`git status`
```

### Git Diff
```diff
!`git diff HEAD`
```

### Recent Commits
```
!`git log --oneline -5`
```

### PR Template
!`git rev-parse --show-toplevel | xargs -I {} cat {}/.github/PULL_REQUEST_TEMPLATE.md 2>/dev/null || echo "No PR template found"`

## Input Validation

Before starting, verify:

- **No changes to commit:** If `git status` shows a clean working tree, stop and tell the user: "No changes detected. Stage or modify files before creating a PR."
- **gh not authenticated:** If `gh auth status` fails, stop and tell the user: "GitHub CLI is not authenticated. Run `gh auth login` first."

Do not proceed if any validation fails.

## Workflow

Track progress through these phases:

```
- [ ] Phase 1: Codebase Exploration (if needed)
- [ ] Phase 2: Clarifying Questions
- [ ] Phase 3: Create branch
- [ ] Phase 4: Stage and commit
- [ ] Phase 5: Push to remote
- [ ] Phase 6: Create draft PR
```

### Phase 1: Codebase Exploration (conditional)

The goal here is to catch things the developer may have overlooked — missing related changes, broken consumers, inconsistencies — so these can be surfaced before the PR is created rather than discovered during review.

**Skip** when the diff is small and self-contained: a single file change, a documentation update, a config tweak, or changes isolated to one module with no exported API changes.

**Run** when any of these apply:
- Changes touch 3+ files across different directories
- Modified code is exported, shared, or part of a public API
- The diff includes renaming, moving, or deleting symbols that other code may reference
- Interface changes (function signatures, type definitions, props) that downstream code depends on

When running:
- Use `Read`, `Grep`, `Glob`, `LSP` to check for downstream consumers, missing updates, and consistency with existing patterns
- Optionally launch exploration via `Task` for deeper analysis across multiple areas in parallel
- Note any concerns found — these will be shared with the user in Phase 2

### Phase 2: Clarifying Questions

Use `AskUserQuestion` to present a single consolidated prompt. Lead with your understanding of the changes, then ask only what you genuinely need answered:

1. **Summary:** Briefly describe what changed, the scope, and the type of change (feature, fix, refactor, etc.). Ask the user to confirm or correct.
2. **References:** Ask if there are references to include in the PR (Jira tickets, related PRs, issue numbers, design doc links).
3. **Concerns** (only if Phase 1 found issues): Surface specific findings for the user's input.
4. **Preferences** (only if ambiguous): Branch name, commit message, or PR title — skip this if the changes clearly suggest a name and message.

Keep the question concise. Don't ask about things you can reasonably infer from the diff. Wait for the response before proceeding.

### Phase 3: Create Branch

If currently on `main` or `master`:
- Create a descriptive branch name based on the changes (e.g., `fix/issue-description` or `feat/feature-name`)
- Use the user's preferred branch name from Phase 2 if provided
- Run `git checkout -b <branch-name>`

If already on a feature branch, skip to Phase 4. The branch name will be validated for remote conflicts in Phase 5.

### Phase 4: Stage and Commit

- Stage relevant files with `git add` (avoid staging sensitive or untracked files like `.env`, credentials, local config)
- Create a commit with a descriptive message following conventional commits format (fix:, feat:, chore:, etc.)
- Use the user's preferred commit message style from Phase 2 if provided
- Include `Co-Authored-By: Claude <noreply@anthropic.com>` in the commit message

### Phase 5: Push to Remote

Before pushing, check if a remote branch with the same name already exists:
```bash
git ls-remote --heads origin `git branch --show-current`
```

If a remote branch with the same name exists, create a new branch from the current one before pushing:
- Append a numeric suffix (e.g., `feat/feature-name-2`, then `-3`, etc.) until the name is unique on the remote
- Run `git checkout -b <new-unique-branch-name>`

Then push with upstream tracking:
```bash
git push -u origin `git branch --show-current`
```

If the push fails, report the error and stop.

### Phase 6: Create Draft PR

Create the draft pull request:
```bash
gh pr create --draft --title "<title>" --body "<body>"
```

**Title:** Concise and descriptive, based on the changes. Use the user's preferred title from Phase 2 if provided.

**Body:**
- If the user provided references in Phase 2, include a **References** section at the top of the body (Jira tickets, related PRs, issue numbers, design doc links)
- Use the PR Template from Repository Context above, filling in each section based on the Git Diff
- If no template exists, use a standard format with: References, What (summary with bullet points), Scope of Impact (checkboxes), and How to Test
- Ensure all markdown checkboxes are properly formatted (`- [ ]`)
- Check appropriate Scope of Impact boxes based on files changed

If `gh pr create` fails with "already exists," output the existing PR URL and stop. For other errors, report the raw error message.

After success, output the PR URL to the user.
