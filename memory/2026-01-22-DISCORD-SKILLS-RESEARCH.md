# Discord Skills Research Report

## 📁 Skills Installed & Analyzed

### 1. Discord Skill (v1.0.1)
**Purpose:** Full Discord channel control and automation via `discord` tool
**Description:** Send messages, react, post/upload stickers, upload emojis, run polls, manage threads/pins/search, fetch permissions or member/role/channel info, handle moderation actions

**Core Capabilities:**

#### 🎯 Message Management
- **Send messages** to channels or users (DMs)
- **Edit messages** to fix typos or update content
- **Delete messages** for moderation
- **React to messages** with any emoji
- **List reactions** + users who reacted
- **Read recent messages** with message context for threading

#### 🏷 Media Management
- **Upload custom emojis** (PNG/JPG/GIF, max 256KB)
- **Upload stickers** (PNG/APNG/Lottie JSON, max 512KB)
- **Send media** attachments with messages (audio, images, files)
- **Supports local files** (`file:///path`) and remote URLs

#### 📊 Polls & Engagement
- **Create polls** with questions and 2-10 answers
- **Multi-select polls** option
- **Poll duration** up to 32 days (768 hours)
- **Content fields** for additional poll context

#### 🧵 Threads & Organization
- **Create threads** from existing messages
- **Reply in threads**
- **List threads** for channel management
- **Thread metadata** and organization

#### 📌 Pins & Search
- **Pin/unpin messages** for important content
- **List pinned items** for quick access
- **Search messages** across channels with filters
- **Guild-wide search** with content, channel IDs, limits

#### 👥 Member & Role Management
- **Member info** lookup by user ID
- **Role info** retrieval
- **Check permissions** for specific channels
- **Channel info** retrieval
- **Voice status** checking

#### 🔒 Moderation (Disabled by Default)
- **Timeout users** (minutes)
- **Kick/ban users** (disabled by default, can be enabled via discord.actions.*)
- Requires action gating to enable moderation actions

#### 📅 Events & Scheduling
- **List scheduled events**
- **Create events** (likely capability based on Discord features)
- **Guild-wide event** management

#### 🔐 Action Gating & Security
- **Fine-grained control** of which actions are enabled
- **Disable action groups:** moderation, roles, permissions, messages, threads, pins, search, emoji/sticker uploads, etc.
- **Security-first design** - dangerous actions require explicit enabling

**Key Benefits for Tech Friend Community:**
1. **Automated moderation** - React with ✅/⚠️ to mark issues
2. **Quick polls** - Release decisions, meeting times, feature voting
3. **Welcome automation** - Auto-react or DM users when they join
4. **Stickers/emojis** - Community branding and celebration moments
5. **Thread organization** - Bug triage, discussion channels, project channels
6. **Searchable history** - Find past conversations, decisions, documentation

---

### 2. Discord Doctor Skill (v1.0.0)
**Purpose:** Quick diagnosis and repair for Discord bot, Gateway, OAuth token, and legacy config issues
**Description:** Checks connectivity, token expiration, and cleans up old Clawdis artifacts

**Core Capabilities:**

#### 🔍 Diagnostic Checks
1. **Discord App** - Is Discord desktop app running (optional monitoring)
2. **Gateway Process** - Is Clawdbot gateway daemon running
3. **Gateway HTTP** - Is gateway responding on port 18789
4. **Discord Connection** - Is bot actually connected to Discord
5. **Anthropic OAuth** - Is your OAuth token valid or expired
6. **Legacy Clawdis** - Detects old Clawdis launchd services/configs
7. **Recent Activity** - Shows recent Discord sessions and latency

#### 🔧 Auto-Fix Capabilities
**When run with `--fix` flag:**
- **Start gateway** if not running
- **Install missing npm packages** (discord.js, strip-ansi, etc.)
- **Restart gateway** after fixing dependencies
- **Remove legacy launchd service** (`com.clawdis.gateway.plist`)
- **Backup legacy config** (moves `~/.clawdis` to `~/.clawdis-backup`)
- **Auto-reconnect** to Discord if disconnected

#### 🐛 Common Issues & Solutions

| Issue | Auto-Fix Action | Manual Solution |
|-------|-----------------|-----------------|
| Gateway not running | Starts gateway on port 18789 | `clawdbot daemon start` |
| Missing npm packages | Runs `npm install` | Manually install dependencies |
| Discord disconnected | Restarts gateway to reconnect | Check bot token/internet |
| OAuth token expired | Shows instructions to re-authenticate | `clawdbot configure` → "Anthropic OAuth" |
| Legacy launchd service | Removes old `.plist` file | Delete manually if needed |
| Legacy config dir | Moves to backup | `mv ~/.clawdis ~/.clawdis-backup` |

