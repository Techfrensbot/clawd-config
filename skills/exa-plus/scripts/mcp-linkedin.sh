#!/bin/bash
# Exa MCP LinkedIn search - no API key required!

QUERY="$1"
SEARCH_TYPE="${2:-all}"
NUM_RESULTS="${3:-5}"
MCP_URL="https://mcp.exa.ai/mcp?tools=web_search_exa,get_code_context_exa,crawling_exa,company_research_exa,linkedin_search_exa,deep_researcher_start,deep_researcher_check"

if [ -z "$QUERY" ]; then
    echo "Usage: bash mcp-linkedin.sh \"query\" [search_type] [num_results]" >&2
    echo "Search types: profiles, companies, all (default)" >&2
    echo "Example: bash mcp-linkedin.sh \"AI engineer San Francisco\" profiles 3" >&2
    exit 1
fi

curl -s -X POST "$MCP_URL" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d "{\"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"tools/call\", \"params\": {\"name\": \"linkedin_search_exa\", \"arguments\": {\"query\": \"$QUERY\", \"searchType\": \"$SEARCH_TYPE\", \"numResults\": $NUM_RESULTS}}}" \
  | grep '^data: ' | sed 's/^data: //' | jq -r '.result.content[0].text'
