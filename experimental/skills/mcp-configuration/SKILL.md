---
description: Configure an MCP server for Claude Code by combining Anthropic's official MCP documentation with the MCP provider's own documentation
disable-model-invocation: true
---

You are helping the user configure an MCP (Model Context Protocol) server for use with Claude Code.

## Research Process

Before configuring any MCP server, you MUST perform two research steps:

### Step 1: Fetch the Anthropic MCP documentation

Use WebFetch to retrieve the latest official Anthropic MCP documentation:

**https://code.claude.com/docs/en/mcp**

This documentation covers:
- How to add MCP servers (`claude mcp add`)
- Transport types: HTTP (recommended), SSE (deprecated), and stdio (local processes)
- Scope options: `local` (default, just you in this project), `project` (shared via `.mcp.json`), `user` (all your projects)
- Authentication: OAuth 2.0 flows, pre-configured credentials, PAT-based auth
- JSON configuration via `claude mcp add-json`
- Environment variable expansion in `.mcp.json`
- Plugin-bundled MCP servers using `${CLAUDE_PLUGIN_ROOT}`
- Managing servers: `claude mcp list`, `claude mcp get`, `claude mcp remove`

### Step 2: Fetch the MCP provider's documentation

Use WebFetch and/or WebSearch to find the official documentation for the specific MCP server being configured. Look for:
- The provider's official GitHub repository README
- Installation guides specific to Claude Code
- Authentication requirements (PATs, OAuth, API keys)
- Available tools/capabilities and how to filter them
- Environment variables and configuration options

### Step 3: Synthesize both sources

Combine the Anthropic documentation (how MCP works in Claude Code) with the provider documentation (how this specific MCP works) to produce a correct, complete configuration. Cross-reference:
- The transport type the provider supports vs. what Claude Code supports
- The authentication method the provider requires vs. how Claude Code handles auth
- Any provider-specific flags, domains, or environment variables

## Configuration Command Patterns

Based on the Anthropic documentation, these are the primary patterns:

### Remote HTTP server (recommended for cloud services)
```bash
claude mcp add --transport http <name> <url>

# With authentication header
claude mcp add --transport http <name> <url> \
  --header "Authorization: Bearer <token>"

# With OAuth (authenticate interactively after adding)
claude mcp add --transport http <name> <url>
# Then run /mcp in Claude Code to authenticate
```

### Local stdio server (for locally-run processes)
```bash
claude mcp add --transport stdio <name> -- <command> [args...]

# With environment variables
claude mcp add --transport stdio --env KEY=value <name> -- <command> [args...]
```

### JSON configuration
```bash
claude mcp add-json <name> '<json-config>'
```

### Scope flag (applies to all patterns)
```bash
# local (default): just you, this project
claude mcp add --transport http <name> <url>

# project: shared via .mcp.json, checked into version control
claude mcp add --transport http <name> --scope project <url>

# user: available across all your projects
claude mcp add --transport http <name> --scope user <url>
```

## Worked Examples

The following examples demonstrate the research-then-configure process for two real MCP servers. Use these as templates when configuring other MCPs.

---

### Example 1: GitHub MCP Server

**Research findings from provider documentation:**

