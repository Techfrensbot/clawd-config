---
name: github-backup
description: Automated GitHub backup for frenbot skills, scripts, and memory
author: Sai_revanth_12 (community contribution)
---

# GitHub Backup Skill

Automatically backs up frenbot's skills, scripts, and memory to GitHub for disaster recovery.

## Setup

### 1. Create GitHub Token
- Go to https://github.com/settings/tokens
- Generate new token with `repo` scope
- Copy the token (keep it safe!)

### 2. Create Repository
- Create a new repo (public or private)
- Note the format: `username/repo-name`

### 3. Run Setup
```bash
bash /root/clawd/scripts/github-setup.sh
# Enter repo name and token when prompted
```

### 4. Test Sync
```bash
bash /root/clawd/scripts/github-sync.sh
```

## Auto-Sync Options

### Option A: Cron Job (Recommended)
Add to crontab for daily backups:
```bash
0 2 * * * /root/clawd/scripts/github-sync.sh >> /root/clawd/logs/github-sync.log 2>&1
```

### Option B: Post-Change Hook
Add to skill creation/editing workflow to sync after changes.

## What's Backed Up

| Directory | Contents | Exclusions |
|-----------|----------|------------|
| `skills/` | All skill files | None |
| `scripts/` | Utility scripts | None |
| `memory/` | Memory files | Credentials, tokens |
| `cron/` | Cron job configurations | None |
| `data/` | News history, tracking files | Credentials |
| `config/` | Config templates | Actual credentials |

## What's Excluded

- All credential files (`*credentials*`, `*tokens*`, `*api_keys*`)
- Environment files (`.env`)
- Log files (`*.log`)
- Large media files (`*.mp4`, `*.mp3`)
- Node modules

## Recovery

If frenbot needs to be "revived":

```bash
# Clone the backup repo
git clone https://github.com/USERNAME/REPO.git frenbot-recovery

# Restore skills
cp -r frenbot-recovery/skills/* /root/clawd/skills/

# Restore scripts
cp -r frenbot-recovery/scripts/* /root/clawd/scripts/

# Restore memory (sanitized)
cp -r frenbot-recovery/memory/* /root/clawd/memory/

# Reconfigure credentials manually
```

## Security

- Token stored with 600 permissions (owner-only)
- Credentials never committed to Git
- `.gitignore` auto-generated to exclude sensitive files
- Memory files are sanitized before sync

## Logs

Backup logs: `/root/clawd/logs/github-sync.log`

## Manual Sync

```bash
bash /root/clawd/scripts/github-sync.sh
```
