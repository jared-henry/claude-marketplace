# Claude Marketplace Repository

## Instructions for Claude AI

**Before editing any file in this repository**, invoke the `/claude-marketplace` skill (from the `experimental` plugin). This skill ensures you fetch and follow the latest Anthropic plugin marketplace documentation before making changes.

Key documentation references (fetched by the skill):

- **Plugin Marketplaces:** https://code.claude.com/docs/en/plugin-marketplaces
- **Plugin Authoring:** https://code.claude.com/docs/en/plugins
- **Plugin Reference:** https://code.claude.com/docs/en/plugins-reference

Do not rely on cached or outdated knowledge of the marketplace format.

## Repository Overview

This is **jared-henry-personal**, a Claude Code plugin marketplace owned by Jared Henry. It hosts three plugins: **experimental** (dev tools), **secret-squirrel** (security skills), and **stable** (production-ready).

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
│       ├── bootstrap-test/
│       │   └── SKILL.md          # Skill: Docker bootstrap testing
│       ├── claude-marketplace/
│       │   └── SKILL.md          # Skill: documentation reference
│       ├── diagnose/
│       │   └── SKILL.md          # Skill: Claude Code diagnostics
│       └── mcp-configuration/
│           └── SKILL.md          # Skill: MCP server configuration
├── secret-squirrel/
│   ├── .claude-plugin/
│   │   └── plugin.json           # Secret Squirrel plugin manifest
│   └── skills/
│       ├── dotfiles-doctor/
│       │   └── SKILL.md          # Skill: dotfiles setup audit
│       ├── opsec-review/
│       │   └── SKILL.md          # Skill: operational security review
│       ├── repo-hygiene/
│       │   └── SKILL.md          # Skill: git history hygiene audit
│       ├── secrets-scanner/
│       │   └── SKILL.md          # Skill: secrets detection
│       ├── supply-chain-audit/
│       │   └── SKILL.md          # Skill: supply chain security audit
│       ├── threat-model/
│       │   └── SKILL.md          # Skill: STRIDE threat modeling
│       └── yubikey-setup/
│           └── SKILL.md          # Skill: YubiKey registration wizard
└── stable/
    └── .claude-plugin/
        └── plugin.json           # Stable plugin manifest (no skills yet)
