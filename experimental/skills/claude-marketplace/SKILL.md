---
description: Reference the latest Anthropic documentation when editing a Claude marketplace repo
disable-model-invocation: true
---

You are editing a Claude marketplace repository. Before making any changes, you MUST consult the latest official Anthropic plugin marketplace documentation:

**https://code.claude.com/docs/en/plugin-marketplaces**

## Required Steps

1. **Fetch the documentation** using the WebFetch tool at the URL above to get the latest standards, schemas, and best practices
2. **Follow the marketplace schema** exactly as defined in the documentation for `marketplace.json`, `plugin.json`, and skill files
3. **Validate your changes** against the documented specifications before committing

## Key References

- **Marketplace file**: `.claude-plugin/marketplace.json` must follow the documented schema (required fields: `name`, `owner`, `plugins`)
- **Plugin manifest**: `.claude-plugin/plugin.json` in each plugin directory (required fields: `name`, `description`, `version`)
- **Skills**: `skills/<skill-name>/SKILL.md` with YAML frontmatter (`description` required)
- **Plugin sources**: Use relative paths, GitHub repos, or git URLs as documented
- **Naming**: Use kebab-case for all identifiers (marketplace names, plugin names, skill directories)

## Conventions

- `experimental/` contains plugins under active development
- `stable/` contains production-ready, fully tested plugins
- Always check https://code.claude.com/docs/en/plugins and https://code.claude.com/docs/en/plugins-reference for the full plugin authoring and reference docs

Do NOT rely on cached or outdated knowledge of the marketplace format. Always fetch the live documentation to ensure compliance with the latest spec.
