#!/bin/bash
# Exa MCP search - no API key required!

QUERY="$1"
NUM_RESULTS="${2:-5}"
START_DATE="${3:-}"  # Optional: ISO 8601 date like 2026-01-28T00:00:00Z
MCP_URL="https://mcp.exa.ai/mcp?tools=web_search_exa,get_code_context_exa,crawling_exa,company_research_exa,linkedin_search_exa,deep_researcher_start,deep_researcher_check"

if [ -z "$QUERY" ]; then
    echo "Usage: bash mcp-search.sh \"query\" [num_results] [start_date]" >&2
    exit 1
fi

# Build JSON payload
if [ -n "$START_DATE" ]; then
    PAYLOAD="{\"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"tools/call\", \"params\": {\"name\": \"web_search_exa\", \"arguments\": {\"query\": \"$QUERY\", \"numResults\": $NUM_RESULTS, \"startDate\": \"$START_DATE\"}}}"
else
    PAYLOAD="{\"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"tools/call\", \"params\": {\"name\": \"web_search_exa\", \"arguments\": {\"query\": \"$QUERY\", \"numResults\": $NUM_RESULTS}}}"
fi

curl -s -X POST "$MCP_URL" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d "$PAYLOAD" \
  | grep '^data: ' | sed 's/^data: //' | jq -r '.result.content[0].text'
