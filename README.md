# Jared Henry's Plugin Marketplace

A personal Claude Code plugin marketplace with three plugins: **experimental** (dev tools), **secret-squirrel** (security skills), and **stable** (production-ready).

## Structure

```
claude-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace manifest
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
│   ├── .gitignore                # Prevents committing decrypted skill plaintext
│   ├── hooks/
│   │   └── hooks.json            # SessionStart/End hooks for auto-decrypt/lock
│   ├── scripts/
│   │   └── zero-trust.sh         # Crypto operations (unlock/lock/status)
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
│       ├── yubikey-setup/
│       │   └── SKILL.md          # Skill: YubiKey registration wizard
│       └── zero-trust/
│           └── SKILL.md          # Skill: YubiKey-encrypted skill trees
└── stable/
    └── .claude-plugin/
        └── plugin.json           # Stable plugin manifest (no skills yet)
```

- **`/experimental`** - Plugins under active development (v0.6.0)
- **`/secret-squirrel`** - Security skills: scanning, OPSEC, threat modeling, supply chain, repo hygiene, dotfiles audit, YubiKey setup, zero-trust encryption (v0.3.0)
- **`/stable`** - Production-ready, fully tested plugins (v0.1.0, no skills yet)

## Plugins

| Plugin | Version | Description | Contents |
|--------|---------|-------------|----------|
| experimental | 0.6.0 | Plugins in development or testing phase | **Skills:** `bootstrap-test` - Test bootstrap scripts in Docker for correctness and idempotency, `claude-marketplace` - References latest Anthropic docs when editing marketplace repos, `diagnose` - Diagnose Claude Code problems with root cause analysis, `mcp-configuration` - Configure MCP servers using official + provider docs |
| secret-squirrel | 0.3.0 | Security skills — spy-themed security practices | **Skills:** `dotfiles-doctor` - Audit dotfiles for broken symlinks, permission issues, and config gotchas, `opsec-review` - Review code/configs for operational security issues, `repo-hygiene` - Audit git history for leaked secrets, unsigned commits, and large blobs, `secrets-scanner` - Scan repos for leaked credentials and sensitive data, `supply-chain-audit` - Audit scripts for unpinned downloads and unverified signatures, `threat-model` - STRIDE threat modeling walkthrough, `yubikey-setup` - YubiKey registration wizard for SSH auth and git signing, `zero-trust` - Encrypt skill trees using YubiKey HMAC-SHA1 + age. **Hooks:** SessionStart auto-decrypt, SessionEnd auto-lock |
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
