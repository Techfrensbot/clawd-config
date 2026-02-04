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
| **GitHub credentials** | **`~/.config/github/credentials.json`** |
| **GitHub POC deployment** | **`GITHUB_POC_DEPLOYMENT.md`** |

---

## 🧩 Recent Capability Additions

- **AI News Visual Summary**: Hourly AI News cron now generates a single visual summary image (Pollinations NanoBanana via `gen.pollinations.ai`).
- **Script**: `/root/clawd/scripts/generate-news-visual.sh`
- **API Key**: stored separately at `~/.clawdbot/credentials/pollinations/config.json` (referenced by scripts; do not inline).

---

## 🔗 GitHub Integration & Version Control

### Credentials Location
**File**: `~/.config/github/credentials.json`

```json
{
  "repo": "username/repo-name",
  "token": "ghp_xxxxxxxxxxxx",
  "setup_date": "2026-02-03T16:11:47Z"
}
```

**Usage in scripts**:
```bash
REPO=$(jq -r '.repo' ~/.config/github/credentials.json)
TOKEN=$(jq -r '.token' ~/.config/github/credentials.json)
```

**Repository**: https://github.com/Techfrensbot/clawd-config (public)

**Purpose**: Versioned configuration and documentation for Clawd AI assistant — **NO credentials stored**.

### Repo Setup (How It Was Created)

The repo was initialized **2026-02-03 at 16:11:47Z** via GitHub API/Git CLI pushes (not a local git clone). Key characteristics:

| Aspect | Details |
|--------|---------|
| **Created** | 2026-02-03 (today) by Techfrensbot account |
| **Commits** | 11 total, all authored by Techfrensbot |
| **Method** | File-by-file API uploads (no local git history) |
| **Email** | northamericaserver47@gmail.com |
| **Branch** | `main` (default) |
| **CI/CD** | None (no `.github/workflows/`) |

**Commit History:**
1. `Initial commit: Add README`
2. `Add AGENTS.md - workspace documentation`
3. `Add IDENTITY.md - owner identity and rules`
4. `Add SOUL.md - mission and persona`
5. `Add HEARTBEAT.md - status template`
6. `Add exa-plus skill - neural web search`
7. `Add mcp-search.sh - web search script`
8. `Add moltbook-engagement.sh - disabled legacy script`
9. `Add active-focus.md - task tracking`
10. `Add .gitignore - exclude credentials and secrets`
11. `Add SECURITY.md - credential safety policy`

### Current Gap: Local vs Remote

**⚠️ LOCAL WORKSPACE IS NOT A GIT REPO** — `/root/clawd` has no `.git/` directory.

| Location | Status | Key Difference |
|----------|--------|----------------|
| **GitHub Remote** | 11 files, flat structure | Docs in `docs/` subdir |
| **Local /root/clawd** | 40+ files, NOT versioned | Docs at root; more scripts/skills |

**Files in Remote but NOT Local (Different Structure):**
- `docs/AGENTS.md` (local: `/root/clawd/AGENTS.md` at root)
- `docs/HEARTBEAT.md` (local: `/root/clawd/HEARTBEAT.md` at root)
- `docs/IDENTITY.md` (local: `/root/clawd/IDENTITY.md` at root)
- `docs/SOUL.md` (local: no SOUL.md at root — exists in project context)

**Files in Local but NOT Remote:**
- `scripts/ai-news-aggregator.sh` (peas cron)
- `scripts/generate-news-visual.sh` (v3 with retries)
- `skills/video-gen/` (new skill)
- `skills/pollinations-flux/` (updated)
- `skills/short-form-video-script/` (Source Context rule)
- `skills/github-backup/`, `skills/discord-doctor/`, etc. (12 total skills locally)
- `papers/` (1,410 paper corpus)
- `memory/2026-02-03.md`, `memory/x-articles-drafts.md`, etc.

### Version Control Policy

- **ALL changes** to config files, documentation, skills, and scripts must be versioned
- Commit messages should describe the change purpose
- Use branches for experimental changes, merge via PR for review

**What's Versioned:**
- Documentation (`.md` files)
- Skill definitions and scripts (credential-free, references external creds)
- Memory templates and examples
- Scripts (read credentials from `~/.config/`, never hardcoded)

**What's NOT Versioned (Security):**
- `~/.config/*credentials.json`
- `~/.clawdbot/credentials/`
- `~/.openclaw/openclaw.json` (contains tokens)
- Any file with API keys, tokens, or secrets

**Security Files in Repo:**
- `.gitignore` — excludes credentials, secrets, `.env*`, `credentials.json`, etc.
- `SECURITY.md` — documents no-credential policy and verification steps

### Adding Files to Repo

**Option 1: GitHub API (current method)**
```bash
# Read file and encode
CONTENT=$(base64 -w 0 /root/clawd/AGENTS.md)

# Upload via API
curl -X PUT https://api.github.com/repos/Techfrensbot/clawd-config/contents/docs/AGENTS.md \
  -H "Authorization: token $(jq -r '.token' ~/.config/github/credentials.json)" \
  -H "Accept: application/vnd.github.v3+json" \
  -d "{\"message\":\"Update AGENTS.md with git findings\",\"content\":\"$CONTENT\",\"sha\":\"$(curl -s https://api.github.com/repos/Techfrensbot/clawd-config/contents/docs/AGENTS.md | jq -r '.sha')\"}"
```

**Option 2: Initialize Local Git (recommended for ongoing)**
```bash
cd /root/clawd
git init
git remote add origin https://github.com/Techfrensbot/clawd-config.git
git fetch origin
# Resolve structure differences (docs/ vs root), then:
git add .
git commit -m "Sync local workspace with remote"
git push -u origin main
```

**⚠️ Structure Decision Needed:**
- Remote uses `docs/` subdirectory for `.md` files
- Local has docs at root
- Choose one pattern before syncing to avoid duplication

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