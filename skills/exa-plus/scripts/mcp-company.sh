#!/bin/bash
# Exa MCP company research - no API key required!

COMPANY_NAME="$1"
NUM_RESULTS="${2:-5}"
MCP_URL="https://mcp.exa.ai/mcp?tools=web_search_exa,get_code_context_exa,crawling_exa,company_research_exa,linkedin_search_exa,deep_researcher_start,deep_researcher_check"

if [ -z "$COMPANY_NAME" ]; then
    echo "Usage: bash mcp-company.sh \"company name\" [num_results]" >&2
    echo "Example: bash mcp-company.sh \"Anthropic\" 3" >&2
    exit 1
fi

curl -s -X POST "$MCP_URL" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d "{\"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"tools/call\", \"params\": {\"name\": \"company_research_exa\", \"arguments\": {\"companyName\": \"$COMPANY_NAME\", \"numResults\": $NUM_RESULTS}}}" \
  | grep '^data: ' | sed 's/^data: //' | jq -r '.result.content[0].text'
