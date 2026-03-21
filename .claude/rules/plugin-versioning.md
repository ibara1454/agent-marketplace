---
paths:
  - "plugins/**"
---

# Plugin Versioning

When adding or modifying skills, hooks, agents, or other plugin components, always bump the `version` in the plugin's `.claude-plugin/plugin.json`.

Use semver:
- **Minor** bump for new features (e.g., adding a new skill)
- **Patch** bump for bug fixes or minor updates to existing components
