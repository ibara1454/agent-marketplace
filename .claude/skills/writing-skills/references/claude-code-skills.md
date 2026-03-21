# Claude Code Skills Reference

Source: https://code.claude.com/docs/en/skills

## Contents

- Where skills live (scopes and priority)
- Frontmatter reference (all fields)
- String substitutions
- Supporting files
- Invocation control
- Dynamic context injection
- Subagent execution
- Permission control
- Troubleshooting

## Where Skills Live

| Location | Path | Applies to |
|----------|------|------------|
| Enterprise | Managed settings | All users in organization |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Priority: enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace (no conflicts).

Automatic discovery: Claude Code also looks for skills in nested `.claude/skills/` directories (monorepo support).

## Frontmatter Reference

```yaml
---
name: my-skill           # lowercase, hyphens, max 64 chars
description: What + when  # max 1024 chars, third person
allowed-tools: Read, Grep # tools without permission prompts
disable-model-invocation: true  # only user can invoke
user-invocable: false     # hidden from / menu
context: fork             # run in isolated subagent
agent: Explore            # subagent type (Explore, Plan, general-purpose, or custom)
model: sonnet             # model override
argument-hint: [number]   # autocomplete hint
hooks: ...                # skill-scoped hooks
---
```

## String Substitutions

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed when invoking |
| `$ARGUMENTS[N]` / `$N` | Specific argument by 0-based index |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md |

If `$ARGUMENTS` is not present in content, arguments are appended as `ARGUMENTS: <value>`.

## Supporting Files

```
my-skill/
├── SKILL.md           # Main instructions (required)
├── reference.md       # Detailed docs (loaded when needed)
├── examples.md        # Usage examples (loaded when needed)
└── scripts/
    └── helper.py      # Utility script (executed, not loaded)
```

Reference from SKILL.md so Claude knows what each file contains:
```markdown
- For complete API details, see [reference.md](reference.md)
- For usage examples, see [examples.md](examples.md)
```

## Invocation Control

| Frontmatter | User invokes | Claude invokes | Context loading |
|-------------|-------------|----------------|-----------------|
| (default) | Yes | Yes | Description always loaded, full skill on invoke |
| `disable-model-invocation: true` | Yes | No | Description NOT in context |
| `user-invocable: false` | No | Yes | Description always loaded |

## Dynamic Context Injection

The `!`command`` syntax runs shell commands BEFORE the skill is sent to Claude. Output replaces the placeholder.

```yaml
## Repository context
- Current branch: !`git branch --show-current`
- Status: !`git status --short`
- Recent commits: !`git log --oneline -5`
```

This is preprocessing — Claude only sees the final output.

## Subagent Execution

Add `context: fork` to run in isolation. The skill content becomes the subagent's prompt. No access to conversation history.

```yaml
---
name: deep-research
context: fork
agent: Explore
---
Research $ARGUMENTS thoroughly...
```

Options for `agent`: `Explore`, `Plan`, `general-purpose`, or custom agents from `.claude/agents/`.

## Permission Control

Three ways to restrict skill access:

1. **Deny all skills**: Add `Skill` to deny rules in `/permissions`
2. **Allow/deny specific**: `Skill(commit)` exact match, `Skill(deploy *)` prefix match
3. **Per-skill**: `disable-model-invocation: true` in frontmatter

## allowed-tools Syntax

Restrict tools Claude can use when skill is active:

```yaml
allowed-tools: Read, Grep, Glob                    # specific tools
allowed-tools: Bash(git *)                          # bash with prefix
allowed-tools: Bash(git checkout:*) Bash(git add:*) # specific git subcommands
```

## Troubleshooting

**Skill not triggering:**
- Check description includes natural keywords
- Verify with "What skills are available?"
- Try invoking directly with `/skill-name`

**Skill triggers too often:**
- Make description more specific
- Add `disable-model-invocation: true`

**Too many skills exceed budget:**
- Budget is 2% of context window (fallback 16,000 chars)
- Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var
- Check with `/context` for excluded skills warning
