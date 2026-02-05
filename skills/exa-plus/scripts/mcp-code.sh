#!/bin/bash
# Exa MCP code context search - no API key required!

QUERY="$1"
TOKENS="${2:-5000}"
MCP_URL="https://mcp.exa.ai/mcp?tools=web_search_exa,get_code_context_exa,crawling_exa,company_research_exa,linkedin_search_exa,deep_researcher_start,deep_researcher_check"

if [ -z "$QUERY" ]; then
    echo "Usage: bash mcp-code.sh \"query\" [tokens]" >&2
    echo "Example: bash mcp-code.sh \"React useState hook examples\" 3000" >&2
    exit 1
fi

curl -s -X POST "$MCP_URL" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d "{\"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"tools/call\", \"params\": {\"name\": \"get_code_context_exa\", \"arguments\": {\"query\": \"$QUERY\", \"tokensNum\": $TOKENS}}}" \
  | grep '^data: ' | sed 's/^data: //' | jq -r '.result.content[0].text'
