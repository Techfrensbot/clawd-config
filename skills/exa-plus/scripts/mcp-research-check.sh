#!/bin/bash
# Exa MCP deep research (check) - no API key required!

TASK_ID="$1"
MCP_URL="https://mcp.exa.ai/mcp?tools=web_search_exa,get_code_context_exa,crawling_exa,company_research_exa,linkedin_search_exa,deep_researcher_start,deep_researcher_check"

if [ -z "$TASK_ID" ]; then
    echo "Usage: bash mcp-research-check.sh \"task_id\"" >&2
    echo "Example: bash mcp-research-check.sh \"abc123\"" >&2
    echo "Note: This script includes a 5-second delay. Poll until status is 'completed'." >&2
    exit 1
fi

curl -s -X POST "$MCP_URL" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d "{\"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"tools/call\", \"params\": {\"name\": \"deep_researcher_check\", \"arguments\": {\"taskId\": \"$TASK_ID\"}}}" \
  | grep '^data: ' | sed 's/^data: //' | jq -r '.result.content[0].text'
