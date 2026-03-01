# juns-agent-marketplace

A marketplace of [Claude Code](https://claude.ai/code) plugins and skills, with [GitHub Copilot CLI](https://github.com/github/copilot-plugins) compatibility.

## Quick Start

Add this marketplace to Claude Code:

```sh
/plugin marketplace add ibara1454/juns-agent-marketplace
```

Install a plugin:

```sh
/plugin install hello-world@juns-agent-marketplace
```

Use a skill from the installed plugin:

```
/greet
```

## Available Plugins

| Plugin | Description | Skills |
|--------|-------------|--------|
| [hello-world](./plugins/hello-world/) | Sample template plugin | `/greet` |

## Repository Structure

```
juns-agent-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # Claude Code marketplace registry
├── .github/
│   └── plugin/
│       └── marketplace.json      # GitHub Copilot CLI marketplace registry
├── plugins/
│   └── hello-world/              # Sample plugin (use as template)
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── skills/
│       │   └── greet/
│       │       └── SKILL.md
│       └── README.md
├── .gitignore
├── README.md                     # This file
├── CONTRIBUTING.md
└── LICENSE
```

## Contributing

Want to add your own plugin? See [CONTRIBUTING.md](./CONTRIBUTING.md) for step-by-step instructions.

## License

MIT — see [LICENSE](./LICENSE).