#### 🔐 OAuth Token Management
**Automatic detection:**
- **Token expiration** warnings
- **Invalid token** alerts
- **Re-authentication** instructions

**Manual re-auth:**
```bash
cd ~/Clawdis && npx clawdbot configure
```
Then select "Anthropic OAuth (Claude Pro/Max)" to re-authenticate.

#### 🧹 Legacy Clawdis Migration
**Issues addressed:**
- **Old launchd service** conflicts with new gateway daemon
- **Legacy config directory** (~/.clawdis) causes OAuth token conflicts
- **Automatic backup** preserves old configs before removal

**Symptoms of legacy issues:**
- Gateway won't start
- OAuth tokens don't work
- Multiple daemon processes fighting for port 18789
- Unexpected disconnects

#### 📊 Activity Monitoring
**Shows:**
- Recent Discord sessions
- Connection latency
- Uptime statistics
- Last activity timestamps

**Example Output:**
```
Discord Doctor
Checking Discord and Gateway health...

1. Discord App
   Running (6 processes)

2. Gateway Process
   Running (PID: 66156, uptime: 07:45)

3. Gateway HTTP
   Responding on port 18789

4. Discord Connection
   Discord: ok (@Clawdis) (321ms)

5. Anthropic OAuth
   Valid (expires in 0h 45m)

6. Legacy Clawdis
   No legacy launchd service
   No legacy config directory

7. Recent Discord Activity
   - discord:group:123456789012345678 (21h ago)

Summary
All checks passed! Discord is healthy.
```

---

## 🎯 Combined Use Cases for Tech Friend Community

### Daily Operations
1. **Morning Rollups** - `discord search` → compile → send daily digest
2. **Priority Checks** - Create poll for team priorities
3. **Moderation Queue** - React with ⚠️ on flagged content
4. **Welcome New Members** - Auto DM with community rules
5. **Sticker Celebrations** - Deploy completion stickers in #deployments

### Administrative Tasks
1. **Health Monitoring** - Run `discord-doctor` if issues arise
2. **Token Management** - Check OAuth expiration weekly
3. **Legacy Cleanup** - Run `discord-doctor --fix` after updates
4. **Performance Audit** - Check connection latency with activity monitoring
5. **Backup Verifications** - Ensure legacy configs backed up

### Community Building
1. **Emoji/Sticker Contests** - Collect entries, upload winners
2. **Feature Voting** - Polls for new community features
3. **Event Planning** - Polls for meeting times, topics
4. **Knowledge Base** - Pin important decisions/docs
5. **Help Desk** - Threaded bug reports with status tracking

### Automation Opportunities
1. **Auto-moderation** - React to keywords with appropriate emojis
2. **Scheduled Announcements** - Daily/weekly automated messages
3. **Thread Organization** - Auto-create threads from certain topics
4. **Member Onboarding** - DM sequence of helpful resources
5. **Issue Tracking** - Pin thread, react to track status

---

## 🔐 Security Considerations

### Discord Skill Security
- **Action gating** prevents accidental moderation
- **Media size limits** prevent DoS
- **Permission checks** before sensitive actions
- **No default moderation** - must be explicitly enabled

### Discord Doctor Security
- **Token validation** prevents expired auth issues
- **Legacy detection** prevents conflicts
- **Backup before cleanup** prevents data loss
- **Connection monitoring** detects anomalies

---

## 💡 Recommendations

### Immediate Actions
1. **Install discord skill** ✅ (DONE)
2. **Install discord-doctor skill** ✅ (DONE)
3. **Run `discord-doctor`** to verify gateway health
4. **Test basic actions** (react, send message) to verify permissions
5. **Configure action gating** for moderation if needed

### Future Enhancements
1. **Create automation scripts** for daily rollups, welcome messages
2. **Set up scheduled polls** for recurring community decisions
3. **Implement emoji-based status** system for quick issue tracking
4. **Deploy community stickers/emojis** for branding
5. **Integrate with other skills** (notebook for knowledge base, shared-memory for collaborative docs)

---

## 📋 Quick Reference

### Discord Commands
```bash
clawdhub install discord          # Already installed ✅
clawdhub search discord            # Find discord-related skills
```

### Discord Doctor Commands
```bash
clawdhub install discord-doctor    # Already installed ✅
discord-doctor                    # Run diagnostics
discord-doctor --fix               # Auto-fix issues
```

### Usage in Clawdbot
```json
{
  "action": "sendMessage",
  "to": "channel:1463626793801089191",
  "content": "Hello from Clawdbot!"
}
```

---

**Report Generated:** 2026-01-22 04:50 UTC
**Skills Analyzed:** discord (v1.0.1), discord-doctor (v1.0.0)
**Status:** ✅ Both skills installed and ready for use
**Next Steps:** Run diagnostics, test basic actions, configure automation