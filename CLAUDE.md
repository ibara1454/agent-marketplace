# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Claude Code plugin marketplace. Users add it with:

```sh
/plugin marketplace add ibara1454/agent-marketplace
```

The repo has no build system, test runner, or dependencies — all files are JSON and Markdown.

## Validation

```sh
claude plugin validate .
```

## Architecture

All plugins live under `plugins/<plugin-name>/`. The marketplace is registered in **two separate registry files** that must be kept in sync when adding or updating a plugin:

| File | Client |
|------|--------|
| `.claude-plugin/marketplace.json` | Claude Code — uses `pluginRoot: "./plugins"`, so `source` is just the plugin directory name (e.g. `"hello-world"`) |
| `.github/plugin/marketplace.json` | GitHub Copilot CLI — `source` is the full repo-relative path (e.g. `"plugins/hello-world"`), and each plugin entry includes a `skills` array of skill directory paths |

### Plugin structure

```
plugins/<name>/
├── .claude-plugin/
│   └── plugin.json       # name, description, version, author, license
└── skills/
    └── <skill-name>/
        └── SKILL.md      # YAML frontmatter (name, description) + Claude instructions
```

`plugin.json` requires only `name`. Skills under `skills/` are auto-discovered — no explicit registration in `plugin.json` is needed unless skills live outside the default `skills/` directory, in which case add a `skills` field with a path string or array of paths.

### SKILL.md format

```markdown
---
name: skill-name
description: When Claude should invoke this skill and what it does.
---

Instructions for Claude to follow when the skill fires.
```

Supported frontmatter fields: `name`, `description`, `license`, `compatibility`, `disable-model-invocation`, `metadata`, `user-invokable`. The `version` field is **not** supported in SKILL.md (put version in `plugin.json` instead).

## Skill authoring

When asked to create or improve a skill, suggest using the `skill-creator` skill (from the `anthropic-agent-skills` marketplace), which helps produce well-structured, valid SKILL.md files.

## Naming conventions

- Plugin directories and skill names: `kebab-case`
- Versions: semver (`1.0.0`)
- PRs target the `main` branch