```

## Key Files

### Marketplace Manifest (`.claude-plugin/marketplace.json`)

The root marketplace configuration.

**Required fields:** `name`, `owner`, `plugins`

- **name**: `jared-henry-personal` (kebab-case identifier users see when installing, e.g., `/plugin install my-tool@jared-henry-personal`)
- **owner**: Object with required `name` field and optional `email` field (e.g., `{ "name": "Jared Henry" }`)
- **plugins**: Array of plugin entries, each requiring `name` and `source` fields

**Optional metadata fields:** `metadata.description`, `metadata.version`, `metadata.pluginRoot`

- **metadata.description**: `"Jared Henry's personal Claude marketplace"` - brief marketplace description
- **metadata.version**: Marketplace version string
- **metadata.pluginRoot**: Base directory prepended to relative plugin source paths (e.g., `"./plugins"` lets you write `"source": "formatter"` instead of `"source": "./plugins/formatter"`)

**Reserved names:** The following marketplace names are reserved for official Anthropic use: `claude-code-marketplace`, `claude-code-plugins`, `claude-plugins-official`, `anthropic-marketplace`, `anthropic-plugins`, `agent-skills`, `life-sciences`. Names that impersonate official marketplaces are also blocked.

### Plugin Entries in `marketplace.json`

Each entry in the `plugins` array describes a plugin and where to find it.

**Required fields:** `name`, `source`

- **name**: Plugin identifier (kebab-case, no spaces). Users see this when installing (e.g., `/plugin install experimental@jared-henry-personal`).
- **source**: Where to fetch the plugin from. Can be a relative path string (e.g., `"./experimental"`), a GitHub object (`{ "source": "github", "repo": "owner/repo" }`), or a git URL object (`{ "source": "url", "url": "https://..." }`).

**Optional fields:** `description`, `version`, `author`, `homepage`, `repository`, `license`, `keywords`, `category`, `tags`, `strict`, and component configuration fields (`commands`, `agents`, `hooks`, `mcpServers`, `lspServers`)

- **strict**: When `true` (default), marketplace component fields merge with `plugin.json`. When `false`, the marketplace entry defines the plugin entirely and `plugin.json` must not also declare components.

### Plugin Manifests (`<plugin>/.claude-plugin/plugin.json`)

Each plugin directory contains a manifest. The manifest is optional — if omitted, Claude Code auto-discovers components in default locations and derives the plugin name from the directory name.

**Required field (if manifest is present):** `name`

**Optional metadata fields:** `description`, `version`, `author`, `homepage`, `repository`, `license`, `keywords`

**Optional component path fields:** `commands`, `agents`, `skills`, `hooks`, `mcpServers`, `outputStyles`, `lspServers`

Current plugins:
- **experimental**: v0.6.0 - plugins under active development
- **secret-squirrel**: v0.2.0 - security skills (secrets scanning, OPSEC review, threat modeling, YubiKey setup, supply chain audit, repo hygiene, dotfiles doctor)
- **stable**: v0.1.0 - production-ready plugins (currently empty, no skills yet)

### Skill Files (`skills/<skill-name>/SKILL.md`)

Skills are agent-invokable extensions defined as Markdown files with YAML frontmatter. Claude automatically uses skills based on task context.

**Required frontmatter field:** `description`

**Optional frontmatter fields:** `disable-model-invocation`, `argument-hint`, `allowed-tools`

Current skills:
- `experimental/skills/bootstrap-test/SKILL.md` - Test bootstrap/install scripts in Docker for correctness and idempotency
- `experimental/skills/claude-marketplace/SKILL.md` - References Anthropic docs when editing marketplace repos
- `experimental/skills/diagnose/SKILL.md` - Diagnose Claude Code problems with root cause analysis, support ticket, and team message
- `experimental/skills/mcp-configuration/SKILL.md` - Configure MCP servers using official Anthropic and provider documentation
- `secret-squirrel/skills/dotfiles-doctor/SKILL.md` - Audit dotfiles for broken symlinks, permission issues, config gotchas, and information leakage
- `secret-squirrel/skills/opsec-review/SKILL.md` - Review code/configs for operational security issues
- `secret-squirrel/skills/repo-hygiene/SKILL.md` - Audit git history for leaked secrets, unsigned commits, stale branches, and large blobs
- `secret-squirrel/skills/secrets-scanner/SKILL.md` - Scan repos for leaked credentials, API keys, tokens, and sensitive data
- `secret-squirrel/skills/supply-chain-audit/SKILL.md` - Audit shell scripts and CI/CD pipelines for unpinned downloads and unverified signatures
- `secret-squirrel/skills/threat-model/SKILL.md` - STRIDE threat modeling walkthrough for systems and features
- `secret-squirrel/skills/yubikey-setup/SKILL.md` - Walk through registering a new YubiKey for SSH auth and git commit signing

## Architecture

```
marketplace (jared-henry-personal)
├── plugin: experimental (v0.6.0)
│   ├── skill: bootstrap-test
│   ├── skill: claude-marketplace
│   ├── skill: diagnose
│   └── skill: mcp-configuration
├── plugin: secret-squirrel (v0.2.0)
│   ├── skill: dotfiles-doctor
│   ├── skill: opsec-review
│   ├── skill: repo-hygiene
│   ├── skill: secrets-scanner
│   ├── skill: supply-chain-audit
│   ├── skill: threat-model
│   └── skill: yubikey-setup
└── plugin: stable (v0.1.0)
    └── (no skills yet)
