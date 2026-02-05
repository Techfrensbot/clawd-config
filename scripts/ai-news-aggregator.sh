#!/bin/bash
# AI News Aggregator - Combined OpenAI, Anthropic, and Codex monitoring
# Single cron to reduce concurrency load

set -e

PEASANTRY="<@931708065319907338>"
OUTPUT=""
ALERT=false

# ============================================
# 1. OPENAI NEWS CHECK (RSS-based)
# ============================================
OPENAI_STATE="/root/clawd/memory/openai-news-monitor.json"
OPENAI_URL="https://openai.com/news"

if [ ! -f "$OPENAI_STATE" ]; then
    echo '{"last_hash": null, "last_article": null, "check_count": 0}' > "$OPENAI_STATE"
fi

RSS_CONTENT=$(curl -s -L --max-time 15 "https://openai.com/news/rss.xml" -H "User-Agent: Mozilla/5.0" 2>/dev/null || echo "")

if [ -n "$RSS_CONTENT" ]; then
    ARTICLE_TITLE=$(echo "$RSS_CONTENT" | grep -oP '<title><!\[CDATA\[\K[^\]]+' | sed -n '2p')
    ARTICLE_DATE=$(echo "$RSS_CONTENT" | grep -oP '<pubDate>\K[^<]+' | head -1)
    ARTICLE_LINK=$(echo "$RSS_CONTENT" | grep -oP '<link>\K[^<]+' | sed -n '2p')
    CURRENT_HASH=$(echo "${ARTICLE_TITLE}${ARTICLE_DATE}" | md5sum | cut -d' ' -f1)
    LAST_HASH=$(jq -r '.last_hash' "$OPENAI_STATE")
    
    if [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
        LAST_ARTICLE=$(jq -r '.last_article' "$OPENAI_STATE")
        if [ "$ARTICLE_TITLE" != "$LAST_ARTICLE" ] && [ -n "$ARTICLE_TITLE" ]; then
            jq --arg hash "$CURRENT_HASH" --arg article "$ARTICLE_TITLE" --arg date "$ARTICLE_DATE" --arg link "$ARTICLE_LINK" \
               '.last_hash = $hash | .last_article = $article | .last_date = $date | .last_link = $link' "$OPENAI_STATE" > "$OPENAI_STATE.tmp" && mv "$OPENAI_STATE.tmp" "$OPENAI_STATE"
            OUTPUT+="🟢 **OpenAI News**\n"
            OUTPUT+="📰 ${ARTICLE_TITLE}\n"
            OUTPUT+="📅 ${ARTICLE_DATE}\n"
            OUTPUT+="🔗 ${ARTICLE_LINK}\n\n"
            ALERT=true
        else
            jq --arg hash "$CURRENT_HASH" '.last_hash = $hash | .warning = "Hash changed but no new article"' "$OPENAI_STATE" > "$OPENAI_STATE.tmp" && mv "$OPENAI_STATE.tmp" "$OPENAI_STATE"
            OUTPUT+="⚠️ **OpenAI**: Detection failure (hash changed, no article found)\n\n"
            ALERT=true
        fi
    else
        OUTPUT+="🟡 OpenAI: No new content\n"
    fi
else
    OUTPUT+="🔴 OpenAI: RSS fetch failed\n"
fi

# ============================================
# 2. ANTHROPIC NEWS CHECK (HTML scrape + hash)
# ============================================
ANTHROPIC_STATE="/root/clawd/memory/anthropic-news-monitor.json"
ANTHROPIC_URL="https://www.anthropic.com/news"

if [ ! -f "$ANTHROPIC_STATE" ]; then
    echo '{"last_hash": null, "last_article": null}' > "$ANTHROPIC_STATE"
fi

ANTHROPIC_HTML=$(curl -s --max-time 15 "$ANTHROPIC_URL" -H "User-Agent: Mozilla/5.0" 2>/dev/null || echo "")

if [ -n "$ANTHROPIC_HTML" ]; then
    FEATURED_SECTION=$(echo "$ANTHROPIC_HTML" | grep -oP 'FeaturedGridModule[^>]*>.*?(?=<section|$)' | head -1)
    FEATURED_HASH=$(echo "$FEATURED_SECTION" | md5sum | cut -d' ' -f1)
    LAST_HASH=$(jq -r '.last_hash' "$ANTHROPIC_STATE")
    
    if [ "$FEATURED_HASH" != "$LAST_HASH" ]; then
        ARTICLE_TITLE=$(echo "$FEATURED_SECTION" | grep -oP '<h2[^>]*>\K[^<]+' | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        ARTICLE_DATE=$(echo "$FEATURED_SECTION" | grep -oP '<time[^>]*>\K[^<]+' | head -1)
        LAST_ARTICLE=$(jq -r '.last_article' "$ANTHROPIC_STATE")
        
        if [ "$ARTICLE_TITLE" != "$LAST_ARTICLE" ] && [ -n "$ARTICLE_TITLE" ]; then
            jq --arg hash "$FEATURED_HASH" --arg article "$ARTICLE_TITLE" --arg date "$ARTICLE_DATE" \
               '.last_hash = $hash | .last_article = $article | .last_date = $date' "$ANTHROPIC_STATE" > "$ANTHROPIC_STATE.tmp" && mv "$ANTHROPIC_STATE.tmp" "$ANTHROPIC_STATE"
            OUTPUT+="🟢 **Anthropic News**\n"
            OUTPUT+="📰 ${ARTICLE_TITLE}\n"
            OUTPUT+="📅 ${ARTICLE_DATE}\n"
            OUTPUT+="🔗 ${ANTHROPIC_URL}\n\n"
            ALERT=true
        else
            FALSE_NEGS=$(jq '.false_negatives // 0' "$ANTHROPIC_STATE")
            NEW_FALSE_NEGS=$((FALSE_NEGS + 1))
            jq --arg hash "$FEATURED_HASH" --arg count "$NEW_FALSE_NEGS" \
               '.last_hash = $hash | .false_negatives = ($count | tonumber) | .warning = "DETECTION FAILURE - manual review needed"' "$ANTHROPIC_STATE" > "$ANTHROPIC_STATE.tmp" && mv "$ANTHROPIC_STATE.tmp" "$ANTHROPIC_STATE"
            OUTPUT+="⚠️ **Anthropic**: Detection failure (hash changed, no article found)\n\n"
            ALERT=true
        fi
    else
        OUTPUT+="🟡 Anthropic: No new content\n"
    fi
else
    OUTPUT+="🔴 Anthropic: HTML fetch failed\n"
fi

# ============================================
# 3. GITHUB CODEX COMMITS CHECK
# ============================================
CODEX_STATE="/root/clawd/memory/codex-commits-monitor.json"
REPO="openai/codex"

if [ ! -f "$CODEX_STATE" ]; then
    echo '{"last_sha": null, "last_check": null}' > "$CODEX_STATE"
fi

COMMITS_JSON=$(curl -s --max-time 15 "https://api.github.com/repos/${REPO}/commits?per_page=5" -H "Accept: application/vnd.github.v3+json" 2>/dev/null || echo "")

if [ -n "$COMMITS_JSON" ] && [ "$(echo "$COMMITS_JSON" | jq -r 'type' 2>/dev/null)" == "array" ]; then
    LATEST_SHA=$(echo "$COMMITS_JSON" | jq -r '.[0].sha')
    LAST_SHA=$(jq -r '.last_sha' "$CODEX_STATE")
    
    if [ "$LATEST_SHA" != "$NULL" ] && [ "$LATEST_SHA" != "$LAST_SHA" ]; then
        COMMIT_MSG=$(echo "$COMMITS_JSON" | jq -r '.[0].commit.message' | head -1)
        COMMIT_AUTHOR=$(echo "$COMMITS_JSON" | jq -r '.[0].commit.author.name')
        COMMIT_DATE=$(echo "$COMMITS_JSON" | jq -r '.[0].commit.author.date')
        COMMIT_URL=$(echo "$COMMITS_JSON" | jq -r '.[0].html_url')
        
        jq --arg sha "$LATEST_SHA" --arg date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
           '.last_sha = $sha | .last_check = $date' "$CODEX_STATE" > "$CODEX_STATE.tmp" && mv "$CODEX_STATE.tmp" "$CODEX_STATE"
        
        OUTPUT+="🟢 **Codex Commit**\n"
        OUTPUT+="📝 ${COMMIT_MSG}\n"
        OUTPUT+="👤 ${COMMIT_AUTHOR}\n"
        OUTPUT+="📅 ${COMMIT_DATE}\n"
        OUTPUT+="🔗 ${COMMIT_URL}\n\n"
        ALERT=true
    else
        OUTPUT+="🟡 Codex: No new commits\n"
    fi
else
    OUTPUT+="🔴 Codex: API fetch failed\n"
fi

# ============================================
# 4. GITHUB ISSUES CHECK (feature requests) - Every 30 min only
# ============================================
ISSUES_STATE="/root/clawd/memory/codex-issues-monitor.json"

if [ ! -f "$ISSUES_STATE" ]; then
    echo '{"last_issue_id": null, "reported_issues": [], "check_count": 0}' > "$ISSUES_STATE"
fi

# Only check issues every 3rd run (30 min interval)
ISSUES_CHECK_COUNT=$(jq '.check_count // 0' "$ISSUES_STATE")
ISSUES_NEW_COUNT=$((ISSUES_CHECK_COUNT + 1))
jq --arg count "$ISSUES_NEW_COUNT" '.check_count = ($count | tonumber)' "$ISSUES_STATE" > "$ISSUES_STATE.tmp" && mv "$ISSUES_STATE.tmp" "$ISSUES_STATE"

if [ $((ISSUES_NEW_COUNT % 3)) -eq 0 ]; then
    ISSUES_RESPONSE=$(curl -s --max-time 15 "https://api.github.com/repos/openai/codex/issues?state=open&labels=feature%20request,enhancement&sort=created&direction=desc&per_page=10" -H "Accept: application/vnd.github.v3+json" -w "\n%{http_code}" 2>/dev/null || echo "\n000")
    ISSUES_JSON=$(echo "$ISSUES_RESPONSE" | sed '$d')
    ISSUES_STATUS=$(echo "$ISSUES_RESPONSE" | tail -n1)

    if [ -n "$ISSUES_JSON" ] && [ "$(echo "$ISSUES_JSON" | jq -r 'type' 2>/dev/null)" == "array" ]; then
        LAST_ISSUE_ID=$(jq -r '.last_issue_id // empty' "$ISSUES_STATE")
        NEW_ISSUES=$(echo "$ISSUES_JSON" | jq --arg last "$LAST_ISSUE_ID" '[.[] | select(.id != ($last | tonumber? // 0))]')
        NEW_COUNT=$(echo "$NEW_ISSUES" | jq 'length')
        
        if [ "$NEW_COUNT" -gt 0 ] && [ "$NEW_COUNT" -lt 10 ]; then
            LATEST_ID=$(echo "$NEW_ISSUES" | jq -r '.[0].id')
            jq --arg id "$LATEST_ID" '.last_issue_id = ($id | tonumber)' "$ISSUES_STATE" > "$ISSUES_STATE.tmp" && mv "$ISSUES_STATE.tmp" "$ISSUES_STATE"
            
            OUTPUT+="🟢 **New Codex Issues** (${NEW_COUNT})\n"
            echo "$NEW_ISSUES" | jq -r '.[] | "• #\(.number): \(.title) by @\(.user.login)"' | while read line; do
                OUTPUT+="${line}\n"
            done
            OUTPUT+="🔗 https://github.com/openai/codex/issues\n\n"
            ALERT=true
        else
            OUTPUT+="🟡 Codex Issues: No new feature requests\n"
        fi
    else
        if [ "$ISSUES_STATUS" = "000" ]; then
            OUTPUT+="🔴 Codex Issues: Network timeout\n"
        elif [ "$ISSUES_STATUS" = "403" ]; then
            OUTPUT+="🔴 Codex Issues: Rate limited (403)\n"
        elif [ "$ISSUES_STATUS" = "404" ]; then
            OUTPUT+="🔴 Codex Issues: Not found (404)\n"
        else
            OUTPUT+="🔴 Codex Issues: API error (HTTP ${ISSUES_STATUS})\n"
        fi
    fi
else
    OUTPUT+="⏸️ Codex Issues: Skipped (next check in ~20 min)\n"
fi

# ============================================
# OUTPUT RESULTS
# ============================================
if [ "$ALERT" = true ]; then
    echo -e "${PEASANTRY} 🚨 AI News Update\n\n${OUTPUT}"
    echo "ALERT=true"
else
    echo "No updates - all sources checked"
    echo -e "$OUTPUT"
fi
