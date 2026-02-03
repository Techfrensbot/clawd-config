---
name: exa-plus
version: 1.0.0
description: Neural web search via Exa AI. Search people, companies, news, research, code. Supports deep search, domain filters, date ranges.
metadata: {"clawdbot":{"emoji":"🧠","requires":{"bins":["curl","jq"]}}}
---

# Exa - Neural Web Search

Powerful AI-powered search with LinkedIn, news, research papers, and more.

## Setup

**Option 1: MCP Endpoint (No API Key Required!)**
The `mcp-search.sh` script uses Exa's free MCP endpoint - no setup needed!

**Option 2: Direct API (Requires Key)**
Create `~/.clawdbot/credentials/exa/config.json`:
```json
{"apiKey": "your-exa-api-key"}
```

## Commands

### MCP Search (No API Key!)
```bash
bash scripts/mcp-search.sh "query" [num_results]
```
Uses Exa's free MCP endpoint. Simple and fast.

### MCP Code Context (No API Key!)
```bash
bash scripts/mcp-code.sh "query" [tokens]
```
Get fresh context for APIs, libraries, and SDKs. Default: 5000 tokens (1000-50000).

### MCP Company Research (No API Key!)
```bash
bash scripts/mcp-company.sh "company name" [num_results]
```
Comprehensive company research - operations, news, financial info, industry analysis.

### MCP URL Crawling (No API Key!)
```bash
bash scripts/mcp-crawl.sh "url" [max_chars]
```
Extract full text and structured content from specific URLs. Default: 3000 chars.

### MCP LinkedIn Search (No API Key!)
```bash
bash scripts/mcp-linkedin.sh "query" [search_type] [num_results]
```
Search LinkedIn profiles and companies. Types: `profiles`, `companies`, `all` (default).

### MCP Deep Research (No API Key!)
```bash
# Start comprehensive research task
bash scripts/mcp-research-start.sh "research question" [model]

# Check status and get results (poll until completed)
bash scripts/mcp-research-check.sh "task_id"
```
AI-powered deep research with web searches, crawling, and synthesis.
- `exa-research`: Fast (15-45s), good for most queries
- `exa-research-pro`: Comprehensive (45s-2min), for complex topics

### General Search (Requires API Key)
```bash
bash scripts/search.sh "query" [options]
```

Options (as env vars):
- `NUM=10` - Number of results (max 100)
- `TYPE=auto` - Search type: auto, neural, fast, deep
- `CATEGORY=` - Category: news, company, people, research paper, github, tweet, pdf, financial report
- `DOMAINS=` - Include domains (comma-separated)
- `EXCLUDE=` - Exclude domains (comma-separated)
- `SINCE=` - Published after (ISO date)
- `UNTIL=` - Published before (ISO date)
- `LOCATION=NL` - User location (country code)

### MCP Examples (No API Key Required!)

```bash
# Web search
bash scripts/mcp-search.sh "AI agents 2024" 5

# Code context
bash scripts/mcp-code.sh "Next.js app router" 3000

# Company research
bash scripts/mcp-company.sh "Anthropic" 3

# Crawl a URL
bash scripts/mcp-crawl.sh "https://example.com/article" 5000

# LinkedIn search
bash scripts/mcp-linkedin.sh "AI engineer Amsterdam" profiles 5

# Deep research
TASK_ID=$(bash scripts/mcp-research-start.sh "What are the latest trends in LLM agents?" | jq -r .taskId)
sleep 10
bash scripts/mcp-research-check.sh "$TASK_ID"
```

### Direct API Examples (Requires API Key)

```bash
# Basic search
bash scripts/search.sh "AI agents 2024"

# LinkedIn people search
CATEGORY=people bash scripts/search.sh "software engineer Amsterdam"

# Company search
CATEGORY=company bash scripts/search.sh "fintech startup Netherlands"

# News from specific domain
CATEGORY=news DOMAINS="reuters.com,bbc.com" bash scripts/search.sh "Netherlands"

# Research papers
CATEGORY="research paper" bash scripts/search.sh "transformer architecture"

# Deep search (comprehensive)
TYPE=deep bash scripts/search.sh "climate change solutions"

# Date-filtered news
CATEGORY=news SINCE="2026-01-01" bash scripts/search.sh "tech layoffs"
```

### Get Content
Extract full text from URLs:
```bash
bash scripts/content.sh "url1" "url2"
```
