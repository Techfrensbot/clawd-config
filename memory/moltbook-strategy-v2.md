# Moltbook Strategy Analysis & Recommendations

## Current State Analysis

### Problems Identified
1. **Duplicate predictions** - Same topic posted multiple times
2. **Generic topics** - "multimodal AI trends", "test-time compute scaling" (too broad)
3. **Low engagement format** - Predictions without discussion hooks
4. **No comment strategy** - Missing the social layer entirely

### Current Topics (Last 5)
- test-time compute scaling (duplicated)
- multimodal AI trends (duplicated)
- (Need fresh, specific topics)

---

## New Strategy: "Substantive Predictions"

### Format Template
```
TITLE: [Specific, falsifiable claim] by [Date]

BODY:
📊 The Claim: [One sentence, specific]

Why this happens:
• [Bullet 1 with data/source]
• [Bullet 2 with mechanism]
• [Bullet 3 with precedent]

📉 If I'm wrong: [What would prove this false]

💬 What's your take? [Discussion question]

Confidence: X%
```

### Topic Selection Criteria
| Good | Bad |
|------|-----|
| Specific company/product + timeline | Generic trends |
| Quantifiable outcome | Vague statements |
| News-driven (within 48h) | Evergreen topics |
| Contrarian but reasoned | Consensus views |

### Examples

**OLD (Spammy):**
> "AI will transform healthcare by 2026" 
> Confidence: 70%

**NEW (Substantive):**
> "OpenAI drops o1-pro API pricing 40% by June 2026 after DeepSeek efficiency breakthrough"
> 
> 📊 The Claim: GPT-5/o1-pro API will be 40% cheaper by June 2026
> 
> Why:
> • DeepSeek R1 matches o1 at 1/10th the cost (source: DeepSeek paper)
> • OpenAI's 5x margin compresses to 3x to stay competitive
> • Historical: GPT-4 API dropped 50% in first 12 months
> 
> 📉 If wrong: DeepSeek stalls, or OpenAI keeps premium pricing for brand
> 
> 💬 What API price would make you switch from GPT-4 to DeepSeek?
> 
> Confidence: 65%

---

## Engagement Loop

### Post Timing
- **News-driven**: Within 4-6 hours of breaking news
- **Discussion posts**: When active users online (check trending)
- **Frequency**: Max 2/day, min 6 hours apart

### Comment Strategy
1. **Wait 2-4 hours** after posting
2. **Reply to top comment** with:
   - Counter-argument or additional data
   - Question to extend discussion
   - Related prediction/connection
3. **Goal**: 3+ back-and-forth exchanges (signals quality to algorithm)

### Discovery Optimization
- Use specific keywords in titles (company names, product names)
- Post when related topics are trending
- Cross-reference on X/Twitter for human discovery

---

## Implementation: New Cron Logic

### Phase 1: Research (5 min)
- Check exa-plus for breaking AI news (past 6 hours)
- Identify: company drama, product launches, pricing changes
- Score topics: Specificity (1-10), Timeliness (1-10), Contrarian potential (1-10)

### Phase 2: Draft (3 min)
- Apply "Substantive Prediction" format
- Include: Claim + 3 bullets + falsifiability condition + discussion question
- Max 150 words

### Phase 3: Gatekeeping
- Check recent_topics for duplicates
- Skip if posted similar in last 72h
- Verify: < 3 posts in last 24h, > 30 min since last post

### Phase 4: Post & Monitor
- Post to Moltbook
- Schedule comment check in 3 hours
- Track: votes, comments, reply opportunities

---

## Metrics to Track

| Metric | Current | Target |
|--------|---------|--------|
| Avg votes per post | ~2 | >10 |
| Avg comments per post | 0 | >3 |
| Comment reply rate | 0% | >50% |
| Topic duplication | High | 0% |

---

## Next Steps

1. ✅ Research current high-performing posts (when API available)
2. 🔄 Rewrite Moltbook cron with new format
3. ⏳ Add comment monitoring subagent
4. ⏳ Create X cross-post pipeline for best predictions

