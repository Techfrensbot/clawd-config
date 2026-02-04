# Open Loops Tracker

A structured system for tracking unresolved tasks/requests.

## Quick Commands

- **Add loop**: `loop: [title]` or `add loop: [title]`
- **Close loop**: `close loop [number]` or `done: [title]`
- **Update loop**: `update loop [number]: [new status]`
- **List loops**: `show loops` or `open loops`

## Status Legend

- 🔴 **P0** — Blocks other work, handle today
- 🟡 **P1** — Should close this week
- ⚪ **P2** — Backlog, nice-to-have
- 🟢 **In Progress** — Active work happening
- ⏸️ **Blocked** — Waiting for external input
- ✅ **Closed** — Resolved (moved to Closed section)

## Active Loops

| # | Title | Owner | Status | Priority | Last Updated | Cadence |
|---|-------|-------|--------|----------|--------------|---------|
| 4 | Sequential thinking strategy ranking | 👑 | 🟢 In Progress | 🟢 P2 | 2026-01-30 | Every 15-min loop |
| 3 | Paper analyzer integration | 👑 + memgrafter | ⏸️ Pending approval | 🟡 P1 | 2026-01-26 | Every 2 days |

## Recently Closed

| # | Title | Owner | Closed Date | Resolution |
|---|-------|-------|-------------|------------|
| 5 | Build open loop tracker | 👑 | 2026-01-29 | System built with cron alerts + commands |
| 2 | Video topic idea/day loop | 👑 | 2026-01-29 | Deferred - format unclear |
| 4 | Codex/Claude account incident clarity | 👑 | 2026-01-29 | No action needed - context preserved |

| # | Title | Owner | Closed Date | Resolution |
|---|-------|-------|-------------|------------|
| — | — | — | — | — |

## Stale Loop Rules

- **> 48h without update** → Alert @techfren in DMs
- **> 7 days stale** → Auto-escalate to P0
- **> 14 days stale** → Archive with [STALE] tag

## Last System Check

- Stale scan: 2026-01-29 04:11 UTC
- Next scan: 2026-01-30 04:11 UTC