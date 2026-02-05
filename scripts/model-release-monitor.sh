#!/bin/bash
# Model Release Monitor - Tracks bleeding edge AI model releases
# Monitors: Sonnet 5.0/4.7, Grok 4.20, GPT 5.3
# Note: Twitter/X monitoring would require X API access; this uses web search as proxy
# Runs every 5 minutes

set -e

STATE_FILE="/root/clawd/memory/model-releases-state.json"

# Models we're monitoring
MODELS=(
    "Claude Sonnet 5.0"
    "Claude Sonnet 4.7"
    "Grok 4.20"
    "GPT 5.3"
)

# User mentions
PEASANTRY="<@931708065319907338>"
REVANTH="<@596511748735893505>"

# Initialize
if [ ! -f "$STATE_FILE" ]; then
    echo '{"last_check": null, "notified": [], "cycles": 0}' > "$STATE_FILE"
fi

CYCLES=$(jq '.cycles' "$STATE_FILE")
CYCLE_NUM=$((CYCLES + 1))

echo "[$(date -Iseconds)] Model Release Monitor - Cycle $CYCLE_NUM"
echo "Monitoring: ${MODELS[*]}"

# Update state
jq --arg ts "$(date -Iseconds)" '.cycles = (.cycles + 1) | .last_check = $ts' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

# Search with stricter filtering
HITS=""

for model in "${MODELS[@]}"; do
    SEARCH_QUERY="${model/ /+}+official+release+2026"
    HTML=$(timeout 8 curl -s -A "Mozilla/5.0" "https://html.duckduckgo.com/html/?q=${SEARCH_QUERY}&df=d-2" 2>/dev/null || echo "")
    # Look for very strong indicators only
    if echo "$HTML" | grep -ioP '(class="result__snippet">|class="result__title">)' | head -1 >/dev/null 2>&1; then
        if echo "$HTML" | grep -qiP "(officially released|now available|launched today|breaking.*release)"; then
            HITS="${HITS}${model}\n"
        fi
    fi
done

if [ -n "$HITS" ]; then
    echo "$PEASANTRY 🚨 POTENTIAL RELEASE DETECTED:\n$HITS"
    echo "Source: recent web search (2 days)"
    echo "ALERT=true"
else
    if [ $((CYCLE_NUM % 12)) -eq 0 ] && [ "$CYCLE_NUM" -gt 0 ]; then
        echo "$REVANTH Model monitor: $((CYCLE_NUM / 12))h sampled. Watching: ${MODELS[*]}"
        echo "REVANTH_PING=true"
    else
        echo "No signals this cycle"
    fi
fi
echo "[$(date -Iseconds)] Done"