```

The hierarchy is: **Marketplace** -> **Plugins** -> **Skills/Commands/Hooks/Agents/MCP Servers/LSP Servers**

Plugins are referenced from `marketplace.json` via relative `source` paths. Each plugin is self-contained in its own directory with its own `.claude-plugin/plugin.json` manifest. When users install a plugin, Claude Code copies the plugin directory to a cache location — plugins cannot reference files outside their directory using `../` paths.

## Naming Conventions

- **Marketplace name**: kebab-case (e.g., `jared-henry-personal`)
- **Plugin names**: kebab-case, lowercase (e.g., `experimental`, `stable`)
- **Skill directories**: kebab-case (e.g., `claude-marketplace`)
- **Versioning**: Semantic versioning `MAJOR.MINOR.PATCH` (e.g., `0.1.0`, `1.0.0`)

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

### Adding a New Command (User-Invocable Slash Command)

1. Choose the target plugin
2. Create the commands directory if it doesn't exist: `<plugin>/commands/`
3. Create a Markdown file: `<plugin>/commands/<command-name>.md`
   ```markdown
   ---
   description: Brief description of what the command does
   ---

   Command instructions here. Use $ARGUMENTS for user input.
   ```
4. The command is invoked as `/<plugin-name>:<command-name>`
5. Validate with `claude plugin validate .`

### Adding a New Plugin

1. Create the plugin directory at the repository root (e.g., `my-plugin/`)
2. Create `.claude-plugin/plugin.json` inside it (only `name` is required):
   ```json
   {
     "name": "my-plugin",
     "description": "What this plugin does",
     "version": "1.0.0"
   }
   ```
3. Add a plugin entry to `.claude-plugin/marketplace.json` under `plugins` (`name` and `source` are required):
   ```json
   {
     "name": "my-plugin",
     "source": "./my-plugin",
     "description": "What this plugin does"
   }
   ```
4. Add skills, commands, hooks, agents, MCP servers, or LSP servers inside the plugin directory
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

Plugins can contain any combination of these components. Only `plugin.json` goes inside `.claude-plugin/`. All other directories must be at the plugin root level.

| Component         | Default Location             | Description                                                      |
|-------------------|------------------------------|------------------------------------------------------------------|
| **Skills**        | `skills/<name>/SKILL.md`     | Agent-invocable skills — Claude uses them based on task context   |
| **Commands**      | `commands/<name>.md`         | User-invocable slash commands (`/<plugin>:<command>`)             |
| **Agents**        | `agents/<name>.md`           | Custom subagent definitions                                      |
| **Hooks**         | `hooks/hooks.json`           | Event handlers triggered by Claude Code events                   |
| **MCP Servers**   | `.mcp.json`                  | Model Context Protocol server configurations                     |
| **LSP Servers**   | `.lsp.json`                  | Language Server Protocol configurations for code intelligence    |
| **Output Styles** | `outputStyles/`              | Custom output style files                                        |

### Hooks

Hooks respond to Claude Code events. Three hook types are available: `command` (shell commands), `prompt` (LLM evaluation), and `agent` (agentic verifier with tools).

Available hook events: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `UserPromptSubmit`, `Notification`, `Stop`, `SubagentStart`, `SubagentStop`, `SessionStart`, `SessionEnd`, `TeammateIdle`, `TaskCompleted`, `PreCompact`

### Environment Variable

Use `${CLAUDE_PLUGIN_ROOT}` in hooks, MCP server configs, and scripts to reference files within the plugin's installed directory. This is necessary because plugins are copied to a cache location when installed.

## Guidelines for AI Assistants

1. **Fetch live documentation** before making structural changes to marketplace or plugin manifests
2. **Follow the marketplace schema** exactly as defined in the Anthropic documentation
3. **Maintain the experimental/stable distinction** - do not mix maturity levels
4. **Use kebab-case** for all identifiers (marketplace names, plugin names, skill directories)
5. **Keep plugins self-contained** - do not reference files outside a plugin's directory with `../` paths (plugins are copied to a cache on install, so external references break; use symlinks if shared files are needed)
6. **Validate changes** before committing using `claude plugin validate .`
7. **Preserve existing structure** - do not reorganize without explicit request
8. **Bump versions** when making meaningful changes to plugin contents
9. **Put components at the plugin root** - only `plugin.json` goes inside `.claude-plugin/`; all other directories (`commands/`, `skills/`, `agents/`, `hooks/`) must be at the plugin root level

## No Build System

This repository has no build tools, package managers, test frameworks, or CI/CD pipelines. It is purely configuration and documentation. Changes are validated via the Claude plugin validation command.
