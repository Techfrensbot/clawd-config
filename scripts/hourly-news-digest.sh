#!/bin/bash
# Hourly AI News Digest - pulls fresh stories and filters against history
set -e

HISTORY_FILE="/root/clawd/memory/news-history.json"
RESULTS_COUNT=10

echo "[NEWS] Fetching latest AI news..."

# Try Exa first, fall back to generic web search
fetch_news() {
  # First try: Exa API via MCP (no key needed in theory)
  if command -v curl &> /dev/null && command -v jq &> /dev/null; then
    # Fallback: use Brave Search if configured
    if [ -n "$BRAVE_API_KEY" ]; then
      echo "Using Brave Search API..."
      curl -s "https://api.search.brave.com/res/v1/web/search" \
        -H "Accept: application/json" \
        -H "X-Subscription-Token: $BRAVE_API_KEY" \
        -d "q=latest+AI+news+January+2026&count=$RESULTS_COUNT" | \
        jq -r '.results[]?.title' 2>/dev/null || echo "Brave API failed"
    else
      echo "ERROR: BRAVE_API_KEY not set. Configure with: clawdbot configure --section web"
      exit 1
    fi
  fi
}

# Load existing headlines
load_history() {
  if [ -f "$HISTORY_FILE" ]; then
    cat "$HISTORY_FILE"
  else
    echo "[]"
  fi
}

# Get new headlines not in history
filter_new_headlines() {
  local history="$1"
  local new_headlines="$2"
  
  jq --slurpfile history <(echo "$history") \
    --slurpfile new <(echo "$new_headlines") \
    '
    . as $new |
    ($history[0] // []) as $hist |
    $new[] | select(. as $item | $hist[] | select(. == $item) | not)
    ' 2>/dev/null || echo "$new_headlines"
}

# Update history with new entries (keep latest 24)
update_history() {
  local history="$1"
  local new_items="$2"
  
  jq -s '(.[0] + .[1]) | unique | .[0:24]' \
    <(echo "$history") \
    <(echo "$new_items") > "$HISTORY_FILE.tmp"
  mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
  echo "Updated history with $(echo "$new_items" | jq 'length') new entries"
}

# Main execution
echo "Loading history..."
HISTORY=$(load_history)
HISTORY_COUNT=$(echo "$HISTORY" | jq 'length')
echo "Current history: $HISTORY_COUNT entries"

echo "Fetching news..."
NEW_HEADLINES=$(fetch_news | jq -R '.' | jq -s '.' 2>/dev/null || echo "[]")

if [ "$(echo "$NEW_HEADLINES" | jq 'length')" -eq 0 ]; then
  echo "No headlines fetched. APIs may not be configured."
  exit 1
fi

# Filter against history
UNIQUE_HEADLINES=$(filter_new_headlines "$HISTORY" "$NEW_HEADLINES")
UNIQUE_COUNT=$(echo "$UNIQUE_HEADLINES" | jq 'length // 0')

if [ "$UNIQUE_COUNT" -gt 0 ]; then
  echo "$UNIQUE_COUNT new headlines found"
  echo "$UNIQUE_HEADLINES"
  update_history "$HISTORY" "$UNIQUE_HEADLINES"
else
  echo "No new headlines (all in history)"
fi
