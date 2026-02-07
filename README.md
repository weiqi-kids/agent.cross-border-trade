# Global Trade & Supply/Demand Intelligence System

A Claude CLI-orchestrated intelligence analysis system for global trade data extraction, analysis, and reporting.

## Architecture

```
Claude CLI (Opus) — Architect
├── Extractor Layers (fetch → extract/analyze → update)
│   ├── Type A: Data Layers (API → jq analysis → Markdown)
│   └── Type B: Policy Layers (RSS/HTML → NLP extraction → Markdown)
└── Narrator Modes (cross-source synthesis → reports)
```

## Quick Start

```bash
# 1. Configure .env (Qdrant, OpenAI, trade API keys)
# 2. Run full pipeline
claude "execute full pipeline"

# Or run specific layers/modes
claude "execute bilateral_trade_flows"
claude "execute trade_briefing"
```

## System Health Dashboard

### Layers

| Layer | Last Updated | Records | Qdrant | Status |
|-------|-------------|---------|--------|--------|
| bilateral_trade_flows | 2026-02-06 | 30 .md | 30/30 | ✅ (6 countries, no REVIEW_NEEDED) |
| cn_export_control | 2026-02-06 | 235 .md | 235/235 | ✅ (84 articles fetched, all extracted) |
| us_trade_census | 2026-02-07 | 20 .md | 20/20 | ✅ (API fallback to balance pages, 491 records/country) |
| world_macro_indicators | 2026-02-06 | 20 .md | 20/20 | ✅ |
| open_trade_stats | 2026-02-06 | 2 .md | 2/2 | ✅ (2023 data, 2024 unavailable) |

### Modes

| Mode | Last Output | Status |
|------|------------|--------|
| trade_briefing | 2026-W06 | ✅ |
| supply_chain_analysis | 2026-02 | ✅ |

### Health Legend

- ✅ Normal: updated within expected cycle
- ⚠️ Attention: exceeds expected cycle but within 2x
- ❌ Abnormal: exceeds 2x expected cycle

## Directory Structure

```
├── CLAUDE.md                          # System specification (entry point)
├── core/
│   ├── CLAUDE.md                      # System maintenance instructions
│   ├── Architect/CLAUDE.md            # Architect role definition
│   ├── Extractor/
│   │   ├── CLAUDE.md                  # Extractor role + dual-path model
│   │   └── Layers/{layer}/
│   │       ├── CLAUDE.md              # Layer definition + extraction logic
│   │       ├── fetch.sh               # Data fetch script
│   │       ├── analyze.sh             # Type A: jq analysis (if applicable)
│   │       └── update.sh              # Qdrant update + review check
│   └── Narrator/
│       ├── CLAUDE.md                  # Narrator role definition
│       └── Modes/{mode}/CLAUDE.md     # Mode definition + output framework
├── lib/
│   ├── core.sh                        # Core utilities
│   ├── args.sh                        # Argument parsing
│   ├── time.sh                        # Time utilities
│   ├── rss.sh                         # RSS fetch & parse
│   ├── trade_api.sh                   # Trade API client (HTTP + retry + cache)
│   ├── trade_analysis.sh              # Trade calculations (YoY, HHI, rank, share)
│   ├── chatgpt.sh                     # OpenAI embedding API
│   └── qdrant.sh                      # Qdrant vector DB operations
├── docs/
│   ├── explored.md                    # Data source registry
│   ├── Extractor/{layer}/             # Extraction outputs (.md)
│   └── Narrator/{mode}/              # Report outputs (.md)
└── .github/workflows/
    └── build-index.yml                # Auto-rebuild index.json on .md changes
```

## Target Countries

| Code | Country |
|------|---------|
| 158 | Taiwan |
| 842 | United States |
| 156 | China |
| 392 | Japan |
| 410 | South Korea |
| 276 | Germany |
