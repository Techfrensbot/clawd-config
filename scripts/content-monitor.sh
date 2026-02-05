#!/bin/bash
# Content Monitor - Alerts when specific text appears on a page

set -e

URL="${1:-}"
SEARCH_TERMS="${2:-}"
PEASANTRY="<@931708065319907338>"

if [ -z "$URL" ] || [ -z "$SEARCH_TERMS" ]; then
    echo "Usage: $0 <url> \"term1|term2|term3\""
    echo "Example: $0 https://example.com \"Sonnet 5.0|Sonnet 5|Claude 5\""
    exit 1
fi

# Generate state file path from URL + terms hash
URL_HASH=$(echo "${URL}${SEARCH_TERMS}" | md5sum | cut -d' ' -f1 | cut -c1-16)
STATE_FILE="/root/clawd/memory/content-monitor-${URL_HASH}.json"

# Initialize state
if [ ! -f "$STATE_FILE" ]; then
    echo '{"last_content": null, "notified": false, "checks": 0, "matches_found": []}' > "$STATE_FILE"
fi

# Fetch page content
CONTENT=$(curl -s -L --max-time 15 "$URL" 2>/dev/null | tr -d '\n\r\t' | sed 's/<[^>]*>//g' || echo "")

if [ -z "$CONTENT" ]; then
    echo "Error: Could not fetch content from ${URL}"
    exit 1
fi

CHECKS=$(jq '.checks' "$STATE_FILE")
NEW_CHECKS=$((CHECKS + 1))

# Update check count
jq --arg checks "$NEW_CHECKS" '.checks = ($checks | tonumber)' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

ALREADY_NOTIFIED=$(jq -r '.notified' "$STATE_FILE")
MATCHES_FOUND=""

# Check for each search term
IFS='|' read -ra TERMS <<< "$SEARCH_TERMS"
for term in "${TERMS[@]}"; do
    if echo "$CONTENT" | grep -qi "$term"; then
        MATCHES_FOUND="${MATCHES_FOUND}${term}, "
    fi
done

# Remove trailing comma
MATCHES_FOUND=$(echo "$MATCHES_FOUND" | sed 's/, $//')

# Update state with matches
jq --arg matches "$MATCHES_FOUND" --arg ts "$(date -Iseconds)" \
   '.last_check = $ts | .matches_found += [$matches]' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

# Check if we should alert
if [ -n "$MATCHES_FOUND" ] && [ "$ALREADY_NOTIFIED" = "false" ]; then
    # Match found!
    jq '.notified = true' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    
    echo "${PEASANTRY} 🚨 CONTENT MATCH FOUND!"
    echo ""
    echo "🔗 ${URL}"
    echo "🔍 Matched: ${MATCHES_FOUND}"
    echo "⏰ Checked ${NEW_CHECKS} times"
    echo ""
    echo "ALERT=true"
    
elif [ -z "$MATCHES_FOUND" ]; then
    # No match yet
    echo "No match found (checked: ${NEW_CHECKS})"
    echo "Searching for: ${SEARCH_TERMS}"
    echo "URL: ${URL}"
else
    # Already notified
    echo "Already notified. Matches still present: ${MATCHES_FOUND}"
fi
