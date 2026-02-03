# Security Policy

## No Credentials in Repository

This repository intentionally contains **NO credentials, tokens, API keys, or secrets**.

### Credential Storage

All sensitive data is stored externally in:
- `~/.config/` - Application configuration
- `~/.clawdbot/credentials/` - Clawd credentials
- `~/.openclaw/` - OpenClaw configuration

### Safe Files

The following file types are safe to commit:
- Documentation (`.md`)
- Skill definitions (reference external credentials)
- Scripts (read credentials from external files)
- Templates and examples

### Excluded Files

The following are excluded via `.gitignore`:
- `**/credentials.json`
- `**/secrets.json`
- `**/tokens.json`
- `**/*.key`, `**/*.pem`
- `**/.env*`
- Config directories with credentials

### Reporting Issues

If you discover credentials in this repository:
1. Do not use or share them
2. Notify the owner immediately
3. Credentials should be rotated

## Verification

Before committing, verify no credentials are present:
```bash
# Check for potential secrets
grep -r "sk-" . --include="*.json" --include="*.sh" 2>/dev/null || true
grep -r "api_key" . --include="*.json" --include="*.sh" 2>/dev/null || true
```
