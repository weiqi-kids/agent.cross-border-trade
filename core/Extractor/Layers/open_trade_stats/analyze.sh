#!/bin/bash
# open_trade_stats 數據分析腳本（Type A — jq 計算）
# 讀取 OTS API 回傳的 JSON，產出 HS6 級別貿易分析 Markdown

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/trade_analysis.sh"

LAYER_NAME="open_trade_stats"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

for cat in bilateral_flow product_detail country_profile hs_section; do
  mkdir -p "$DOCS_DIR/$cat"
done

FETCHED_AT="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
CURRENT_YEAR="$(date +%Y)"
DATA_YEAR=$(( CURRENT_YEAR - 2 ))

# Bash 3.2 compatible — function instead of declare -A
country_name_for() {
  case "$1" in
    twn) echo "Taiwan" ;;
    usa) echo "United States" ;;
    chn) echo "China" ;;
    jpn) echo "Japan" ;;
    kor) echo "South Korea" ;;
    deu) echo "Germany" ;;
    *)   echo "$1" ;;
  esac
}

echo "=== open_trade_stats analyze ==="

TOTAL_MD=0

# 1. Country Profiles (yr files)
for raw_file in "$RAW_DIR"/yr-*-${DATA_YEAR}.json; do
  [[ -f "$raw_file" ]] || continue

  country="$(basename "$raw_file" | sed "s/yr-\(.*\)-${DATA_YEAR}.json/\1/")"
  country_name="$(country_name_for "$country")"

  echo "Processing country profile: $country_name"

  tmp_jsonl="$(mktemp)"
  jq -c '.[]? // empty' "$raw_file" > "$tmp_jsonl" 2>/dev/null || true
  record_count="$(wc -l < "$tmp_jsonl" | tr -d ' ')"

  if [[ "$record_count" -gt 0 ]]; then
    md_file="$DOCS_DIR/country_profile/${country}-profile-${DATA_YEAR}.md"
    {
      echo "# ${country_name} — Trade Profile (${DATA_YEAR})"
      echo ""
      echo "- **Source**: Open Trade Statistics (tradestatistics.io)"
      echo "- **Country**: ${country_name} (${country})"
      echo "- **Period**: ${DATA_YEAR}"
      echo "- **Fetched**: ${FETCHED_AT}"
      echo "- **confidence**: 高"
      echo ""
      echo "## Overview"
      echo ""
      echo "| Metric | Value |"
      echo "|--------|-------|"
      jq -r '
        "| Export Value | \(.export_value_usd // "N/A") |",
        "| Import Value | \(.import_value_usd // "N/A") |",
        "| Trade Balance | \((.export_value_usd // 0) - (.import_value_usd // 0)) |"
      ' "$tmp_jsonl" 2>/dev/null | head -5 || echo "| — | — |"
      echo ""
      echo "---"
      echo ""
      echo "*Source: Open Trade Statistics, https://tradestatistics.io/*"
    } > "$md_file"

    TOTAL_MD=$(( TOTAL_MD + 1 ))
    echo "  country_profile: $md_file"
  fi
  rm -f "$tmp_jsonl"
done

# 2. Bilateral Flows (yrp files)
for raw_file in "$RAW_DIR"/yrp-*-${DATA_YEAR}.json; do
  [[ -f "$raw_file" ]] || continue

  filename="$(basename "$raw_file" ".json")"
  # Extract reporter and partner from filename: yrp-{reporter}-{partner}-{year}
  reporter="$(echo "$filename" | cut -d'-' -f2)"
  partner="$(echo "$filename" | cut -d'-' -f3)"
  reporter_name="$(country_name_for "$reporter")"
  partner_name="$(country_name_for "$partner")"

  echo "Processing bilateral: $reporter_name → $partner_name"

  tmp_jsonl="$(mktemp)"
  jq -c '.[]? // empty' "$raw_file" > "$tmp_jsonl" 2>/dev/null || true
  record_count="$(wc -l < "$tmp_jsonl" | tr -d ' ')"

  if [[ "$record_count" -gt 0 ]]; then
    md_file="$DOCS_DIR/bilateral_flow/${reporter}-${partner}-${DATA_YEAR}.md"
    {
      echo "# ${reporter_name} ↔ ${partner_name} — Bilateral Trade (${DATA_YEAR})"
      echo ""
      echo "- **Source**: Open Trade Statistics"
      echo "- **Reporter**: ${reporter_name} (${reporter})"
      echo "- **Partner**: ${partner_name} (${partner})"
      echo "- **Period**: ${DATA_YEAR}"
      echo "- **Fetched**: ${FETCHED_AT}"
      echo "- **confidence**: 高"
      echo ""
      echo "## Bilateral Summary"
      echo ""
      echo "| Metric | Value (USD) |"
      echo "|--------|-------------|"
      jq -r '
        "| Export Value | \(.export_value_usd // "N/A") |",
        "| Import Value | \(.import_value_usd // "N/A") |"
      ' "$tmp_jsonl" 2>/dev/null | head -5 || echo "| — | — |"
      echo ""
      echo "---"
      echo ""
      echo "*Source: Open Trade Statistics, https://tradestatistics.io/*"
    } > "$md_file"

    TOTAL_MD=$(( TOTAL_MD + 1 ))
    echo "  bilateral_flow: $md_file"
  fi
  rm -f "$tmp_jsonl"
done

# 3. Commodity Structure (yrc files)
for raw_file in "$RAW_DIR"/yrc-*-${DATA_YEAR}.json; do
  [[ -f "$raw_file" ]] || continue

  country="$(basename "$raw_file" | sed "s/yrc-\(.*\)-${DATA_YEAR}.json/\1/")"
  country_name="$(country_name_for "$country")"

  echo "Processing commodities: $country_name"

  tmp_jsonl="$(mktemp)"
  jq -c '.[]? // empty' "$raw_file" > "$tmp_jsonl" 2>/dev/null || true
  record_count="$(wc -l < "$tmp_jsonl" | tr -d ' ')"

  if [[ "$record_count" -gt 0 ]]; then
    md_file="$DOCS_DIR/hs_section/${country}-commodities-${DATA_YEAR}.md"
    {
      echo "# ${country_name} — Commodity Structure (${DATA_YEAR})"
      echo ""
      echo "- **Source**: Open Trade Statistics"
      echo "- **Country**: ${country_name} (${country})"
      echo "- **Period**: ${DATA_YEAR}"
      echo "- **Fetched**: ${FETCHED_AT}"
      echo "- **confidence**: 高"
      echo ""
      echo "## Top Commodities by Export Value"
      echo ""
      echo "| Section | Export Value (USD) |"
      echo "|---------|-------------------|"
      jq -r 'select(.export_value_usd != null) | "| \(.section_code // "N/A") | \(.export_value_usd) |"' "$tmp_jsonl" 2>/dev/null | sort -t'|' -k3 -rn | head -20 || echo "| — | — |"
      echo ""
      echo "---"
      echo ""
      echo "*Source: Open Trade Statistics, https://tradestatistics.io/*"
    } > "$md_file"

    TOTAL_MD=$(( TOTAL_MD + 1 ))
    echo "  hs_section: $md_file"
  fi
  rm -f "$tmp_jsonl"
done

echo ""
echo "=== Analyze Summary ==="
echo "Total .md files generated: $TOTAL_MD"
echo "Analyze completed: $LAYER_NAME"
