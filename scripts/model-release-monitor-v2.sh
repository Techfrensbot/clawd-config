#!/bin/bash
# Model Release Monitor v2.2 - Grok X/Twitter with Scira-style System Prompt
# Monitors: Sonnet 5.0/4.7, Grok 4.20, GPT 5.3
# Uses Scira's X Search methodology for accurate results

set -e

STATE_FILE="/root/clawd/memory/model-releases-state.json"
CREDENTIALS_FILE="${HOME}/.clawdbot/credentials/pollinations/config.json"

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

# Load API key
API_KEY=$(jq -r '.apiKey' "$CREDENTIALS_FILE" 2>/dev/null || echo "")

if [ -z "$API_KEY" ]; then
    echo "[$(date -Iseconds)] ERROR: No API key found"
    exit 1
fi

# Initialize state
if [ ! -f "$STATE_FILE" ]; then
    echo '{"last_check": null, "notified": [], "cycles": 0, "grok_checked": []}' > "$STATE_FILE"
fi

CYCLES=$(jq '.cycles' "$STATE_FILE")
CYCLE_NUM=$((CYCLES + 1))

echo "[$(date -Iseconds)] Model Release Monitor v2.2 (Scira-style Grok X) - Cycle $CYCLE_NUM"
echo "Monitoring: ${MODELS[*]}"

# Update state
jq --arg ts "$(date -Iseconds)" '.cycles = (.cycles + 1) | .last_check = $ts' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

ALERT_FOUND=false
ALERT_MSG=""

# Scira-style System Prompt for X Search
SYSTEM_PROMPT='You are an X/Twitter search assistant. Your task is to search for recent posts about AI model releases.

### Search Guidelines (MANDATORY):
- Search for posts from the LAST 24 HOURS ONLY
- Use MULTIPLE query variations (3-5 different phrasings) for comprehensive coverage
- Queries must be in NATURAL LANGUAGE - no Twitter syntax (no "from:", "to:", "filter:")
- If searching for specific accounts, note them separately - do NOT include handles in queries
- Focus on finding ACTUAL tweet content, not generating plausible-sounding summaries

### Response Format:
For each model search, provide:
1. **Query variations used** (list them)
2. **Actual findings** - ONLY include tweets you can verify exist
3. **If no results**: Explicitly state "No recent posts found"
4. **Never hallucinate**: If you cannot verify a tweet exists, do NOT include it

### Date Handling:
- ONLY search last 24 hours (today and yesterday)
- Ignore older posts even if relevant
- Do NOT make up dates or timestamps

### Output Requirements:
- Be concise but specific
- Include actual tweet text snippets if found
- Include tweet URLs ONLY if you can provide real, working links
- If uncertain about a claim, omit it rather than guess'

echo "[$(date -Iseconds)] Checking Grok X/Twitter with Scira-style prompts..."

for model in "${MODELS[@]}"; do
    # Check if we already searched this model in last 6 hours
    LAST_CHECK=$(jq -r --arg m "$model" '.grok_checked[]? | select(.model == $m) | .ts' "$STATE_FILE" | tail -1)
    if [ -n "$LAST_CHECK" ]; then
        LAST_EPOCH=$(date -d "$LAST_CHECK" +%s 2>/dev/null || echo 0)
        NOW_EPOCH=$(date +%s)
        DIFF=$((NOW_EPOCH - LAST_EPOCH))
        if [ $DIFF -lt 21600 ]; then  # 6 hours
            echo "  Skipping $model (checked ${DIFF}s ago)"
            continue
        fi
    fi
    
    echo "  Checking $model..."
    
    # Build multi-query prompt following Scira methodology
    QUERY_VARIATIONS="${model} release today,${model} announced,${model} launched,${model} official release,${model} news today"
    
    # Grok X search via Pollinations with system prompt
    RESPONSE=$(curl -s -X POST 'https://gen.pollinations.ai/v1/chat/completions' \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"grok\",
            \"messages\": [
                {\"role\": \"system\", \"content\": \"${SYSTEM_PROMPT}\"},
                {\"role\": \"user\", \"content\": \"Search X/Twitter for posts about ${model} using these query variations: ${QUERY_VARIATIONS}. Only report verified findings from the last 24 hours. If no posts found, explicitly state 'No recent posts found'.\"}
            ]
        }")
    
    # Extract content from response
    CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content' 2>/dev/null || echo "")
    
    # Check if response indicates no results (better filtering)
    if echo "$CONTENT" | grep -qiE "no recent posts found|no posts found|no results|no activity"; then
        echo "    ✓ No recent posts for $model"
    elif echo "$CONTENT" | grep -qiE "(released|available|launched|out now|officially announced|breaking)" && \
         ! echo "$CONTENT" | grep -qiE "(rumor|speculation|might|could|may|expected|predicted|guess)"; then
        # Strong signal detected (not just rumors)
        ALERT_MSG="${ALERT_MSG}🚨 **${model}**\n${CONTENT}\n\n---\n\n"
        ALERT_FOUND=true
        echo "    ⚠️  ALERT: Strong signal detected for $model"
    else
        echo "    ⚠️  Weak signal or rumors only for $model"
    fi
    
    # Update last checked
    jq --arg m "$model" --arg ts "$(date -Iseconds)" '.grok_checked += [{"model": $m, "ts": $ts}]' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    
    sleep 2  # Rate limiting between calls
done

# Output results
if [ "$ALERT_FOUND" = true ]; then
    echo "$PEASANTRY 🚨 POTENTIAL RELEASE DETECTED (Scira-style search):\n\n$ALERT_MSG"
    echo "Note: Results filtered for verified signals only (no rumors/speculation)"
    echo "ALERT=true"
else
    if [ $((CYCLE_NUM % 12)) -eq 0 ] && [ "$CYCLE_NUM" -gt 0 ]; then
        echo "$REVANTH Model monitor: $((CYCLE_NUM / 12))h sampled via Grok X (Scira-style). Watching: ${MODELS[*]}"
        echo "REVANTH_PING=true"
    else
        echo "No verified signals this cycle (Grok X with Scira prompts)"
    fi
fi

echo "[$(date -Iseconds)] Done"
