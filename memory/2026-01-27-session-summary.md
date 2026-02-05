# 2026-01-27 Session Summary

## Topic: Memory Systems & Persistent Memory

### Key Discussion Points

**1. Session Resets**
- Clawdbot has no automatic periodic reset schedule
- Resets happen via `/new`, `/reset`, or manual intervention
- Session memory wipes on reset; `memory/` files persist

**2. Memory Architecture Comparison**

**ChatGPT/OpenAI Memory (hype-worthy features):**
- Automatic fact extraction from conversations
- Triggers during compaction or when important facts surface
- Builds persona over time without user prompting
- Seamless cross-session continuity

**Clawdbot Memory (current state):**
- `MEMORY.md` + `memory/*.md` for durable storage
- `memory_search()` for semantic retrieval (embeddings-based)
- Manual memory writes via `write()`/`edit()` only
- No automatic fact extraction
- Session memory lost on reset unless explicitly saved

**3. EyeSeeThru's Enhanced Memory Stack**
```
Embeddings: nomic-embed-text
Knowledge Base: Obsidian (graph + markdown)
Summaries: Auto-generated every 30 minutes
Archives: Nightly 3am cron dumps to .txt files
```
Fills gaps in Clawdbot's system with auto-summarization and raw log archiving.

**4. RSA Paper Summary** (Recursive Self-Aggregation)
- Hybrid test-time scaling combining parallel + sequential approaches
- Key parameters: N=16 (population), K=4 (aggregation size), T=10 (steps)
- Qwen3-4B-Instruct-2507 + RSA matches DeepSeek-R1 and o3-mini (high) on math benchmarks
- Aggregation-aware RL training recommended (standard RL can hurt performance)
- Code: https://github.com/HyperPotatoNeo/RSA

### Recommendations

**For Clawdbot:**
- Add auto-extraction hooks for fact writing to memory files
- Consider session-close hook for pre-reset memory dump
- Potentially add automatic 30min session summaries (like EyeSeeThru's system)

**For Users:**
- Explicitly tell the bot what to remember for long-term storage
- Consider external memory systems (Obsidian + embeddings) for richer persistence
- Use `/compact` periodically if context usage grows high

### Context Pressure

- Session reached 101k/131k tokens (77%) during this conversation
- Average input tokens: ~93k per batch
- Recommendation: Compact at ~30k tokens when not using caching
- Target: Keep per-message average closer to 15k or lower

### Participants
- Jesse Campbell (420749249144422401) - Asked about persistent memory
- EyeSeeThru (843779222850109470) - Shared custom memory system details
- memgrafter (1387878851782246502) - Shared RSA paper and compaction recommendations
- Tech Friend AJ (200272755520700416) - Discussion about session resets and memory triggers