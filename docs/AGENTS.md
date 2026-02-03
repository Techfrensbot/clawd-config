# AGENTS.md - Workspace & System Documentation

This folder is the assistant's working directory.

---

## 🧠 Core Identity

- **Owner:** `IDENTITY.md` — Tech Friend AJ @techfren (200272755520700416)
- **Mission:** Accelerate safely (`SOUL.md` + `eacc-strategic-plan.md`)
- **Model:** GLM-4.7-Flash (no override unless on-policy)

---

## 💾 Memory Layout

| File | Purpose | How to Read |
|------|---------|-------------|
| `memory/active-focus.md` | Current tasks, 15-min cadence, research queue | Always read first |
| `memory/eacc-strategic-plan.md` | Full "helpful skynet" path, phases, metrics | Reference when defining goals |
| `memory/loop-log-{DATE}.md` | Daily autonomous loop execution Log | Check for progress |
| `memory/loop-performance.json` | Success rates, cycle history, patterns | Check health |
| `memory/impl-fridge/` | Code stubs from research → `current-active.txt` | See what's buildable |
| `memory/research-cache/` | MCP search output (sources, findings) | Source material |
| `memory/safety_policy.md` | Blast-radius containment rules | Read before risky actions |
| `memory/open_loops.md` | Status tracker for stalled items | Check for attention items |

---

## 🔄 Self-Improving Loop (15-min cycles)

**What it does:**
- Runs every :15 PT (cron job "Autonomous Loop v2")
- Executes: RESEARCH → PARSE → CREATE → DEPLOY → LOG
- Learns from `loop-performance.json`, self-improves

**Key files:**
- `scripts/autonomous-loop-v2.sh` — The actual loop script
- `memory/loop-log-{DATE}.md` — Execution log with timestamps
- `memory/loop-performance.json` — Cycle stats, success rates

**Check status:**
```bash
wc -l /root/clawd/memory/loop-log-2026-01-30.md    # Cycles run
jq '.cycles[-1].status' /root/clawd/memory/loop-performance.json
```

---

## 🎯 Research Pipeline

**Rule:** For most tasks requiring real‑world knowledge, use the **exa-plus** skill first (MCP neural web search) before answering.

**Flow:**
```
exa-plus MCP search → research-cache → impl-fridge → benches → deployment
```

**exa-plus MCP tools (no API key):**
- `mcp-search.sh` — web search
- `mcp-code.sh` — code/API context
- `mcp-company.sh` — company research
- `mcp-crawl.sh` — crawl a URL
- `mcp-linkedin.sh` — LinkedIn search
- `mcp-research-start.sh` / `mcp-research-check.sh` — deep research tasks

**Usage:**
1. `scripts/mcp-search.sh SEARCH_TERM LIMIT DATE` — Get sources
2. Read `research-cache/{date}-{time}.md` — Parse findings
3. Write to `impl-fridge/{date}-{time}.md` — Create stub
4. Update `current-active.txt` — Mark deployed

**Files:**
- `skills/exa-plus/scripts/mcp-search.sh` — Neural web search
- `memory/research-cache/` — Search output storage
- `memory/impl-fridge/` — Implementation stubs

---

## 🛡️ Safety Layers

| Layer | File | Purpose |
|-------|------|---------|
| Blast radius | `memory/safety_policy.md` | Off-switches, containment |
| Code gate | `IDENTITY.md` § Owner Rules | Never edit `~/.clawdbot/clawdbot.json` without approval |
| Execution | `HEARTBEAT.md` | Only update mem files unless user asked |

---

## 📅 Daily Workflow

**For AJ (owner):**
1. `read /root/clawd/HEARTBEAT.md` — Check what needs attention
2. `read /root/clawd/memory/active-focus.md` — See current tasks
3. `read /root/clawd/memory/loop-log-{TODAY}.md` — Check autonomous progress
4. Keep `memory/YYYY-MM-DD.md` synced (daily log)

**For the assistant (loop execution):**
- Use `memory/active-focus.md` as the single source of truth for tasks
- Update only the files listed in `HEARTBEAT.md` on each cycle
- Never change high-level docs (IDENTITY, SOUL, roadmap) without approval

---

## 🔗 Reference Index

| Area | Key Doc |
|------|---------|
| Mission & alignment | `SOUL.md` |
| Full path to helpful skynet | `memory/eacc-strategic-plan.md` |
| Capabilities goals | `roadmap.md` |
| Owner rules | `IDENTITY.md` |
| Status check | `HEARTBEAT.md` |
| Current tasks | `memory/active-focus.md` |
| Loop execution log | `memory/loop-log-{DATE}.md` |
| Health metrics | `memory/loop-performance.json` |
| Open loop tracker | `memory/open_loops.md` |

---

## 🧩 Recent Capability Additions

- **AI News Visual Summary**: Hourly AI News cron now generates a single visual summary image (Pollinations NanoBanana via `gen.pollinations.ai`).
- **Script**: `/root/clawd/scripts/generate-news-visual.sh`
- **API Key**: stored separately at `~/.clawdbot/credentials/pollinations/config.json` (referenced by scripts; do not inline).

---

## 📊 Quick Status Commands

```bash
# Current tasks
cat /root/clawd/memory/active-focus.md

# Recent loop activity
tail -20 /root/clawd/memory/loop-log-2026-01-30.md

# Success rate
jq '.cycles | length' /root/clawd/memory/loop-performance.json

# Deployed impls
ls -lt /root/clawd/memory/impl-fridge/*.md | head -5

# Research output (today)
find /root/clawd/memory/research-cache -name "r-2026-01-30-*.md" -exec bat -n --wrap none {} \;

# Trigger loop (manual)
bash /root/clawd/scripts/autonomous-loop-v2.sh

# List cron jobs
clawdbot cron list
```

---

## 🚀 Updates (Owner Only)

- Never edit `/root/.clawdbot/clawdbot.json` without approval
- Before changing the mission, duplicate/sync to `memory/backup-{DATE}.md`

---

## 📝 Memory Journal

Keep daily context in `memory/YYYY-MM-DD.md`:
- Decisions made
- Lessons from failed runs
- Preferences discovered
- Relevant snippets from research

---

**Last updated:** 2026-01-30
**Next review:** When autonomous loop has 50+ cycles or <80% success rate