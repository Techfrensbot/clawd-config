#!/bin/bash
# Frenbot GitHub Backup Sync
# Backs up skills, scripts, memory (excluding credentials) to GitHub

set -e

GITHUB_CONFIG="$HOME/.config/github/credentials.json"
WORKSPACE="/root/clawd"
BACKUP_LOG="/root/clawd/logs/github-sync.log"

# Check if configured
if [ ! -f "$GITHUB_CONFIG" ]; then
    echo "GitHub not configured. Run setup first."
    exit 1
fi

REPO=$(jq -r '.repo // empty' "$GITHUB_CONFIG")
TOKEN=$(jq -r '.token // empty' "$GITHUB_CONFIG")

if [ -z "$REPO" ] || [ -z "$TOKEN" ]; then
    echo "GitHub repo or token not set."
    exit 1
fi

mkdir -p "$WORKSPACE/logs"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Starting GitHub sync to $REPO" >> "$BACKUP_LOG"

# Create temp directory for staging
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Clone repo (shallow)
if ! git clone --depth 1 "https://${TOKEN}@github.com/${REPO}.git" repo 2>/dev/null; then
    echo "[$DATE] Failed to clone repo" >> "$BACKUP_LOG"
    rm -rf "$TMP_DIR"
    exit 1
fi

cd repo

# Sync skills
echo "Syncing skills..."
mkdir -p skills
rsync -av --delete "$WORKSPACE/skills/" skills/ 2>/dev/null || true

# Sync scripts
echo "Syncing scripts..."
mkdir -p scripts
rsync -av --delete "$WORKSPACE/scripts/" scripts/ 2>/dev/null || true

# Sync memory (excluding sensitive files)
echo "Syncing memory..."
mkdir -p memory
rsync -av --delete --exclude='*/credentials*' --exclude='*/tokens*' --exclude='*/api_keys*' "$WORKSPACE/memory/" memory/ 2>/dev/null || true

# Sync cron configurations
echo "Syncing cron configs..."
mkdir -p cron
# Export current cron jobs to JSON
clawdbot cron list 2>/dev/null | tee cron/cron-jobs.json > /dev/null || echo "[]" > cron/cron-jobs.json

# Sync news history
echo "Syncing news history..."
mkdir -p data
rsync -av --delete "$WORKSPACE/data/" data/ 2>/dev/null || true

# Sync config files (excluding credentials)
echo "Syncing configs..."
mkdir -p config
# Copy example configs only, not actual credentials
find "$WORKSPACE" -maxdepth 1 -name "*.md" -exec cp {} config/ \; 2>/dev/null || true

# Create .gitignore
cat > .gitignore << 'EOF'
# Credentials - NEVER commit
**/credentials*
**/tokens*
**/api_keys*
**/.env
**/secrets*

# Runtime files
*.log
*.pid
*.sock

# Large files
*.mp4
*.mp3
*.wav
*.zip
*.tar.gz

# Node modules
node_modules/

# Temp files
*.tmp
.cache/
EOF

# Create sync metadata
cat > LAST_SYNC << EOF
Last sync: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Commit: $(git rev-parse HEAD 2>/dev/null || echo "initial")
Files: $(find . -type f ! -path './.git/*' | wc -l)
EOF

# Git operations
git config user.email "frenbot@techfren.net"
git config user.name "Frenbot Backup"

git add -A
git add -f .gitignore LAST_SYNC

# Check if there are changes
if git diff --cached --quiet; then
    echo "[$DATE] No changes to commit" >> "$BACKUP_LOG"
    echo "No changes to sync."
else
    git commit -m "Auto-sync: $(date -u +%Y-%m-%dT%H:%M:%SZ)

Synced:
- Skills
- Scripts  
- Memory (sanitized)
- Config templates

Excluded: Credentials, tokens, API keys"
    
    if git push origin HEAD:main 2>/dev/null || git push origin HEAD:master 2>/dev/null; then
        echo "[$DATE] Sync successful" >> "$BACKUP_LOG"
        echo "✅ Synced to GitHub: $REPO"
    else
        echo "[$DATE] Push failed" >> "$BACKUP_LOG"
        echo "❌ Failed to push"
        rm -rf "$TMP_DIR"
        exit 1
    fi
fi

# Cleanup
cd "$WORKSPACE"
rm -rf "$TMP_DIR"

echo "[$DATE] Sync complete" >> "$BACKUP_LOG"
