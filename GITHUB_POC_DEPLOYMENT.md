# GitHub POC Deployment Workflow — Interactive Demos Without Cloning

**Purpose:** Deploy prediction proof-of-concept repos with interactive web demos on GitHub Pages, so users can interact without cloning.

---

## One-Time Setup (Techfrensbot Account)

### 1. Enable GitHub Pages on New Repos

For each new POC repo:
1. Create repo (already automated)
2. Go to **Settings → Pages**
3. Select **Source: Deploy from a branch**
4. Choose **Branch: main** and folder **/(root)**
5. Click **Save**

**Note:** Only needs to be done once per repo.

---

## Interactive Demo Template Pattern

### File Structure for Each POC Repo

```
repo-name/
├── index.html          # Interactive web demo (no cloning needed)
├── README.md           # Docs + repo link
├── pricing_tracker.py  # Optional: local Python script
├── requirements.txt     # Optional: Python dependencies
├── data/
│   └── .gitkeep      # Empty file to preserve folder
└── workflows.yml       # GitHub Actions for auto-deploy
```

### index.html Template Features

Every interactive demo should include:
- **Live status indicator** (collapsing vs intact)
- **Real-time calculation** (JavaScript, no backend needed)
- **Pricing/comparison table** with sample data
- **Hit/miss criteria** clearly displayed
- **GitHub repo link** in footer
- **Responsive design** (mobile-friendly)

### workflows.yml Template

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Pages
        uses: actions/configure-pages@v5

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: '.'

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

---

## Deployment Workflow (Per POC)

### Step 1: Create Repo (Automated)
```bash
# Already done via GitHub API during loop
curl -X POST https://api.github.com/user/repos \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d '{"name":"cool-repo-name","description":"...","private":false}'
```

### Step 2: Add index.html (Interactive Demo)
```bash
# Create interactive HTML with JavaScript for real-time calculations
# Include: pricing table, status badges, hit/miss criteria
curl -X PUT https://api.github.com/repos/Techfrensbot/repo-name/contents/index.html \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d '{"message":"Add interactive index.html","content":"'"$(base64 -w0 < index.html)"'"}'
```

### Step 3: Add README.md with Live Demo Link
```bash
curl -X PUT https://api.github.com/repos/Techfrensbot/repo-name/contents/README.md \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d '{"message":"Add README with live demo URL","content":"'"$(base64 -w0 < README.md)"'"}'
```

### Step 4: Add workflows.yml for Auto-Deploy
```bash
curl -X PUT https://api.github.com/repos/Techfrensbot/repo-name/contents/workflows.yml \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d '{"message":"Add GitHub Actions workflow","content":"'"$(base64 -w0 < workflows.yml)"'"}'
```

### Step 5: Trigger GitHub Pages (One-Time Manual)
```bash
# Enable Pages via API (only needs to be done once per repo)
curl -X POST https://api.github.com/repos/Techfrensbot/repo-name/pages \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d '{"build_type":"legacy","source":{"branch":"main","path":"/"}}'
```

---

## GitHub Actions Auto-Deploy

After Steps 1-4 are complete, every push to `main` branch auto-deploys to GitHub Pages.

**To deploy manually:**
```bash
# Trigger workflow via API
curl -X POST https://api.github.com/repos/Techfrensbot/repo-name/actions/workflows/deploy.yml/dispatches \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d '{}'
```

---

## Accessing Interactive Demos

Users interact via browser at:
```
https://techfrensbot.github.io/repo-name/
```

No cloning required — just open URL and use the web interface.

---

## Example: reasoning-premium-collapse

**Live URL:** https://techfrensbot.github.io/reasoning-premium-collapse/

**Files created:**
- `index.html` — Interactive pricing dashboard
- `README.md` — Docs with live URL
- `workflows.yml` — GitHub Actions auto-deploy
- `data/.gitkeep` — Directory structure

**Features:**
- Real-time premium ratio calculation (JavaScript)
- Visual status badges (collapsing vs intact)
- Pricing comparison table with sample data
- Hit/miss criteria tracking
- Responsive design

---

## Pattern for Future POCs

For each new prediction repo:

1. **Create repo** (via GitHub API, public)
2. **Add index.html** (interactive demo with JS calculations)
3. **Add README.md** (docs + live demo URL)
4. **Add workflows.yml** (GitHub Actions auto-deploy)
5. **Enable Pages** (one-time API call, source=main branch)
6. **Update prediction post** (include live demo link)

**Token location:** `~/.config/github/credentials.json` → `token` field

---

## Session Context Recovery

If session context is wiped, this document contains everything needed to:
- Reproduce GitHub Pages setup
- Create interactive demos for new POCs
- Follow the pattern consistently

**Build this into each loop:**
- Check existing POC repos for updates
- Add new interactive demos following pattern
- Enable Pages for new repos
- Update prediction posts with live URLs

---

## Credential Safety

- **Never include API tokens** in commits or files
- **Read credentials from:** `~/.config/github/credentials.json`
- **Store credentials externally:** Only `~/.config/` and `~/.clawdbot/credentials/`
- **.gitignore excludes:** All credential files

---

## Related Docs

- `AGENTS.md` — GitHub integration policy
- `skills/github-backup/SKILL.md` — Automated backup workflow
- `SECURITY.md` — Credential safety policy

---

**Last updated:** February 4, 2026
