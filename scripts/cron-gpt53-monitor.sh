#!/bin/bash
# GPT-5.3 Page Monitor - Wrapper for cron

OUTPUT=$(bash /root/clawd/scripts/url-status-monitor.sh "https://openai.com/index/introducing-gpt-5-3" 200)

if echo "$OUTPUT" | grep -q "ALERT=true"; then
    # Send to #frenbot via Discord
    curl -s -X POST "${GATEWAY_URL}/api/v1/message" \
        -H "Authorization: Bearer ${GATEWAY_TOKEN}" \
        -H "Content-Type: application/json" \
        -d '{
            "action": "send",
            "channel": "discord",
            "target": "frenbot",
            "message": "'"$(echo "$OUTPUT" | head -6 | sed 's/"/\\"/g')"'"
        }'
fi
