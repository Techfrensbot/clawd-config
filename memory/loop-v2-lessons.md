# v2 Script Writing Lessons Learned

## What Went Wrong

| Issue | Location | Root Cause |
|-------|----------|------------|
| Bad variable substitution | Line 12, 14, 16, 18 | Line breaks in `${MEMORY_DIR}` path after write corrupted the variable string |
| EOF while looking for closing quote | Line 283 | Quote corruption propagated; never closed properly |
| Missing return status check | Action execution | Missing `[ -n "$output" ] && status="SUCCESS"` guard for some cases |

---

## Rules for Next Time

1. **Single-line variable assignments**
   - ✅ `LOOP_LOG="${MEMORY_DIR}/loop-log-DATE.md"`
   - ❌ Don't break paths mid-variable

2. **Quote safety**
   - Escape double-quotes in heredocs or use single quotes
   - Check for unclosed quotes before writing
   - Use `grep -c` and loops over `loop-log-*.md` instead of counting patterns

3. **State signal names**
   - Cron job IDs require exact spelling (e.g., `id: 5396b3db`) or use field name
   - Use `name` or capture from remove/update with printed ID
   - Avoid pass-through `state` keys that differ across CRUD operations

4. **Deployment interaction**
   - Use `jq .name` from cron remove result to get the exact ID (not `state.id`)
   - Apply subscript or first-element filter before update operators

---

## Corrective Pattern

```bash
# BAD
LOCAL_VARPATH="${M
MEMORY_DIR}/loop-log-${DATE}.md"

# GOOD
LOCAL_VARPATH="${MEMORY_DIR}/loop-log-${DATE}.md"

# CLEANUP USE - STRING RUNSAFE:
# Use `grep -c` with full filenames and loop-entries not grep/pattern
```

---

## Enhanced Deployment SPEC

```json
{
  "name": "Autonomous Loop v2",
  "id": "ID_FROM_REMOVE_RESULT",
  "schedule": {
    "kind": "cron",
    "expr": "15 * * * *",
    "tz": "America/Los_Angeles"
  }
}
```

Critical notes:
- Dynamo-style custom: cron schedule spec should be concise; use `15 * * * *` or `*/15 * * * *` or `0,15,30,45 * * * *`
- Avoid intervals: `interval: 15m` or simple verb-noun/t2t is not defined/default

---

## Safety Guards

- Capture MCP search output non-truncated
- Always check `[ -n "$output" ]` before assuming pass
- Validate file write with exit status ($?)

---

## Next: To Apply

- Rewrite autonomous-loop-v3.sh
- Apply single-line paths
- Enforce quote safety
- Stricter output capture for MCP
- Smoother cron state transitions

---