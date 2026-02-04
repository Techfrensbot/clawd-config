# Autonomous Research Agent - AGI Loop

## Overview
Narrow-domain autonomous research agent that actually learns from its cycles.

**Domain**: Test-time scaling + AI safety research (narrow focus to start)

## Core Loop (AGI Pattern)

```
SEARCH → UNDERSTAND → PROPOSE → LEARN → ADAPT → EXECUTE
```

### Phase-by-Phase Breakdown

| Phase | What it Does | AGI Relevance |
|-------|--------------|---------------|
| **SEARCH** | Queries Exa MCP for research papers, docs | Information gathering |
| **UNDERSTAND** | Extracts structured findings (methodologies, gaps) | Semantic understanding |
| **PROPOSE** | Generates novel research directions based on knowledge | Planning & creativity |
| **LEARN** | Builds knowledge base from findings | Knowledge accumulation |
| **ADAPT** | Refines search strategy based on what works | Self-improvement |
| **EXECUTE** | Validates learning progress | Feedback loop |

---

## Knowledge Accumulation

### State Structure (`memory/ara-state.json`)

```json
{
  "cycle": 5,
  "domain": "test-time scaling",
  "knowledge_entries": [
    {
      "cycle": 3,
      "timestamp": "2026-01-30T22:58:22Z",
      "query": "ensemble methods test-time compute scaling papers",
      "findings": ["Findings extracted from research..."],
      "gaps": ["Implementation gap", "Knowledge gap"],
      "keywords": ["test-time scaling", "autonomous research", "agent architecture"]
    }
  ],
  "strategies_tried": [...],
  "learning": {
    "kb_size_kb": 60,
    "cache_entries": 5,
    "knowledge_count": 4
  }
}
```

### Knowledge Base Files

- `/root/clawd/memory/ara-knowledge.md` - Human-readable knowledge entries
- `/root/clawd/memory/ara-knowledge/understanding-cycleN.md` - Per-cycle understanding
- `/root/clawd/memory/ara-knowledge/proposal-cycleN.md` - Per-cycle research proposals

---

## Strategy Adaptation

The agent refines its approach each cycle:

| Cycle | Strategy | Query Pattern |
|-------|----------|---------------|
| 0 | test-time scaling RL benchmarks | `% 4 == 0` |
| 1 | autonomous research agent architecture | `% 4 == 1` |
| 2 | AI safety verification gates | `% 4 == 2` |
| 3 | ensemble methods test-time compute | `% 4 == 3` |

After 5+ cycles, switches to **keyword-driven refinement** using accumulated knowledge.

---

## Safety & Containment

| Layer | Implementation |
|-------|----------------|
| **Off-switch** | `touch /root/clawd/memory/ara-stop.flag` |
| **Blast radius** | No external writes, only local state updates |
| **Containment** | All validation is measurement-only |
| **Logging** | Full cycle logs in `memory/ara-log-*.md` |

---

## Usage

```bash
# Run single cycle
bash /root/clawd/scripts/autonomous-research-agent.sh

# Run with specific domain
DOMAIN="AI safety" bash /root/clawd/scripts/autonomous-research-agent.sh

# Stop execution
touch /root/clawd/memory/ara-stop-flag

# Check state
cat /root/clawd/memory/ara-state.json | jq .
```

---

## Success Criteria

| Milestone | Status |
|-----------|--------|
| ✅ Cycle structure (SEARCH → UNDERSTAND → PROPOSE → LEARN → ADAPT → EXECUTE) | Complete |
| ✅ Knowledge accumulation with structured entries | Working |
| ✅ Strategy adaptation (query rotation) | Working |
| ⏳ LLM-based semantic understanding (beyond pattern matching) | Next upgrade |
| ⏳ Propositions based on actual findings (not hardcoded) | Next upgrade |
| ⏳ Self-directed experiments beyond measurement | Next upgrade |

---

## Research Foundation

Based on:
- "Thinking vs. Doing: Scaling Test-Time Interaction" (Stevens, 2025)
- "Collective Test-Time Scaling" (arXiv:2405.06624)
- "Towards a Science of Scaling Agent Systems" (Google/DeepMind, 2025)

---

## Next Improvements

1. **Deeper Understanding**: Integrate LLM to truly understand research findings
2. **Better Proposals**: Generate novel directions based on accumulated knowledge
3. **Keyword-Driven Search**: Use learned keywords to refine queries
4. **Real Experiments**: Add ability to run actual benchmarks/experiments
5. **Knowledge Graph**: Build relationships between findings over cycles