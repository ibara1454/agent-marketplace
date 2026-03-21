---
name: writing-skills
description: >-
  Provides authoritative guidance for creating, reviewing, and improving Claude Code skills
  (SKILL.md files). Covers naming conventions, description best practices, progressive disclosure,
  frontmatter fields, allowed-tools syntax, and common skill patterns. Triggers on requests like
  "write a skill," "create a SKILL.md," "improve this skill," "fix my skill description,"
  "how to write a skill," "skill best practices," "skill frontmatter help," "review my skill,"
  or any variation of authoring, editing, or troubleshooting Claude Code skills.
user-invocable: false
---

# Writing Skills Reference

Quick reference for authoring high-quality skills. For full details, see the reference files below.

## Key Principles

1. **Concise is key** — only add context Claude doesn't already have. Challenge each paragraph: does it justify its token cost?
2. **Description is critical** — written in third person, includes what the skill does AND when to trigger it. Include synonym phrases for discovery.
3. **Progressive disclosure** — keep SKILL.md under 500 lines. Move detailed reference material to separate files.
4. **Match freedom to fragility** — use exact scripts for fragile operations, text instructions for context-dependent tasks.
5. **One level of references** — all reference files should link directly from SKILL.md, not nested references.

## Skill Name Convention

Use **gerund form** (verb + -ing): `drafting-pr`, `processing-pdfs`, `analyzing-spreadsheets`.
Name field: lowercase letters, numbers, hyphens only. Max 64 characters. No reserved words (anthropic, claude).

## Description Checklist

- Written in third person ("Processes files..." not "Use this to process files")
- Includes what the skill does
- Includes when to use it (trigger phrases, synonyms, natural language variants)
- Max 1024 characters, no XML tags

## Frontmatter Quick Reference

| Field | Purpose |
|-------|---------|
| `name` | Skill name (lowercase, hyphens, max 64 chars) |
| `description` | What it does + when to trigger (max 1024 chars) |
| `allowed-tools` | Tools Claude can use without permission prompts |
| `disable-model-invocation` | `true` = only user can invoke via `/name` |
| `user-invocable` | `false` = hidden from `/` menu, Claude-only |
| `context` | `fork` to run in isolated subagent |
| `agent` | Subagent type when `context: fork` is set |
| `argument-hint` | Autocomplete hint, e.g. `[issue-number]` |

## Structural Patterns

- **Input validation** — verify preconditions before workflow with quoted error messages
- **Progress checklist** — copy-paste checklist for multi-step workflows
- **Inline error recovery** — handle errors within the step that can fail
- **Dynamic context** — use `!`command`` to inject live data (git status, PR info, etc.)
- **Template pattern** — provide output format templates for consistent results
- **Examples pattern** — input/output pairs for style-sensitive output

## Full References

- **Best practices (authoring guide):** See [references/best-practices.md](references/best-practices.md)
- **Claude Code skills (features & config):** See [references/claude-code-skills.md](references/claude-code-skills.md)

