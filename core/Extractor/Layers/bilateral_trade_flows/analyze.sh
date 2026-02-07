#!/bin/bash
# bilateral_trade_flows 數據分析腳本（Type A — jq 計算）
# 讀取 raw/ 下的 JSON，計算排名、YoY、HHI、份額、差額
# 輸出結構化 Markdown 到各 category 目錄

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/trade_analysis.sh"

LAYER_NAME="bilateral_trade_flows"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# Ensure category directories exist
for cat_dir in export_flow import_flow trade_balance market_concentration commodity_structure; do
  mkdir -p "$DOCS_DIR/$cat_dir"
done

CURRENT_YEAR="$(date +%Y)"
YEAR_1=$(( CURRENT_YEAR - 2 ))
YEAR_2=$(( CURRENT_YEAR - 3 ))
FETCHED_AT="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# Reporter name mapping — bash 3.2 compatible
reporter_name_for() {
  case "$1" in
    158) echo "Taiwan" ;;
    842) echo "United States" ;;
    156) echo "China" ;;
    392) echo "Japan" ;;
    410) echo "South Korea" ;;
    276) echo "Germany" ;;
    *)   echo "Unknown($1)" ;;
  esac
}

# Extract clean per-partner JSONL from raw JSON
# Filters: customsCode=C00, motCode=0, partnerCode!=0 (exclude World aggregate)
extract_partner_jsonl() {
  local raw_file="$1"
  local output_jsonl="$2"
  if [[ -f "$raw_file" ]]; then
    jq -c '.data[]? // empty | select(.customsCode == "C00" and .motCode == 0 and .partnerCode != 0)' \
      "$raw_file" >> "$output_jsonl" 2>/dev/null || true
  fi
}

IFS=',' read -ra REPORTERS <<< "${TRADE_TARGET_REPORTERS:-158,842,156,392,410,276}"

echo "=== bilateral_trade_flows analyze ==="

TOTAL_MD=0
REVIEW_NEEDED_COUNT=0