The GitHub MCP server is GitHub's official MCP server (https://github.com/github/github-mcp-server). Key findings:
- Remote HTTP endpoint: `https://api.githubcopilot.com/mcp/`
- Supports OAuth (via Claude Code's `/mcp` authentication flow) and PAT-based auth
- Available to all GitHub users; some tools require paid licenses
- The deprecated npm package `@modelcontextprotocol/server-github` should NOT be used
- Toolsets can be filtered: `repos`, `issues`, `pull_requests`, `actions`, `code_security`, `discussions`
- Local alternative via Docker: `ghcr.io/github/github-mcp-server`
- GitHub Enterprise Server requires local setup with `GITHUB_HOST` env var

**Research findings from Anthropic documentation:**

- HTTP transport is the recommended option for remote servers
- OAuth authentication is supported natively via `/mcp` command
- Headers can be passed with `--header` or `-H` for PAT-based auth
- Scope can be set to `user` for cross-project availability

**Synthesized configuration:**

Option A - OAuth (simplest, recommended):
```bash
claude mcp add --transport http github https://api.githubcopilot.com/mcp/
```
Then authenticate in Claude Code:
```
/mcp
# Select "Authenticate" for GitHub
```

Option B - Personal Access Token:
```bash
claude mcp add --transport http github \
  https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer YOUR_GITHUB_PAT"
```

Option C - JSON configuration with PAT:
```bash
claude mcp add-json github '{
  "type": "http",
  "url": "https://api.githubcopilot.com/mcp/",
  "headers": {
    "Authorization": "Bearer YOUR_GITHUB_PAT"
  }
}'
```

Option D - Local Docker server (no remote dependency):
```bash
claude mcp add github \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=YOUR_GITHUB_PAT \
  -- docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN \
  ghcr.io/github/github-mcp-server
```

Option E - User scope (available in all projects):
```bash
claude mcp add -s user --transport http github \
  https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer YOUR_GITHUB_PAT"
```

**Verification:**
```bash
claude mcp list
claude mcp get github
```

---

### Example 2: Azure DevOps MCP Server

**Research findings from provider documentation:**

The Azure DevOps MCP server is Microsoft's official MCP server (https://github.com/microsoft/azure-devops-mcp). Key findings:
- Uses stdio transport via `npx -y @azure-devops/mcp <OrgName>`
- Requires the Azure DevOps organization name as a positional argument
- Authentication: interactive OAuth on first use (browser-based Microsoft login), or PAT via `ADO_MCP_AUTH_TOKEN` env var with `--authentication envvar` flag
- 50+ tools across 9 domains: `core`, `work`, `work-items`, `search`, `test-plans`, `repositories`, `wiki`, `pipelines`, `advanced-security`
- Domain filtering via `-d` flag reduces loaded tools and avoids overwhelming the model
- The `core` domain is recommended for all configurations
- Requires Node.js 20+
- Nightly builds available via `@azure-devops/mcp@next`

**Research findings from Anthropic documentation:**

- stdio transport is the correct choice for locally-run npx processes
- All options (`--transport`, `--env`) must come before the server name
- The `--` separator prevents flag conflicts between Claude Code and the MCP server
- Environment variables can be set with `--env` or `-e`
- Tool Search auto-activates when many MCP tools are loaded (relevant since ADO has 50+ tools)

**Synthesized configuration:**

Option A - Interactive OAuth (simplest):
```bash
claude mcp add azure-devops -- npx -y @azure-devops/mcp YourOrgName
```
On first tool use, a browser window opens for Microsoft account authentication.

Option B - With domain filtering (recommended to avoid tool overload):
```bash
claude mcp add azure-devops -- npx -y @azure-devops/mcp YourOrgName \
  -d core work-items repositories
```

Option C - PAT authentication (for CI/automation):
```bash
claude mcp add --env ADO_MCP_AUTH_TOKEN=YOUR_PAT azure-devops \
  -- npx -y @azure-devops/mcp YourOrgName --authentication envvar
```

Option D - PAT with domain filtering:
```bash
claude mcp add --env ADO_MCP_AUTH_TOKEN=YOUR_PAT azure-devops \
  -- npx -y @azure-devops/mcp YourOrgName \
  --authentication envvar -d core work-items repositories pipelines
```

Option E - JSON configuration:
```bash
claude mcp add-json azure-devops '{
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@azure-devops/mcp", "YourOrgName", "-d", "core", "work-items", "repositories"],
  "env": {}
}'
```

**Verification:**
```bash
claude mcp list
claude mcp get azure-devops
```

---

## Applying This Process to Any MCP Server

When the user asks you to configure an MCP server:

1. **Fetch** `https://code.claude.com/docs/en/mcp` for the latest Anthropic MCP documentation
2. **Search** for the MCP provider's official documentation (check their GitHub repo, official docs site, or npm/PyPI page)
3. **Identify** the transport type (HTTP for remote services, stdio for local processes)
4. **Identify** the authentication method (OAuth, PAT, API key, none)
5. **Construct** the `claude mcp add` command by combining both sources
6. **Recommend** a scope based on the user's needs (local for testing, user for personal cross-project, project for team sharing)
7. **Verify** with `claude mcp list` and `claude mcp get <name>`

## Common Pitfalls

- **Option ordering**: All flags (`--transport`, `--env`, `--scope`, `--header`) must come BEFORE the server name
- **Double dash**: Use `--` to separate Claude Code flags from the MCP server command/args
- **Deprecated transports**: SSE is deprecated; prefer HTTP for remote servers
- **Token security**: Never commit tokens to version control; use environment variables or `.env` files added to `.gitignore`
- **Tool overload**: MCP servers with many tools (like Azure DevOps with 50+) can consume context. Use domain filtering or rely on Claude Code's automatic Tool Search
- **Deprecated packages**: Some MCP servers have deprecated npm packages (e.g., `@modelcontextprotocol/server-github`). Always check the provider's latest docs
