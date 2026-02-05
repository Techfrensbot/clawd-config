#!/bin/bash
# URL Status Monitor - Alerts when page becomes available (not 404)

set -e

URL="${1:-}"
TARGET_STATUS="${2:-200}"
PEASANTRY="<@931708065319907338>"

if [ -z "$URL" ]; then
    echo "Usage: $0 <url> [target_status_code]"
    exit 1
fi

# Generate state file path from URL hash
URL_HASH=$(echo "$URL" | md5sum | cut -d' ' -f1 | cut -c1-16)
STATE_FILE="/root/clawd/memory/url-monitor-${URL_HASH}.json"

# Initialize state
if [ ! -f "$STATE_FILE" ]; then
    echo '{"last_status": null, "notified": false, "checks": 0}' > "$STATE_FILE"
fi

# Check URL
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$URL" 2>/dev/null || echo "000")

CHECKS=$(jq '.checks' "$STATE_FILE")
NEW_CHECKS=$((CHECKS + 1))

# Update check count
jq --arg checks "$NEW_CHECKS" '.checks = ($checks | tonumber)' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

LAST_STATUS=$(jq -r '.last_status // empty' "$STATE_FILE")
ALREADY_NOTIFIED=$(jq -r '.notified' "$STATE_FILE")

# Update last status
jq --arg status "$HTTP_CODE" --arg ts "$(date -Iseconds)" '.last_status = $status | .last_check = $ts' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

# Check if we should alert
if [ "$HTTP_CODE" = "$TARGET_STATUS" ] && [ "$ALREADY_NOTIFIED" = "false" ]; then
    # Page is now available!
    jq '.notified = true' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    
    echo "${PEASANTRY} 🚨 PAGE IS NOW LIVE!"
    echo ""
    echo "🔗 ${URL}"
    echo "📊 Status: ${HTTP_CODE}"
    echo "⏰ Checked ${NEW_CHECKS} times"
    echo ""
    echo "ALERT=true"
    
elif [ "$HTTP_CODE" != "$TARGET_STATUS" ]; then
    # Still not available
    echo "Status: ${HTTP_CODE} (waiting for ${TARGET_STATUS})"
    echo "Checks: ${NEW_CHECKS}"
    echo "URL: ${URL}"
else
    # Already notified
    echo "Already notified. Page remains available (${HTTP_CODE})"
fi
