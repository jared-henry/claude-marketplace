# Jared Henry's Plugin Marketplace

A personal Claude Code plugin marketplace with two maturity tiers: **experimental** (in development) and **stable** (production-ready).

## Structure

```
claude-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace manifest
├── experimental/
│   ├── .claude-plugin/
│   │   └── plugin.json           # Experimental plugin manifest
│   └── skills/
│       ├── claude-marketplace/
│       │   └── SKILL.md          # Skill: documentation reference
│       ├── diagnose/
│       │   └── SKILL.md          # Skill: Claude Code diagnostics
│       └── mcp-configuration/
│           └── SKILL.md          # Skill: MCP server configuration
└── stable/
    └── .claude-plugin/
        └── plugin.json           # Stable plugin manifest (no skills yet)
```

- **`/experimental`** - Plugins under active development (v0.3.0)
- **`/stable`** - Production-ready, fully tested plugins (v0.1.0, no skills yet)

## Plugins

| Plugin | Version | Description | Contents |
|--------|---------|-------------|----------|
| experimental | 0.3.0 | Plugins in development or testing phase | **Skills:** `claude-marketplace` - References latest Anthropic docs when editing marketplace repos, `diagnose` - Diagnose Claude Code problems with root cause analysis, `mcp-configuration` - Configure MCP servers using official + provider docs |
| stable | 0.1.0 | Production-ready, fully tested plugins | *(no skills yet)* |

## Installation

Add this marketplace and install plugins via Claude Code:

```shell
/plugin marketplace add jared-henry/claude-marketplace
```

Install an individual plugin:

```shell
/plugin install experimental@jared-henry-personal
```

Or browse available plugins:

```shell
/plugin > Discover
```

## Adding a New Skill

1. Create the skill directory under the target plugin: `<plugin>/skills/<skill-name>/`
2. Add a `SKILL.md` with YAML frontmatter (`description` is required)
3. Bump the plugin version in `<plugin>/.claude-plugin/plugin.json`
4. Validate: `claude plugin validate .` or `/plugin validate .`

## Adding a New Plugin

1. Create a directory at the repo root (e.g., `my-plugin/`)
2. Add `.claude-plugin/plugin.json` with `name`, `description`, and `version`
3. Register the plugin in `.claude-plugin/marketplace.json` under `plugins`
4. Validate: `claude plugin validate .` or `/plugin validate .`

## Documentation

- [Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Plugin Authoring](https://code.claude.com/docs/en/plugins)
- [Plugin Reference](https://code.claude.com/docs/en/plugins-reference)
