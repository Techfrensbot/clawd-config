---
name: short-form-video-script
description: Create engaging scripts for short-form social media videos (TikTok, Instagram Reels, YouTube Shorts, LinkedIn, Twitter/X). Use when creating video content under 90 seconds that needs a strong hook, clear data/stats, actionable insights, and an inspirational close.
---

# Short-Form Video Script Writer

Create engaging, human-sounding scripts for social media videos (15-90 seconds).

## Core Principles

### 1. Hook Generation & Selection (Orchestrated)

The hook is auto-generated and selected from multiple candidates. Zero manual intervention.

**Step 1: Generate 5 Hook Variations**

| Type | Template | Example (Tesla xAI) |
|------|----------|---------------------|
| **Contrast** | "X happened. Meanwhile Y..." | "$2B to xAI. BYD just passed Tesla." |
| **Question** | "What happens when..." | "What happens when AI costs more than cars?" |
| **Data-first** | "Number. Surprising fact." | "$20 billion. That's Tesla's AI bet." |
| **Personal** | "Your [thing] is changing..." | "Your car company just became a software bet." |
| **Stakes** | "X eats Y..." | "Software eats cars. Or cars eat software." |

**Step 2: Auto-Selection Criteria**

Score each hook 1-5 on:
- **Specificity** — Names companies/numbers, not vague
- **Curiosity gap** — Makes viewer need to know more
- **Relevance** — Connects to viewer's world
- **No AI clichés** — No "twist", "kicker", "here's the thing"

**Winner = Highest score. Break ties with specificity.**

**Step 3: Promise/Payoff Verification**

- Hook makes a promise → Body MUST deliver it
- Example: "Three stats..." → Script contains exactly 3 stats
- Example: "Here's what the data says..." → Stats section follows

**Avoid:**
- Generic statements ("AI is here")
- Clickbait without payoff ("You won't believe this")
- Over-hyping ("This will DESTROY everything you know")
- Vague promises ("The secret they don't want you to know")
- **AI-sounding transitions** — "Here's the twist", "Here's the kicker", "But wait", "The catch"

### 2. Stats & Data (middle section)
- **Compare apples to apples**: If comparing 2023 vs 2026, use the same metric
- **Include totals**: Don't just say "12% use it daily" — add context like "up from 21% total usage in 2023"
- **Use round numbers**: "one in ten" reads better than "10.3%"
- **Front-load the punchline**: Lead with the surprising stat, then explain
- **Source Context Requirement**: When citing any organization, report, or expert, immediately clarify what they are. Never assume audience recognition.
  - ❌ "According to Challenger, Gray and Christmas..."
  - ✅ "According to Challenger, Gray and Christmas, the job market tracking firm..."
  - ✅ "Job market tracking firm Challenger, Gray and Christmas reported that..."
  - **Pattern**: "According to [Name], the [type of organization/person]..." or "[Type] [Name] reported that..."

**Example (good):**
> "In 2023, only 21% of American workers used AI at work. Fast forward to today: that number has jumped to 51%."

**Example (bad — apples to oranges):**
> "In 2023, 21% used AI occasionally. Now 12% use it daily."

### 3. Impact (show real consequences)
Use concrete examples, not abstractions.

**Good:**
- "Healthcare workers are learning telehealth systems overnight."
- "Marketers who ignored social media data three years ago now get passed over for promotions."

**Avoid:**
- "This will change everything" (vague)
- "The paradigm is shifting" (corporate jargon)

### 4. Action (what can they do?)
Give **one** clear, actionable step.

**Good:**
- "Pick one new skill. Spend 20 minutes a day learning it."
- "Start with Python. Free courses are everywhere. Begin today."

**Avoid:**
- Laundry lists of actions
- "Consider maybe trying to think about..."

### 5. Close (end with inspiration)
Short, punchy, memorable.

**Good:**
- "The winners won't be the smartest. They'll be the ones who started learning today."
- "Your move."

**Avoid:**
- Em dashes (use periods or commas)
- "So in conclusion..." (never say this)

## Human Tone Guidelines

### Avoid AI Clichés
**NEVER use these patterns (zero tolerance):**
- "It's not just X, it's Y"
- **"Not X, but Y" / "Not X. It's Y"** - Contrastive negation (BANNED in ALL forms: "Not on chips, on dirt" / "This isn't about stock price, it's what comes next" / "Not server racks, entire power plants")
- **"X isn't just Y anymore. They're/It's Z"** - Temporal contrast negation (BANNED: "Nvidia isn't just selling chips anymore. They're financing infrastructure" / "AI isn't just a tool anymore. It's replacing jobs")
- "But here's the thing..."
- "Let's be honest..."
- "At the end of the day..."
- Em dashes (use periods, commas, or short sentences)

**Contrastive negation = instant failure.**
It doesn't sound clever. Not once. Not ever. It screams "AI-written" from the first use.

**All "isn't just...anymore" patterns are contrastive negation in disguise.**
Same problem, different words. Always rewrite as direct statements.

**Use instead:**
- Direct statements: "Nvidia bought dirt and electricity" (skip the negation entirely)
- Shift focus without contrast: "Forget the stock price. Here's what matters..."
- Simple pivots: "The real story: 5 gigawatts by 2030"
- **Rewrite temporal contrasts:** Instead of "Nvidia isn't just selling chips anymore. They're financing infrastructure" → "Nvidia now finances infrastructure. Two billion into CoreWeave proves it."

### Use Instead
- Short sentences
- Direct statements
- Active voice
- Concrete examples
- Round numbers ("one in ten" not "10.3%")

## Timing & Word Count

**Formula:**
- Speaking pace: **150-160 words/minute** = ~**2.5 words/second**
- 15-second video: ~40 words
- 30-second video: ~75 words
- 45-second video: ~110 words
- 60-second video: ~150 words
- 90-second video: ~225 words

