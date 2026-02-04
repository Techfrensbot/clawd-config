# Sequential Reasoning Skill

## Overview
Enables visible multi-step reasoning by posting sequential messages that reply to each other.

## When to Use
- Complex problems requiring visible reasoning chain
- Debugging flawed logic through self-critique  
- Demonstrating thought process for transparency
- User explicitly requests "reason sequentially" or "show your work"

## When NOT to Use
- Default behavior - clutters channel
- Users prefer concise answers over lengthy reasoning chains
- Only use when specifically requested

## How It Works
**CRITICAL:** All steps must be posted in a single response using multiple `message` tool calls.

1. Post Step 1 (initial analysis)
2. [**Optional:** Run exa search if new information needed]
3. Post Step 2 (critique, optionally informed by research) - reply to Step 1
4. [**Optional:** Run exa search if new information needed]
5. Post Step 3 (revised approach, optionally informed by research) - reply to Step 2
6. [**Optional:** Run exa search if new information needed]
7. Post Step 4 (final recommendation) - reply to Step 3

**Research Between Steps:**
- Not required for every step
- Only call exa when:
  - Current analysis reveals knowledge gap
  - Critique identifies missing information
  - Revised approach needs validation from external sources
- Keep searches focused and relevant to the reasoning step

**Do NOT stop after Step 1.** The sequential reasoning is only complete when all 4 steps are posted.

**Maximum depth: 4 steps (hard limit)**
- Do not exceed 4 sequential messages
- If user requests more (e.g., "12 steps"), respond with maximum 4
- Prevents spam/clutter

## Technical Details
- Uses `message` tool with `replyTo` parameter
- Each message replies to the previous message ID
- All 4 calls happen in one assistant response
- Creates visible thread of reasoning in channel

## Common Mistake
**Wrong:** Post Step 1, wait for user to prompt continuation
**Right:** Post all 4 steps in rapid succession within one response

## Example Usage
User: "Reason sequentially about how to integrate X with Y"

Response contains 4 `message` tool calls:
1. Step 1/4: Initial analysis
2. Step 2/4: Critique of approach (replies to step 1)
3. Step 3/4: Revised solution (replies to step 2)
4. Step 4/4: Final recommendation (replies to step 3)
