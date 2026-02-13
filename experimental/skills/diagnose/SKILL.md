---
description: Diagnose Claude Code problems by analyzing chat history, logs, and live documentation, then generate a root cause analysis, support ticket, and team message
disable-model-invocation: true
argument-hint: [description of the problem]
allowed-tools: Read, Grep, Glob, Bash(ls *), Bash(find *), Bash(cat *), Bash(tail *), Bash(head *), Bash(wc *), WebFetch, WebSearch
---

# Claude Code Diagnostic Skill

You are a diagnostic specialist for Claude Code issues. The user is experiencing a problem and needs a structured analysis with actionable outputs. Follow every phase below in order.

## Phase 1: Understand the Problem

Read the user's problem description carefully:

**Problem:** $ARGUMENTS

If the description is vague, ask one round of clarifying questions before proceeding. Otherwise, move directly to investigation.

## Phase 2: Gather Evidence from Chat History

Review the current conversation history for:

- Error messages, stack traces, or unusual output
- Patterns of repeated failures or retries
- Tool calls that failed or timed out
- Any workarounds the user already attempted
- Timestamps and frequency of failures

Summarize what you find as a bulleted list of **observations**.

## Phase 3: Gather Evidence from Claude Code Logs

Search the Claude Code log directories for entries related to the problem. Common log locations:

- `~/.claude/logs/`
- `~/.claude.log`
- `/tmp/claude-*` or `/tmp/claude_*`

Use Glob to find log files, then Grep and Read to search them for:

- Error messages matching the reported problem
- Network errors, timeouts, connection resets
- API errors or HTTP status codes (429, 500, 502, 503, 504)
- Crash reports or unexpected exits
- Timestamps correlating with the reported issue window

If logs are large, focus on the most recent entries (last 500 lines) and entries matching error keywords.

Summarize what you find as a bulleted list of **log evidence**.

## Phase 4: Fetch Latest Anthropic Documentation

Based on the error messages and symptoms found in Phases 2-3, fetch the relevant Anthropic documentation. Always start with:

- **Troubleshooting guide**: https://code.claude.com/docs/en/troubleshooting

Then fetch additional pages based on the specific subsystem involved. Use the documentation index at https://code.claude.com/docs/llms.txt to discover relevant pages. Examples:

- Network/connection issues -> fetch networking and proxy docs
- Permission errors -> fetch permissions docs
- Plugin errors -> fetch plugin docs
- MCP errors -> fetch MCP docs
- Performance issues -> fetch configuration and optimization docs

Use WebFetch to retrieve each relevant page and extract information about:

- Known issues matching the symptoms
- Recommended configuration for the user's environment
- Diagnostic steps suggested by Anthropic
- Workarounds or fixes documented by Anthropic

## Phase 5: Root Cause Analysis

Cross-reference everything from Phases 2-4 and produce a structured analysis:

### Diagnosis Report

#### Summary
One-paragraph summary of the problem and its most likely cause.

#### Evidence
| Source | Finding | Relevance |
|--------|---------|-----------|
| Chat history | (what you found) | (how it relates to the root cause) |
| Logs | (what you found) | (how it relates to the root cause) |
| Documentation | (what you found) | (how it relates to the root cause) |

#### Probable Root Causes (ranked by likelihood)
1. **Most likely cause** - explanation with supporting evidence
2. **Second most likely** - explanation with supporting evidence
3. **Other possibilities** - if applicable

#### Recommended Fixes
For each root cause, provide concrete steps:
1. **Immediate fix** - what to do right now to unblock
2. **Proper fix** - the correct long-term resolution
3. **Prevention** - how to avoid this in the future

## Phase 6: Generate Support Ticket

Write a support ticket suitable for submitting to Anthropic support or posting on https://github.com/anthropics/claude-code/issues:

```
### Support Ticket

**Title:** [concise title]

**Environment:**
- Claude Code version: (extract from logs or ask user)
- OS: (detect from environment)
- Shell: (detect from environment)

**Problem Description:**
[2-3 sentences describing the problem clearly]

**Steps to Reproduce:**
1. [step]
2. [step]
3. [step]

**Expected Behavior:**
[what should happen]

**Actual Behavior:**
[what actually happens, including error messages]

**Relevant Log Excerpts:**
[key log lines, redacting any sensitive information like API keys or internal URLs]

**Diagnostic Analysis:**
[1-2 sentences summarizing your root cause findings]

**Attempted Workarounds:**
[what was tried and what happened]
```

## Phase 7: Generate Team Message

Write a concise message suitable for posting in a project chat (Slack, Teams, etc.) to ask teammates about the issue:

```
### Team Message

**Subject:** [short subject line]

**Message:**
Hey team - I've been hitting an issue with Claude Code: [1-sentence summary].

**Symptoms:** [bullet points of what's happening]

**What I've found so far:** [brief summary of diagnosis]

**Questions for the team:**
- Has anyone seen similar behavior?
- Are there any known firewall/proxy/network changes that might affect this?
- Any workarounds that have worked for you?

[Any relevant environment details that might help teammates compare their setup]
```

## Important Guidelines

- **Redact sensitive data**: Strip API keys, auth tokens, internal hostnames, and personal information from all outputs
- **Be specific**: Reference exact error messages, log lines, and timestamps where possible
- **Stay evidence-based**: Clearly distinguish confirmed facts from speculation
- **Prioritize actionability**: The user needs to unblock themselves, so lead with immediate fixes
- **Fetch live docs**: Always check the latest Anthropic documentation rather than relying on cached knowledge
