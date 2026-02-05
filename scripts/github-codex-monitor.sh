#!/bin/bash
# GitHub Commit Monitor for OpenAI Codex
# Tracks new commits and notifies on changes

set -e

REPO="openai/codex"
BRANCH="main"
API_URL="https://api.github.com/repos/${REPO}/commits/${BRANCH}"
STATE_FILE="/root/clawd/memory/github-codex-commits.json"
PEASANTRY="<@931708065319907338>"

# Initialize state file if not exists
if [ ! -f "$STATE_FILE" ]; then
    echo '{"last_sha": null, "last_check": null, "commits_notified": []}' > "$STATE_FILE"
fi

# Fetch latest commit info
echo "[$(date -Iseconds)] Checking ${REPO} for new commits..."

RESPONSE=$(curl -s -L \
    -H "Accept: application/vnd.github.v3+json" \
    -H "User-Agent: Frenbot-Commit-Monitor" \
    --max-time 15 \
    "$API_URL" 2>/dev/null || echo "")

if [ -z "$RESPONSE" ] || [ "$(echo "$RESPONSE" | jq -r 'type' 2>/dev/null)" != "object" ]; then
    echo "Error: Failed to fetch commits from GitHub API"
    exit 1
fi

# Extract commit info
LATEST_SHA=$(echo "$RESPONSE" | jq -r '.sha // empty')
COMMIT_MSG=$(echo "$RESPONSE" | jq -r '.commit.message // empty' | head -1)
AUTHOR=$(echo "$RESPONSE" | jq -r '.commit.author.name // empty')
AUTHOR_LOGIN=$(echo "$RESPONSE" | jq -r '.author.login // empty')
DATE=$(echo "$RESPONSE" | jq -r '.commit.author.date // empty')
HTML_URL=$(echo "$RESPONSE" | jq -r '.html_url // empty')

if [ -z "$LATEST_SHA" ] || [ "$LATEST_SHA" = "null" ]; then
    echo "Error: Could not parse commit SHA from response"
    exit 1
fi

# Read previous state
LAST_SHA=$(jq -r '.last_sha // empty' "$STATE_FILE")

# Update state with current check
jq --arg sha "$LATEST_SHA" \
   --arg ts "$(date -Iseconds)" \
   '.last_check = $ts | .last_sha = $sha' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

# Check if this is a new commit
if [ "$LATEST_SHA" != "$LAST_SHA" ] && [ -n "$LAST_SHA" ]; then
    # New commit detected!
    SHORT_SHA="${LATEST_SHA:0:7}"
    
    # Add to notified list (keep last 50)
    jq --arg sha "$LATEST_SHA" \
       '.commits_notified += [$sha] | .commits_notified = .commits_notified[-50:]' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    
    # Format message
    echo "${PEASANTRY} 🆕 New commit in **openai/codex**!"
    echo ""
    echo "\`\`\`${COMMIT_MSG:0:100}\`\`\`"
    echo "👤 ${AUTHOR_LOGIN:-$AUTHOR}"
    echo "🔗 <${HTML_URL}>"
    echo "📝 \`${SHORT_SHA}\` • ${DATE}"
    echo ""
    echo "ALERT=true"
    
elif [ -z "$LAST_SHA" ]; then
    # First run - just record, don't alert
    echo "Initialized monitoring. Latest commit: ${LATEST_SHA:0:7}"
    echo "Future commits will trigger alerts."
else
    # No new commits
    echo "No new commits. Latest: ${LATEST_SHA:0:7} by ${AUTHOR_LOGIN:-$AUTHOR}"
fi

echo "[$(date -Iseconds)] Done"