**Always verify timing:**
1. Count words in each section
2. Divide by 2.5 to get seconds
3. Adjust if sections run long

## Research: Deep Dive First (Before Writing)

**ALWAYS start each session by researching the topic in detail** so you are knowledgeable before writing anything.

### Step 1: Topic Research

Use **exa-plus** to gather comprehensive understanding:

```bash
bash scripts/mcp-search.sh "<topic> overview analysis"
bash scripts/mcp-search.sh "<topic> expert opinion recent"
bash scripts/mcp-search.sh "<topic> statistics data 2025 2026"
```

**What to gather:**
1. **Foundational understanding** - What is the topic? Key concepts? Current state?
2. **Expert opinions** - Industry leaders, researchers, analysts
3. **Data & statistics** - Recent numbers, studies, reports from credible sources
4. **Real-world examples** - Case studies, concrete applications, specific companies/people
5. **Contrarian views** - Nuanced takes, not just consensus

**Build deep knowledge BEFORE writing** - understand the topic well enough to explain it naturally, not just repeat facts.

### Step 2: Apply Research to Script

**How to use what you learned:**
- Weave expert perspectives into the **STATS** or **IMPACT** sections
- Add credibility with phrases like "According to Goldman Sachs CIO..." or "IMF analysis shows..."
- Use concrete examples from your research
- Keep source links for the reference list at the end

## Script Structure Template

Use this structure for 45-60 second videos:

**[HOOK - 5 sec, ~12 words]**
Tell them what they'll learn.

**[STATS - 15-20 sec, ~40-50 words]**
Present data clearly, compare apples to apples, include totals. Cite expert sources when available.

**[IMPACT - 10-15 sec, ~25-35 words]**
Show real-world consequences with concrete examples. Include expert opinions or analysis if relevant.

**[ACTION - 10 sec, ~25 words]**
One clear, actionable step.

**[CLOSE - 3-5 sec, ~10-15 words]**
Inspirational, memorable finish.

## Script Review Checklist

Before delivering the final script, verify:

1. **Promise/Payoff Alignment**
   - Does the hook make a promise? (e.g., "Here's what the data says" / "Three stats..." / "The reason why...")
   - Does the body deliver on that exact promise?
   - Example: If hook says "Three stats that will change...", count the stats in the script. Are there exactly three impactful ones?

2. **Timing Accuracy**
   - Count words in each section
   - Divide by 2.5 to get seconds
   - Does the total match the target length?

3. **Human Tone**
   - No AI clichés ("It's not just...", "isn't just...anymore", "But here's the thing...")
   - No em dashes
   - Active voice, short sentences

## Final Step: Contrastive Negation Elimination (Mandatory Loop)

**Before delivering the script, run this analysis loop:**

1. **Scan the entire script** for ALL forms of contrastive negation:
   - "Not X, but Y"
   - "Not X. Y instead."
   - "This isn't X, it's Y"
   - "X? No. Y."
   - **"X isn't just Y anymore. [They're/It's] Z"** (temporal contrast negation)
   - Any pattern that negates one thing to emphasize another

2. **For each instance found:**
   - Rewrite as a direct statement (no negation)
   - Example: "Not on chips. On dirt and electricity." → "Nvidia bought dirt and electricity. Two billion dollars on land and power infrastructure."
   - Example: "This isn't about the stock price. It's what comes next." → "The stock price jumped 10%. But here's what actually matters."
   - Example: "Nvidia isn't just selling chips anymore. They're financing infrastructure." → "Nvidia now finances infrastructure. Two billion into CoreWeave proves it."

3. **Re-scan the rewritten script**
   - If ANY contrastive negation remains, repeat step 2
   - Loop until the script is 100% clean

4. **Verify the rewrite reads naturally**
   - Does it still make sense?
   - Does it flow smoothly?
   - Is it more direct and human?

**Do not deliver a script until this loop confirms zero instances of contrastive negation.**

## Output Format

When generating scripts:

1. **Full script with spoken words only** (no stage directions unless requested)
2. **Word count per section** (for timing verification)
3. **Total estimated runtime** (based on 2.5 words/sec)
4. **Promise/Payoff check** (if hook makes a promise, confirm it's delivered)
5. **Source links** (list all expert sources, reports, or data referenced in the script)

## Example Output

**Spoken Script:**

Your job is changing faster than you think. Here's what the data says about your future at work.

In 2023, only 21% of American workers used AI at work. Fast forward to today: that number has jumped to 51%. 12% now use it daily. Another 25% use it weekly. The rest? A few times a year. But 49% still haven't touched it once. And they're paying for it. One in ten job postings now demands skills that didn't exist five years ago. In tech roles, it's one in two.

Healthcare workers are learning telehealth systems overnight. Marketers who ignored social media data three years ago now get passed over for promotions. Developers pair-program with AI that codes faster than any senior engineer.

What can you actually do about this? Pick one new skill. Spend 20 minutes a day learning it. You'll leap ahead of half the people competing for the same jobs as you.

The winners won't be the smartest. They'll be the ones who started learning today.

---

**Timing Breakdown:**
- Hook: 14 words (~6 sec)
- Stats: 90 words (~36 sec)
- Impact: 31 words (~12 sec)
- Action: 30 words (~12 sec)
- Close: 14 words (~6 sec)
- **Total: 179 words (~72 seconds)**

**Sources:**
- Gallup Workforce Survey: https://www.wsbtv.com/news/trending/ai-work-how-artificial-intelligence-is-reshaping-work/...
- IMF Analysis: https://www.imf.org/en/blogs/articles/2026/01/14/new-skills-and-ai-are-reshaping-the-future-of-work
