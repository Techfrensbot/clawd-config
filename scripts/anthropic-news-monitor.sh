#!/bin/bash
# Anthropic News Monitor - Enhanced with content hashing
# Detects ANY changes to news section, validates article detection

set -e

URL="https://www.anthropic.com/news"
STATE_FILE="/root/clawd/memory/anthropic-news-monitor.json"
PEASANTRY="<@931708065319907338>"

# Initialize state
if [ ! -f "$STATE_FILE" ]; then
    echo '{"last_hash": null, "last_article": null, "check_count": 0, "false_negatives": 0}' > "$STATE_FILE"
fi

# Fetch page HTML
HTML=$(curl -s -L --max-time 15 "$URL" -H "User-Agent: Mozilla/5.0" 2>/dev/null || echo "")

if [ -z "$HTML" ]; then
    echo "Error: Could not fetch ${URL}"
    exit 1
fi

# Extract featured article section (the top/newest article)
FEATURED_SECTION=$(echo "$HTML" | grep -oP 'FeaturedGrid-module[^>]*>.*?</h2>.*?</time>' | head -1)

# Calculate hash of featured section
CURRENT_HASH=$(echo "$FEATURED_SECTION" | md5sum | cut -d' ' -f1)

# Extract article title and date
ARTICLE_TITLE=$(echo "$FEATURED_SECTION" | grep -oP '<h2[^>]*>\K[^<]+' | head -1)
ARTICLE_DATE=$(echo "$FEATURED_SECTION" | grep -oP '<time[^>]*>\K[^<]+' | head -1)

# Load previous state
LAST_HASH=$(jq -r '.last_hash' "$STATE_FILE")
LAST_ARTICLE=$(jq -r '.last_article' "$STATE_FILE")
CHECK_COUNT=$(jq '.check_count' "$STATE_FILE")
NEW_COUNT=$((CHECK_COUNT + 1))

# Update check count
jq --arg count "$NEW_COUNT" '.check_count = ($count | tonumber)' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

# Check if content hash changed
if [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
    # Hash changed - content updated
    
    # Check if we detected a new article
    if [ "$ARTICLE_TITLE" != "$LAST_ARTICLE" ] && [ -n "$ARTICLE_TITLE" ]; then
        # New article detected - this is the expected case
        jq --arg hash "$CURRENT_HASH" --arg article "$ARTICLE_TITLE" --arg date "$ARTICLE_DATE" \
           '.last_hash = $hash | .last_article = $article | .last_date = $date' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
        
        echo "${PEASANTRY} 🚨 New Anthropic Article Detected!"
        echo ""
        echo "📰 **${ARTICLE_TITLE}**"
        echo "📅 ${ARTICLE_DATE}"
        echo "🔗 ${URL}"
        echo ""
        echo "ALERT=true"
        
    else
        # Hash changed but no new article detected - FALSE NEGATIVE!
        FALSE_NEGS=$(jq '.false_negatives' "$STATE_FILE")
        NEW_FALSE_NEGS=$((FALSE_NEGS + 1))
        
        jq --arg hash "$CURRENT_HASH" --arg count "$NEW_FALSE_NEGS" \
           '.last_hash = $hash | .false_negatives = ($count | tonumber) | .warning = "Hash changed but no new article detected - DOUBLE CHECK REQUIRED"' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
        
        echo "${PEASANTRY} ⚠️ **DETECTION FAILURE**"
        echo ""
        echo "Content hash changed but no new article detected!"
        echo "Previous: ${LAST_ARTICLE}"
        echo "Current detected: ${ARTICLE_TITLE}"
        echo ""
        echo "🔗 ${URL}"
        echo ""
        echo "This is likely a detection bug - manual review needed."
        echo ""
        echo "ALERT=true"
    fi
else
    # No change
    echo "No new content (check #${NEW_COUNT})"
    echo "Last article: ${LAST_ARTICLE}"
    echo "Hash: ${CURRENT_HASH:0:16}..."
fi
