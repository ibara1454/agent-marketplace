# hello-world

A sample template plugin for [juns-agent-marketplace](../../README.md). Use it as a starting point for building your own Claude Code plugins.

## Skills

| Skill | Description |
|-------|-------------|
| `/greet [name]` | Greet the user with a friendly hello message |

## Installation

Add the marketplace to Claude Code, then install this plugin:

```sh
/plugin marketplace add ibara1454/juns-agent-marketplace
/plugin install hello-world@juns-agent-marketplace
```

## Usage

Once installed, invoke the `/greet` skill:

```
/greet
```
> Hello, World! Welcome to juns-agent-marketplace.

```
/greet Alice
```
> Hello, Alice! Welcome to juns-agent-marketplace.

## Structure

```
hello-world/
├── .claude-plugin/
│   └── plugin.json     # Plugin manifest
├── skills/
│   └── greet/
│       └── SKILL.md    # /greet skill definition
└── README.md           # This file
```

## Using as a Template

To create your own plugin based on this template:

1. Copy this directory to `plugins/<your-plugin-name>/`
2. Update `.claude-plugin/plugin.json` with your plugin's details
3. Replace or add skills under `skills/`
4. Register your plugin in the root `.claude-plugin/marketplace.json`
5. Submit a pull request — see [CONTRIBUTING.md](../../CONTRIBUTING.md)
