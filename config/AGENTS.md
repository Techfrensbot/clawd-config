# AGENTS.md - Workspace & System Documentation

This folder is the assistant's working directory.

---

## 🧠 Core Identity

- **Owner:** `IDENTITY.md` — Tech Friend AJ @techfren (200272755520700416)
- **Mission:** Accelerate safely (`SOUL.md` + `memory/eacc-strategic-plan.md`)
- **Model:** GLM-4.7-Flash (no override unless on-policy)

---

## 💾 Memory Layout

| File | Purpose |
|------|---------|
| `memory/active-focus.md` | Current tasks, 15-min cadence, research queue |
| `memory/eacc-strategic-plan.md` | Full "helpful skynet" path, phases, metrics |
| `memory/safety_policy.md` | Blast-radius containment rules |
| `memory/research-cache/` | MCP search output (sources, findings) |
| `memory/impl-fridge/` | Code stubs from research → deployment candidates |

---

## 🎯 Research Pipeline

**Rule:** For real‑world knowledge tasks, use **exa-plus** skill (MCP neural web search).

**Flow:** `exa-plus MCP search` → `research-cache` → `impl-fridge` → `deployment`

**Tools** (`skills/exa-plus/scripts/`):
- `mcp-search.sh` — web search
- `mcp-code.sh` — code/API context
- `mcp-company.sh` — company research
- `mcp-crawl.sh` — crawl a URL

---

## 🛡️ Safety Layers

| Layer | File | Purpose |
|-------|------|---------|
| Blast radius | `memory/safety_policy.md` | Off-switches, containment |
| Code gate | `IDENTITY.md` § Owner Rules | Never edit `~/.clawdbot/clawdbot.json` without approval |
| Execution | `HEARTBEAT.md` | Only update mem files unless user asked |

---

## 📅 Daily Workflow

**For AJ:**
1. `read /root/clawd/HEARTBEAT.md` — Check what needs attention
2. `read /root/clawd/memory/active-focus.md` — See current tasks
3. Keep `memory/YYYY-MM-DD.md` synced (daily log)

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
| **GitHub credentials** | `~/.config/github/credentials.json` |

---

## 🎨 Pollinations AI (Image Generation)

**Script:** `/root/clawd/scripts/generate-news-visual.sh`

**Usage:**
```bash
bash /root/clawd/scripts/generate-news-visual.sh "Text prompt" /output/path
```

**Returns:** `MEDIA: /path/to/image.png` (or JPEG)

**API Key:** Stored at `~/.clawdbot/credentials/pollinations/config.json`

**Docs:** https://pollinations.ai

---

## 🔗 GitHub Integration & Version Control

### Credentials
**File:** `~/.config/github/credentials.json`

```bash
REPO=$(jq -r '.repo' ~/.config/github/credentials.json)
TOKEN=$(jq -r '.token' ~/.config/github/credentials.json)
```

### Repositories
- **Techfrensbot/clawd-config** — Documentation & config (no credentials)
- **Techfrensbot/reasoning-premium-collapse** — Example repo with working prototype

### GitHub Pages (Auto-Deployed)
- **URL Pattern:** `https://<username>.github.io/<repo-name>/`
- **Auto-enables:** When repo has `README.md` at root
- **Example:** https://techfrensbot.github.io/reasoning-premium-collapse/

### Version Control Policy
- **Versioned:** Docs, skills, scripts (credential-free only)
- **Not Versioned:** Credentials, secrets, API keys
- **Git Repo:** Local workspace is NOT a git repo; use API for file uploads

---

**Last updated:** 2026-02-05
