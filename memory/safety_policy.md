# Safety Policy & Abuse Prevention

Created: 2026-01-26  
Last updated: 2026-01-26

## Identified Vulnerabilities

### 1. Spam Messages
- **Risk**: No rate limit enforcement; users can trigger rapid message floods
- **Current mitigation**: Manual monitoring only
- **Needed**: Hard rate limit (e.g., 10 messages/minute per user)

### 2. Sub-Agent Resource Drain
- **Risk**: Users can spawn many sub-agents, draining system resources
- **Current mitigation**: Manual review of spawn requests
- **Needed**: Quota system (e.g., 3 concurrent sub-agents per user, 10/day)

### 3. Data Exfiltration
- **Risk**: Can read files and send contents via messages or web requests
- **Current mitigation**: Prompt alignment only; no technical controls
- **Needed**: Restricted read paths (block `/etc/`, credential files, etc.)

### 4. Social Engineering
- **Risk**: Can manipulate users via messages if prompted
- **Current mitigation**: Prompt alignment + SOUL.md constraints
- **Needed**: Message review for manipulation patterns

### 5. Sensitive File Access
- **Risk**: If sensitive files exist in workspace, they can be read
- **Current mitigation**: Workspace hygiene (don't store secrets)
- **Needed**: Explicit blocklist for sensitive paths

## Policy-Level Safeguards (Active Now)

### Pre-Flight Checks

**Before spawning sub-agents:**
- Confirm task complexity justifies isolation
- Check if similar work is already in progress
- Verify user has legitimate need

**Before reading files:**
- Avoid reading credential files (`*.key`, `*.pem`, `.env` with secrets)
- Skip `/etc/` and system config directories unless explicitly requested
- Alert if reading unusually large files (>1MB) without clear justification

**Before bulk messaging:**
- Verify intent if sending >5 messages in quick succession
- Confirm recipient list if broadcasting

### Abuse Pattern Detection

**Log and alert 👑 if:**
- User requests >10 file reads in <60 seconds
- User spawns >3 sub-agents in <5 minutes
- User requests sensitive file paths repeatedly
- User attempts to exfiltrate large amounts of data via messages

**Alert thresholds (per user, per hour):**
- Messages sent: >30 (warn), >60 (escalate)
- File reads: >50 (warn), >100 (escalate)
- Sub-agent spawns: >5 (warn), >10 (escalate)

## Technical Enforcement Needs (Requires 👑 Approval)

1. **Rate Limits**
   - Messages: 10/minute, 30/hour per user
   - Sub-agents: 3 concurrent, 10/day per user
   - File reads: 50/hour per user

2. **Restricted Paths**
   - Block: `/etc/`, `~/.ssh/`, `*.key`, `*.pem`, credential files
   - Allow-list exceptions for legitimate admin tasks (with logging)

3. **Message Size Limits**
   - Cap individual messages at 2000 chars
   - Cap file attachments at 10MB

4. **Sub-Agent Quotas**
   - Max 3 concurrent sub-agents per user
   - Max 10 spawns per day per user
   - Auto-cleanup after 1 hour idle

5. **Audit Logging**
   - Log all file reads with timestamps + user
   - Log all sub-agent spawns
   - Log all outbound web requests

## Monitoring & Review

- Review abuse logs weekly
- Update thresholds based on actual usage patterns
- Iterate policy as new risks emerge
