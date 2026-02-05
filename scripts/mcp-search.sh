#!/bin/bash
# MCP Exa search wrapper - pulls from installed exa-plus skill
SKILL_PATH="${SKILL_PATH:-/root/clawd/skills/exa-plus/scripts/mcp-search.sh}"
if [ ! -f "$SKILL_PATH" ]; then
  SKILL_PATH="/usr/lib/node_modules/clawdbot/skills/exa-plus/scripts/mcp-search.sh"
fi
exec "$SKILL_PATH" "$@"
