# Contributing to agent-marketplace

Thank you for your interest in contributing! This guide explains how to add a new plugin to the marketplace.

## Adding a New Plugin

### 1. Create the plugin directory

Plugins live under `plugins/`. Use **kebab-case** for the directory name:

```
plugins/
└── your-plugin-name/
    ├── .claude-plugin/
    │   └── plugin.json
    ├── skills/
    │   └── <skill-name>/
    │       └── SKILL.md
    └── README.md
```

You can copy the `plugins/hello-world/` directory as a starting point:

```sh
cp -r plugins/hello-world plugins/your-plugin-name
```

### 2. Write the plugin manifest

Edit `plugins/your-plugin-name/.claude-plugin/plugin.json`:

```json
{
  "name": "your-plugin-name",
  "description": "A short description of what your plugin does.",
  "version": "0.1.0",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "license": "MIT"
}
```

### 3. Define your skills

Each skill is a directory under `skills/` containing a `SKILL.md` file. Skills are auto-discovered — no registration in `plugin.json` is needed unless you use a non-default path.

See [`plugins/hello-world/skills/greet/SKILL.md`](./plugins/hello-world/skills/greet/SKILL.md) for a complete example, and the [official skills reference](https://code.claude.com/docs/en/skills) for full frontmatter options.

### 4. Register in both marketplace registries

This repository maintains two registry files for compatibility with different clients.

**Claude Code** — add an entry to `.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    {
      "name": "your-plugin-name",
      "source": "your-plugin-name",
      "description": "A short description of your plugin.",
      "version": "0.1.0"
    }
  ]
}
```

The `source` field is resolved relative to `pluginRoot` (`./plugins`).

**GitHub Copilot CLI** — add an entry to `.github/plugin/marketplace.json`:

```json
{
  "plugins": [
    {
      "name": "your-plugin-name",
      "source": "plugins/your-plugin-name",
      "description": "A short description of your plugin.",
      "version": "0.1.0",
      "skills": [
        "./skills/your-skill-name"
      ]
    }
  ]
}
```

The `source` field is the full path from the repo root, and `skills` lists each skill directory relative to the plugin source.

### 5. Add a README

Write a `plugins/your-plugin-name/README.md` that covers:

- What the plugin does
- Installation instructions
- Available skills and their usage
- Directory structure

### 6. Validate your plugin

Run the Claude Code plugin validator, pointing it at your plugin directory:

```sh
claude plugin validate ./plugins/your-plugin-name
```

Fix any reported errors before submitting.

### 7. Submit a pull request

Open a pull request against `main` with a clear description of what your plugin does and why it's useful.

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Plugin directory | kebab-case | `my-cool-plugin` |
| Skill name | kebab-case | `my-skill` |
| Plugin version | semver | `1.0.0` |

## Resources

Official Claude Code documentation:

- [Create plugins](https://code.claude.com/docs/en/plugins) — plugin authoring guide and walkthrough
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference) — complete `plugin.json` schema, component path fields, and CLI commands
- [Skills](https://code.claude.com/docs/en/skills) — `SKILL.md` frontmatter options and skill development details
- [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) — `marketplace.json` schema and distribution guide
- [github/copilot-plugins](https://github.com/github/copilot-plugins) — official GitHub Copilot plugins repository (reference for `.github/plugin/marketplace.json` format)

## Code of Conduct

Be respectful and constructive. Plugins should be useful, well-documented, and not harmful.
