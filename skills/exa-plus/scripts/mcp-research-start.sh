#!/bin/bash
# Exa MCP deep research (start) - no API key required!

INSTRUCTIONS="$1"
MODEL="${2:-exa-research}"
MCP_URL="https://mcp.exa.ai/mcp?tools=web_search_exa,get_code_context_exa,crawling_exa,company_research_exa,linkedin_search_exa,deep_researcher_start,deep_researcher_check"

if [ -z "$INSTRUCTIONS" ]; then
    echo "Usage: bash mcp-research-start.sh \"research question\" [model]" >&2
    echo "Models: exa-research (fast, 15-45s), exa-research-pro (comprehensive, 45s-2min)" >&2
    echo "Example: bash mcp-research-start.sh \"What are the latest developments in AI agents?\" exa-research" >&2
    exit 1
fi

curl -s -X POST "$MCP_URL" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d "{\"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"tools/call\", \"params\": {\"name\": \"deep_researcher_start\", \"arguments\": {\"instructions\": \"$INSTRUCTIONS\", \"model\": \"$MODEL\"}}}" \
  | grep '^data: ' | sed 's/^data: //' | jq -r '.result.content[0].text'
