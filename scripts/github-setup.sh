#!/bin/bash
# GitHub Backup Setup
# Run this after receiving token from Sai

set -e

echo "🔧 Frenbot GitHub Backup Setup"
echo "==============================="
echo ""

read -p "GitHub repo (format: username/repo-name): " REPO
read -sp "GitHub token: " TOKEN
echo ""

CONFIG_FILE="$HOME/.config/github/credentials.json"

# Save config
cat > "$CONFIG_FILE" << EOF
{
  "repo": "${REPO}",
  "token": "${TOKEN}",
  "setup_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

chmod 600 "$CONFIG_FILE"

echo "✅ Config saved to $CONFIG_FILE"
echo ""

# Test connection
echo "🔄 Testing GitHub connection..."
if curl -s -H "Authorization: token ${TOKEN}" "https://api.github.com/repos/${REPO}" | grep -q '"id"'; then
    echo "✅ Connected to GitHub repo: $REPO"
else
    echo "❌ Failed to connect. Check repo name and token."
    exit 1
fi

echo ""
echo "🚀 Setup complete! You can now:"
echo "   1. Run manual sync: bash /root/clawd/scripts/github-sync.sh"
echo "   2. Add to cron for auto-sync"
echo ""
echo "📋 What gets backed up:"
echo "   ✅ Skills"
echo "   ✅ Scripts"
echo "   ✅ Memory (sanitized)"
echo "   ✅ Config templates"
echo ""
echo "🚫 What gets excluded:"
echo "   ❌ Credentials, tokens, API keys"
echo "   ❌ Log files"
echo "   ❌ Large media files"
