# Claude Marketplace Repository

## Instructions for Claude AI

When editing this repository, **always reference the latest Anthropic documentation** for plugin marketplaces before making changes:

- **Plugin Marketplaces:** https://code.claude.com/docs/en/plugin-marketplaces
- **Plugin Authoring:** https://code.claude.com/docs/en/plugins
- **Plugin Reference:** https://code.claude.com/docs/en/plugins-reference

Fetch the live documentation using `WebFetch` before making structural changes. Do not rely on cached or outdated knowledge of the marketplace format.

## Repository Overview

This is **jared-henry-personal**, a Claude Code plugin marketplace owned by Jared Henry. It hosts Claude plugins organized into two maturity tiers: **experimental** (in development) and **stable** (production-ready).

The marketplace is configuration-driven with no runtime code. It uses JSON manifests and Markdown skill files following the Anthropic plugin marketplace specification.

## Directory Structure

```
claude-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # Root marketplace manifest
├── .gitignore
├── CLAUDE.md                     # This file - AI assistant instructions
├── README.md                     # Project introduction
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

## Key Files

### Marketplace Manifest (`.claude-plugin/marketplace.json`)

The root marketplace configuration. Required fields: `name`, `owner`, `plugins`.

- **name**: `jared-henry-personal` (kebab-case identifier users see when installing)
- **owner**: `Jared Henry`
- **plugins**: References `./experimental` and `./stable` via relative paths

### Plugin Manifests (`<plugin>/.claude-plugin/plugin.json`)

Each plugin directory contains a manifest with required fields: `name`, `description`, `version`.

- **experimental**: v0.3.0 - plugins under active development
- **stable**: v0.1.0 - production-ready plugins (currently empty, no skills yet)

### Skill Files (`skills/<skill-name>/SKILL.md`)

Skills are defined as Markdown files with YAML frontmatter. Required frontmatter field: `description`.

Current skills:
- `experimental/skills/claude-marketplace/SKILL.md` - References Anthropic docs when editing marketplace repos
- `experimental/skills/diagnose/SKILL.md` - Diagnose Claude Code problems with root cause analysis, support ticket, and team message
- `experimental/skills/mcp-configuration/SKILL.md` - Configure MCP servers using official Anthropic and provider documentation

## Architecture

```
marketplace (jared-henry-personal)
├── plugin: experimental (v0.3.0)
│   ├── skill: claude-marketplace
│   ├── skill: diagnose
│   └── skill: mcp-configuration
└── plugin: stable (v0.1.0)
    └── (no skills yet)
```

The hierarchy is: **Marketplace** -> **Plugins** -> **Skills/Hooks/Agents/MCP Servers**

Plugins are referenced from `marketplace.json` via relative `source` paths. Each plugin is self-contained in its own directory with its own `.claude-plugin/plugin.json` manifest.

## Naming Conventions

- **Marketplace name**: kebab-case (e.g., `jared-henry-personal`)
- **Plugin names**: kebab-case, lowercase (e.g., `experimental`, `stable`)
- **Skill directories**: kebab-case (e.g., `claude-marketplace`)
- **Versioning**: Semantic versioning (e.g., `0.1.0`, `1.0.0`)

## Development Workflow

### Adding a New Skill

1. Choose the target plugin (`experimental/` for development, `stable/` for production-ready)
2. Create the skill directory: `<plugin>/skills/<skill-name>/`
3. Create `SKILL.md` with YAML frontmatter:
   ```markdown
   ---
   description: Brief description of what the skill does
   disable-model-invocation: true
   ---

   Skill instructions here.
   ```
4. Update the plugin's `plugin.json` version if appropriate
5. Validate with `claude plugin validate .` or `/plugin validate .`

### Adding a New Plugin

1. Create the plugin directory at the repository root (e.g., `my-plugin/`)
2. Create `.claude-plugin/plugin.json` inside it:
   ```json
   {
     "name": "my-plugin",
     "description": "What this plugin does",
     "version": "1.0.0"
   }
   ```
3. Add a plugin entry to `.claude-plugin/marketplace.json` under `plugins`:
   ```json
   {
     "name": "my-plugin",
     "source": "./my-plugin",
     "description": "What this plugin does"
   }
   ```
4. Add skills, hooks, agents, or MCP servers inside the plugin directory
5. Validate the marketplace

### Promoting a Skill from Experimental to Stable

1. Move the skill directory from `experimental/skills/<name>/` to `stable/skills/<name>/`
2. Update version numbers in both plugin manifests
3. Validate the marketplace

### Validation

Always validate before committing structural changes:

```bash
claude plugin validate .
```

Or from within Claude Code:
```
/plugin validate .
```

## Plugin Capabilities

Plugins can contain any combination of:

- **Skills** (`skills/<name>/SKILL.md`) - Slash commands users can invoke
- **Hooks** - Shell commands triggered by Claude Code events (e.g., `PostToolUse`)
- **Agents** - Custom agent definitions
- **MCP Servers** - Model Context Protocol server configurations
- **LSP Servers** - Language Server Protocol configurations

Use `${CLAUDE_PLUGIN_ROOT}` in hooks and server configs to reference files within the plugin's installed directory.

## Guidelines for AI Assistants

1. **Fetch live documentation** before making structural changes to marketplace or plugin manifests
2. **Follow the marketplace schema** exactly as defined in the Anthropic documentation
3. **Maintain the experimental/stable distinction** - do not mix maturity levels
4. **Use kebab-case** for all identifiers (marketplace names, plugin names, skill directories)
5. **Keep plugins self-contained** - do not reference files outside a plugin's directory with `../` paths (plugins are copied to a cache on install, so external references break)
6. **Validate changes** before committing using `claude plugin validate .`
7. **Preserve existing structure** - do not reorganize without explicit request
8. **Bump versions** when making meaningful changes to plugin contents

## No Build System

This repository has no build tools, package managers, test frameworks, or CI/CD pipelines. It is purely configuration and documentation. Changes are validated via the Claude plugin validation command.
