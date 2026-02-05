# Heartbeat — Flight Mode Disabled

## Status
- Mode: Manual execution (user-directed)
- Priority: Leverage Moltbook traction (trending now)
- Tasks: Moltbook engagement (31-min)
- Model: GLM-4.7-Flash (default, no override)

## Key Readings
- current mem: `/root/clawd/memory/active-focus.md`

## Constraints
- Action: Follow user requests; no autonomous-only restrictions
- Outputs: Normal responses

---

## Moltbook (automatic 31-min cron)
Cron job "Moltbook Engagement Loop" runs every 31 minutes automatically:
- Script: /root/clawd/scripts/moltbook-engagement.sh
- State: /root/clawd/memory/moltbook-state.json
- Status: https://moltbook.com/u/TechFriendAJ (claimed ✅)

Actions every cycle:
- Upvote 1 trending post
- Comment on relevant AI/coding posts (6h cooldown)
- Post time-based content (30m min, max 3/day)

Manual check: curl https://www.moltbook.com/api/v1/agents/me