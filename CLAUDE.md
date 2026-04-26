# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a locally runnable version of Claude Code (based on leaked source code from 2026-03-31), with fixes applied to enable the full Ink TUI interface to work locally. It supports connecting to any Anthropic-compatible API (MiniMax, OpenRouter, etc.).

## Common Commands

```bash
# Install dependencies
bun install

# Copy and configure environment variables
cp .env.example .env

# Interactive TUI mode
./bin/claude-haha

# Headless mode (script/CI usage)
./bin/claude-haha -p "your prompt here"

# Recovery CLI mode (simple readline REPL, no Ink TUI)
CLAUDE_CODE_FORCE_RECOVERY_CLI=1 ./bin/claude-haha

# Docs development
vitepress dev docs
vitepress build docs
```

## Architecture

### Entry Points
- `src/entrypoints/cli.tsx` - CLI main entry point
- `src/main.tsx` - TUI main logic (Commander.js + React/Ink)
- `bin/claude-haha` - Shell launcher script

### Core Modules
- `src/tools/` - Agent tools (BashTool, EditTool, GrepTool, AgentTool, etc.)
- `src/commands/` - Slash commands (/commit, /review, etc.)
- `src/skills/` - Skills system for extensible capabilities
- `src/services/` - Service layer (API, MCP, OAuth, analytics)
- `src/ink/` - Ink terminal rendering engine
- `src/components/` - React UI components
- `src/utils/` - Utility functions

### Key Systems

**Multi-Agent System** (`src/tools/AgentTool/`):
- 4 spawn paths: Teammate (team collaboration), Async Subagent (background), Fork Subagent (prompt cache optimization), Sync Subagent (default)
- TeamFile stores team config at `~/.claude/teams/{team_name}/config.json`
- Mailbox system for inter-agent communication at `~/.claude/teams/{team_name}/inboxes/`

**Skills System** (`src/skills/`):
- Discovered from 6 sources: bundled, builtin plugin, managed, user, project, MCP
- Loaded via `loadAllCommands()` in `src/commands.ts` with memoization
- Conditional Skills activated via `paths` frontmatter when matching files are accessed
- Fork execution via `executeForkedSkill()` runs skill in isolated sub-agent

**Channel System** (`src/services/mcp/channelNotification.ts`):
- IM integration (Telegram/Feishu/Discord) via MCP protocol
- Channel is an MCP Server declaring `experimental['claude/channel']` capability
- 6-layer access control gate before message registration
- Permission relay allows remote approval/denial of sensitive operations

**Memory System**:
- Cross-session persistent memory
- DreamTask for automatic memory consolidation

## Environment Variables

Key variables in `.env.example`:
- `ANTHROPIC_API_KEY` / `ANTHROPIC_BASE_URL` - API configuration
- `CLAUDE_CODE_FORCE_RECOVERY_CLI=1` - Force recovery CLI mode

## Docs Structure

- `docs/guide/` - User guides (env-vars, faq, global-usage, third-party-models)
- `docs/agent/` - Multi-agent system documentation
- `docs/skills/` - Skills system documentation
- `docs/channel/` - Channel system (IM remote control)
- `docs/features/` - Computer Use and other features
- `docs/reference/` - Project structure and fix records
