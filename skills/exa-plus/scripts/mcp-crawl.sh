#!/bin/bash
# Exa MCP URL crawling - no API key required!

URL="$1"
MAX_CHARS="${2:-3000}"
MCP_URL="https://mcp.exa.ai/mcp?tools=web_search_exa,get_code_context_exa,crawling_exa,company_research_exa,linkedin_search_exa,deep_researcher_start,deep_researcher_check"

if [ -z "$URL" ]; then
    echo "Usage: bash mcp-crawl.sh \"url\" [max_chars]" >&2
    echo "Example: bash mcp-crawl.sh \"https://example.com\" 5000" >&2
    exit 1
fi

curl -s -X POST "$MCP_URL" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d "{\"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"tools/call\", \"params\": {\"name\": \"crawling_exa\", \"arguments\": {\"url\": \"$URL\", \"maxCharacters\": $MAX_CHARS}}}" \
  | grep '^data: ' | sed 's/^data: //' | jq -r '.result.content[0].text'