for reporter in "${REPORTERS[@]}"; do
  reporter_name="$(reporter_name_for "$reporter")"
  echo ""
  echo "--- Analyzing: $reporter_name ($reporter) ---"

  # === 1. Export Flow Analysis ===
  export_jsonl="$(mktemp)"
  export_found=0
  for year in "$YEAR_1" "$YEAR_2"; do
    f="$RAW_DIR/${reporter}-export-${year}.json"
    if [[ -f "$f" ]]; then
      extract_partner_jsonl "$f" "$export_jsonl"
      export_found=1
    fi
  done

  export_count="$(wc -l < "$export_jsonl" | tr -d ' ')"

  if [[ "$export_count" -gt 0 ]]; then
    # Rank by trade value
    tmp_rank="$(mktemp)"
    trade_rank "$export_jsonl" "$tmp_rank" ".primaryValue" ".partnerCode" 20

    partner_count="$(jq '. | length' "$tmp_rank" 2>/dev/null || echo "0")"
    review_flag=""
    confidence="高"

    md_file="$DOCS_DIR/export_flow/${reporter}-export-${YEAR_1}.md"
    {
      echo "# ${review_flag}${reporter_name} — Export Flow Analysis"
      echo ""
      echo "- **Source**: UN Comtrade Preview API"
      echo "- **Reporter**: ${reporter_name} (${reporter})"
      echo "- **Period**: ${YEAR_2}-${YEAR_1}"
      echo "- **Fetched**: ${FETCHED_AT}"
      echo "- **confidence**: ${confidence}"
      echo "- **Partners found**: ${partner_count}"
      echo ""
      echo "## Top Export Partners (by trade value, USD)"
      echo ""
      echo "| Rank | Partner Code | Total Value (USD) | Records |"
      echo "|------|-------------|-------------------|---------|"
      jq -r '.[] | "| \(.rank) | \(.group) | \(.total_value) | \(.record_count) |"' "$tmp_rank" 2>/dev/null || echo "| — | — | — | — |"
      echo ""
      echo "---"
      echo ""
      echo "*Source: UN Comtrade Database, https://comtradeplus.un.org/*"
    } > "$md_file"

    TOTAL_MD=$(( TOTAL_MD + 1 ))
    echo "  export_flow: $md_file ($export_count records, $partner_count partners)"
    rm -f "$tmp_rank"
  elif [[ "$export_found" -eq 1 ]]; then
    # Files exist but 0 records — may need review
    review_flag="[REVIEW_NEEDED] "
    md_file="$DOCS_DIR/export_flow/${reporter}-export-${YEAR_1}.md"
    {
      echo "# ${review_flag}${reporter_name} — Export Flow Analysis"
      echo ""
      echo "- **Source**: UN Comtrade Preview API"
      echo "- **Reporter**: ${reporter_name} (${reporter})"
      echo "- **Period**: ${YEAR_2}-${YEAR_1}"
      echo "- **Fetched**: ${FETCHED_AT}"
      echo "- **confidence**: 低"
      echo ""
      echo "## Data"
      echo ""
      echo "No export records returned by the API for this reporter."
      echo ""
      echo "---"
      echo ""
      echo "*Source: UN Comtrade Database, https://comtradeplus.un.org/*"
    } > "$md_file"
    TOTAL_MD=$(( TOTAL_MD + 1 ))
    REVIEW_NEEDED_COUNT=$(( REVIEW_NEEDED_COUNT + 1 ))
    echo "  export_flow: $md_file (0 records — REVIEW_NEEDED)"
  else
    echo "  export_flow: No raw files found"
  fi
  rm -f "$export_jsonl"

  # === 2. Import Flow Analysis ===
  import_jsonl="$(mktemp)"
  import_found=0
  for year in "$YEAR_1" "$YEAR_2"; do
    f="$RAW_DIR/${reporter}-import-${year}.json"
    if [[ -f "$f" ]]; then
      extract_partner_jsonl "$f" "$import_jsonl"
      import_found=1
    fi
  done

  import_count="$(wc -l < "$import_jsonl" | tr -d ' ')"

  if [[ "$import_count" -gt 0 ]]; then
    tmp_rank="$(mktemp)"
    trade_rank "$import_jsonl" "$tmp_rank" ".primaryValue" ".partnerCode" 20

    partner_count="$(jq '. | length' "$tmp_rank" 2>/dev/null || echo "0")"

    md_file="$DOCS_DIR/import_flow/${reporter}-import-${YEAR_1}.md"
    {
      echo "# ${reporter_name} — Import Flow Analysis"
      echo ""
      echo "- **Source**: UN Comtrade Preview API"
      echo "- **Reporter**: ${reporter_name} (${reporter})"
      echo "- **Period**: ${YEAR_2}-${YEAR_1}"
      echo "- **Fetched**: ${FETCHED_AT}"
      echo "- **confidence**: 高"
      echo "- **Partners found**: ${partner_count}"
      echo ""
      echo "## Top Import Partners (by trade value, USD)"
      echo ""
      echo "| Rank | Partner Code | Total Value (USD) | Records |"
      echo "|------|-------------|-------------------|---------|"
      jq -r '.[] | "| \(.rank) | \(.group) | \(.total_value) | \(.record_count) |"' "$tmp_rank" 2>/dev/null || echo "| — | — | — | — |"
      echo ""
      echo "---"
      echo ""
      echo "*Source: UN Comtrade Database, https://comtradeplus.un.org/*"
    } > "$md_file"

    TOTAL_MD=$(( TOTAL_MD + 1 ))
    echo "  import_flow: $md_file ($import_count records, $partner_count partners)"
    rm -f "$tmp_rank"
  elif [[ "$import_found" -eq 1 ]]; then
    echo "  import_flow: No import records for $reporter_name"
  fi
  rm -f "$import_jsonl"

  # === 3. Trade Balance ===
  combined_jsonl="$(mktemp)"
  for year in "$YEAR_1" "$YEAR_2"; do
    for flow_type in export import; do
      f="$RAW_DIR/${reporter}-${flow_type}-${year}.json"
      if [[ -f "$f" ]]; then
        extract_partner_jsonl "$f" "$combined_jsonl"
      fi
    done
  done

  combined_count="$(wc -l < "$combined_jsonl" | tr -d ' ')"
  if [[ "$combined_count" -gt 0 ]]; then
    tmp_balance="$(mktemp)"
    trade_balance "$combined_jsonl" "$tmp_balance" '.flowCode == "X"' '.flowCode == "M"' ".primaryValue" ".partnerCode"

    md_file="$DOCS_DIR/trade_balance/${reporter}-balance-${YEAR_1}.md"
    {
      echo "# ${reporter_name} — Trade Balance"
      echo ""
      echo "- **Source**: UN Comtrade Preview API"
      echo "- **Reporter**: ${reporter_name} (${reporter})"
      echo "- **Period**: ${YEAR_2}-${YEAR_1}"
      echo "- **Fetched**: ${FETCHED_AT}"
      echo "- **confidence**: 高"
      echo ""
      echo "## Trade Balance by Partner (USD)"
      echo ""
      echo "| Partner Code | Exports | Imports | Balance | Type |"
      echo "|-------------|---------|---------|---------|------|"
      jq -r '.[:30][] | "| \(.group) | \(.exports) | \(.imports) | \(.balance) | \(.balance_type) |"' "$tmp_balance" 2>/dev/null || echo "| — | — | — | — | — |"
      echo ""
      echo "---"
      echo ""
      echo "*Source: UN Comtrade Database, https://comtradeplus.un.org/*"
    } > "$md_file"

    TOTAL_MD=$(( TOTAL_MD + 1 ))
    echo "  trade_balance: $md_file"
    rm -f "$tmp_balance"
  fi
  rm -f "$combined_jsonl"

  # === 4. Market Concentration (HHI) ===
  hhi_jsonl="$(mktemp)"
  for year in "$YEAR_1" "$YEAR_2"; do
    f="$RAW_DIR/${reporter}-export-${year}.json"
    if [[ -f "$f" ]]; then
      extract_partner_jsonl "$f" "$hhi_jsonl"
    fi
  done

  hhi_count="$(wc -l < "$hhi_jsonl" | tr -d ' ')"
  if [[ "$hhi_count" -gt 1 ]]; then
    tmp_hhi="$(mktemp)"
    trade_hhi "$hhi_jsonl" "$tmp_hhi" ".primaryValue" ".partnerCode"

    hhi_value="$(jq -r '.hhi // "N/A"' "$tmp_hhi" 2>/dev/null)"
    concentration="$(jq -r '.concentration // "unknown"' "$tmp_hhi" 2>/dev/null)"
    top3="$(jq -r '.top3_share // "N/A"' "$tmp_hhi" 2>/dev/null)"
    groups="$(jq -r '.groups // 0' "$tmp_hhi" 2>/dev/null)"

    # Boundary check: HHI=10000 with <3 groups is likely data issue
    confidence="高"
    review_flag=""
    if [[ "$groups" -lt 3 ]]; then
      confidence="低"
      review_flag="[REVIEW_NEEDED] "
      REVIEW_NEEDED_COUNT=$(( REVIEW_NEEDED_COUNT + 1 ))
    fi

    md_file="$DOCS_DIR/market_concentration/${reporter}-hhi-${YEAR_1}.md"
    {
      echo "# ${review_flag}${reporter_name} — Market Concentration (Export)"
      echo ""
      echo "- **Source**: UN Comtrade Preview API"
      echo "- **Reporter**: ${reporter_name} (${reporter})"
      echo "- **Period**: ${YEAR_2}-${YEAR_1}"
      echo "- **Fetched**: ${FETCHED_AT}"
      echo "- **confidence**: ${confidence}"
      echo ""
      echo "## HHI Index"
      echo ""
      echo "| Metric | Value |"
      echo "|--------|-------|"
      echo "| HHI | ${hhi_value} |"
      echo "| Concentration Level | ${concentration} |"
      echo "| Top 3 Partners Share | ${top3}% |"
      echo "| Total Partner Groups | ${groups} |"
      echo ""
      echo "### HHI Reference"
      echo ""
      echo "- < 1500: Low concentration (diversified)"
      echo "- 1500-2500: Moderate concentration"
      echo "- > 2500: High concentration (dependent)"
      echo ""
      echo "---"
      echo ""
      echo "*Source: UN Comtrade Database, https://comtradeplus.un.org/*"
    } > "$md_file"

    TOTAL_MD=$(( TOTAL_MD + 1 ))
    echo "  market_concentration: $md_file (HHI=$hhi_value, $concentration, groups=$groups)"
    rm -f "$tmp_hhi"
  else
    echo "  market_concentration: Insufficient data for HHI ($hhi_count records)"
  fi
  rm -f "$hhi_jsonl"

  # === 5. Commodity Structure ===
  # Note: Comtrade Preview API returns cmdCode=TOTAL per partner.
  # To get HS-level breakdown, a commodity-specific query would be needed.
  # We reuse export data and group by partnerCode to show partner composition.
  commodity_jsonl="$(mktemp)"
  for year in "$YEAR_1" "$YEAR_2"; do
    f="$RAW_DIR/${reporter}-export-${year}.json"
    if [[ -f "$f" ]]; then
      extract_partner_jsonl "$f" "$commodity_jsonl"
    fi
  done

  commodity_count="$(wc -l < "$commodity_jsonl" | tr -d ' ')"
  if [[ "$commodity_count" -gt 1 ]]; then
    tmp_share="$(mktemp)"
    trade_market_share "$commodity_jsonl" "$tmp_share" ".primaryValue" ".partnerCode"

    md_file="$DOCS_DIR/commodity_structure/${reporter}-commodity-${YEAR_1}.md"
    {
      echo "# ${reporter_name} — Export Partner Composition"
      echo ""
      echo "- **Source**: UN Comtrade Preview API"
      echo "- **Reporter**: ${reporter_name} (${reporter})"
      echo "- **Period**: ${YEAR_2}-${YEAR_1}"
      echo "- **Fetched**: ${FETCHED_AT}"
      echo "- **confidence**: 高"
      echo ""
      echo "> **Note**: HS commodity-level breakdown is not available from the Preview API."
      echo "> This shows export partner composition (market share by destination)."
      echo ""
      echo "## Top Export Destinations (by value share)"
      echo ""
      echo "| Partner Code | Total Value (USD) | Share (%) |"
      echo "|-------------|-------------------|-----------|"
      jq -r '.[:20][] | "| \(.group) | \(.total_value) | \(.share_pct)% |"' "$tmp_share" 2>/dev/null || echo "| — | — | — |"
      echo ""
      echo "---"
      echo ""
      echo "*Source: UN Comtrade Database, https://comtradeplus.un.org/*"
    } > "$md_file"

    TOTAL_MD=$(( TOTAL_MD + 1 ))
    echo "  commodity_structure: $md_file (partner composition)"
    rm -f "$tmp_share"
  else
    echo "  commodity_structure: Insufficient data ($commodity_count records)"
  fi
  rm -f "$commodity_jsonl"
done

echo ""
echo "=== Analyze Summary ==="
echo "Total .md files generated: $TOTAL_MD"
echo "REVIEW_NEEDED flags: $REVIEW_NEEDED_COUNT"
echo "Analyze completed: $LAYER_NAME"
