#!/bin/bash
# us_trade_census 數據分析腳本（Type A — jq 計算）
# 讀取 Census API 回傳的 JSON，產出月度貿易分析 Markdown

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/trade_analysis.sh"

LAYER_NAME="us_trade_census"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

for cat in monthly_export monthly_import trade_balance country_detail; do
  mkdir -p "$DOCS_DIR/$cat"
done

FETCHED_AT="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
CURRENT_YEAR="$(date +%Y)"

echo "=== us_trade_census analyze ==="

TOTAL_MD=0

# Census API returns data as JSON array where first element is headers
# Convert to JSONL with named fields

convert_census_json() {
  local input_file="$1"
  local output_jsonl="$2"

  if [[ ! -f "$input_file" ]]; then
    return 1
  fi

  # Census format: [[header1, header2, ...], [val1, val2, ...], ...]
  jq -c '
    if type == "array" and length > 1 then
      .[0] as $headers |
      .[1:][] |
      . as $row |
      [range(0; $headers | length)] |
      map({key: $headers[.], value: $row[.]}) |
      from_entries
    else empty end
  ' "$input_file" > "$output_jsonl" 2>/dev/null || return 1
}

# Process exports
for raw_file in "$RAW_DIR"/exports-*.json; do
  [[ -f "$raw_file" ]] || continue

  cty_code="$(basename "$raw_file" | sed 's/exports-\([0-9]*\)-.*/\1/')"
  tmp_jsonl="$(mktemp)"

  if convert_census_json "$raw_file" "$tmp_jsonl"; then
    record_count="$(wc -l < "$tmp_jsonl" | tr -d ' ')"

    if [[ "$record_count" -gt 0 ]]; then
      cty_name="$(jq -r '.CTY_NAME // "Unknown"' "$tmp_jsonl" | head -1)"

      md_file="$DOCS_DIR/monthly_export/us-export-${cty_code}-${CURRENT_YEAR}.md"
      {
        echo "# United States — Monthly Exports to ${cty_name}"
        echo ""
        echo "- **Source**: US Census Bureau International Trade API"
        echo "- **Partner**: ${cty_name} (${cty_code})"
        echo "- **Fetched**: ${FETCHED_AT}"
        echo "- **confidence**: 高"
        echo ""
        echo "## Export Data by HS2 Commodity"
        echo ""
        echo "| HS2 Code | Description | Total Value (USD) | Months |"
        echo "|----------|-------------|-------------------|--------|"
        jq -sr '
          [ .[] | select(.ALL_VAL_MO != null and .ALL_VAL_MO != "0") ] |
          group_by(.E_COMMODITY) |
          map({
            hs_code: .[0].E_COMMODITY,
            description: (.[0].E_COMMODITY_LDESC // "N/A" | .[0:60]),
            total_value: (map(.ALL_VAL_MO | tonumber? // 0) | add),
            months: length
          }) |
          sort_by(-.total_value) |
          .[:20][] |
          "| \(.hs_code) | \(.description) | \(.total_value) | \(.months) |"
        ' "$tmp_jsonl" 2>/dev/null || echo "| — | — | — | — |"
        echo ""
        echo "---"
        echo ""
        echo "*Source: U.S. Census Bureau, https://www.census.gov/foreign-trade/*"
      } > "$md_file"

      TOTAL_MD=$(( TOTAL_MD + 1 ))
      echo "  monthly_export: $md_file ($record_count records)"
    fi
  fi
  rm -f "$tmp_jsonl"
done

# Process imports
for raw_file in "$RAW_DIR"/imports-*.json; do
  [[ -f "$raw_file" ]] || continue

  cty_code="$(basename "$raw_file" | sed 's/imports-\([0-9]*\)-.*/\1/')"
  tmp_jsonl="$(mktemp)"

  if convert_census_json "$raw_file" "$tmp_jsonl"; then
    record_count="$(wc -l < "$tmp_jsonl" | tr -d ' ')"

    if [[ "$record_count" -gt 0 ]]; then
      cty_name="$(jq -r '.CTY_NAME // "Unknown"' "$tmp_jsonl" | head -1)"

      md_file="$DOCS_DIR/monthly_import/us-import-${cty_code}-${CURRENT_YEAR}.md"
      {
        echo "# United States — Monthly Imports from ${cty_name}"
        echo ""
        echo "- **Source**: US Census Bureau International Trade API"
        echo "- **Partner**: ${cty_name} (${cty_code})"
        echo "- **Fetched**: ${FETCHED_AT}"
        echo "- **confidence**: 高"
        echo ""
        echo "## Import Data by HS2 Commodity"
        echo ""
        echo "| HS2 Code | Description | Total Value (USD) | Months |"
        echo "|----------|-------------|-------------------|--------|"
        jq -sr '
          [ .[] | select(.GEN_VAL_MO != null and .GEN_VAL_MO != "0") ] |
          group_by(.I_COMMODITY) |
          map({
            hs_code: .[0].I_COMMODITY,
            description: (.[0].I_COMMODITY_LDESC // "N/A" | .[0:60]),
            total_value: (map(.GEN_VAL_MO | tonumber? // 0) | add),
            months: length
          }) |
          sort_by(-.total_value) |
          .[:20][] |
          "| \(.hs_code) | \(.description) | \(.total_value) | \(.months) |"
        ' "$tmp_jsonl" 2>/dev/null || echo "| — | — | — | — |"
        echo ""
        echo "---"
        echo ""
        echo "*Source: U.S. Census Bureau, https://www.census.gov/foreign-trade/*"
      } > "$md_file"

      TOTAL_MD=$(( TOTAL_MD + 1 ))
      echo "  monthly_import: $md_file ($record_count records)"
    fi
  fi
  rm -f "$tmp_jsonl"
done

# 3. Trade Balance (export - import per country)
for export_file in "$RAW_DIR"/exports-*.json; do
  [[ -f "$export_file" ]] || continue

  cty_code="$(basename "$export_file" | sed 's/exports-\([0-9]*\)-.*/\1/')"
  import_file="$RAW_DIR/imports-${cty_code}-${CURRENT_YEAR}.json"
  [[ -f "$import_file" ]] || continue

  exp_jsonl="$(mktemp)"
  imp_jsonl="$(mktemp)"

  if convert_census_json "$export_file" "$exp_jsonl" && \
     convert_census_json "$import_file" "$imp_jsonl"; then

    exp_count="$(wc -l < "$exp_jsonl" | tr -d ' ')"
    imp_count="$(wc -l < "$imp_jsonl" | tr -d ' ')"

    if [[ "$exp_count" -gt 0 ]] && [[ "$imp_count" -gt 0 ]]; then
      cty_name="$(jq -r '.CTY_NAME // "Unknown"' "$exp_jsonl" | head -1)"

      # Aggregate exports by HS2
      exp_agg="$(mktemp)"
      jq -s '[
        .[] | select(.ALL_VAL_MO != null and .ALL_VAL_MO != "0")
      ] | group_by(.E_COMMODITY) | map({
        hs: .[0].E_COMMODITY,
        desc: (.[0].E_COMMODITY_LDESC // "N/A" | .[0:60]),
        val: (map(.ALL_VAL_MO | tonumber? // 0) | add)
      })' "$exp_jsonl" > "$exp_agg" 2>/dev/null

      # Aggregate imports by HS2
      imp_agg="$(mktemp)"
      jq -s '[
        .[] | select(.GEN_VAL_MO != null and .GEN_VAL_MO != "0")
      ] | group_by(.I_COMMODITY) | map({
        hs: .[0].I_COMMODITY,
        desc: (.[0].I_COMMODITY_LDESC // "N/A" | .[0:60]),
        val: (map(.GEN_VAL_MO | tonumber? // 0) | add)
      })' "$imp_jsonl" > "$imp_agg" 2>/dev/null

      # --- trade_balance ---
      md_file="$DOCS_DIR/trade_balance/us-balance-${cty_code}-${CURRENT_YEAR}.md"
      {
        echo "# United States — Trade Balance with ${cty_name}"
        echo ""
        echo "- **Source**: US Census Bureau International Trade API"
        echo "- **Partner**: ${cty_name} (${cty_code})"
        echo "- **Fetched**: ${FETCHED_AT}"
        echo "- **confidence**: 高"
        echo ""
        echo "## Trade Balance by HS2 Commodity (Top 20 by |Balance|)"
        echo ""
        echo "| HS2 | Description | Export (USD) | Import (USD) | Balance (USD) | Type |"
        echo "|-----|-------------|-------------|-------------|--------------|------|"
        jq -r --slurpfile imp "$imp_agg" '
          ($imp[0] | map({key: .hs, value: .val}) | from_entries) as $imap |
          ($imp[0] | map({key: .hs, value: .desc}) | from_entries) as $idesc |
          ([.[].hs] + [$imp[0][].hs] | unique) as $all_hs |
          (. | map({key: .hs, value: .val}) | from_entries) as $emap |
          (. | map({key: .hs, value: .desc}) | from_entries) as $edesc |
          [
            $all_hs[] |
            . as $hs |
            {
              hs: $hs,
              desc: ($edesc[$hs] // $idesc[$hs] // "N/A"),
              exp: ($emap[$hs] // 0),
              imp: ($imap[$hs] // 0),
              bal: (($emap[$hs] // 0) - ($imap[$hs] // 0))
            }
          ] |
          sort_by(-(if .bal < 0 then -.bal else .bal end)) |
          .[:20][] |
          "| \(.hs) | \(.desc) | \(.exp) | \(.imp) | \(.bal) | \(if .bal >= 0 then "Surplus" else "Deficit" end) |"
        ' "$exp_agg" 2>/dev/null || echo "| — | — | — | — | — | — |"
        echo ""
        echo "---"
        echo ""
        echo "*Source: U.S. Census Bureau, https://www.census.gov/foreign-trade/*"
      } > "$md_file"
      TOTAL_MD=$(( TOTAL_MD + 1 ))
      echo "  trade_balance: $md_file"

      # --- country_detail ---
      md_file="$DOCS_DIR/country_detail/us-detail-${cty_code}-${CURRENT_YEAR}.md"
      {
        echo "# United States — Trade Detail with ${cty_name}"
        echo ""
        echo "- **Source**: US Census Bureau International Trade API"
        echo "- **Partner**: ${cty_name} (${cty_code})"
        echo "- **Fetched**: ${FETCHED_AT}"
        echo "- **confidence**: 高"
        echo ""
        total_exp="$(jq '[.[].val] | add // 0 | floor' "$exp_agg" 2>/dev/null || echo 0)"
        total_imp="$(jq '[.[].val] | add // 0 | floor' "$imp_agg" 2>/dev/null || echo 0)"
        balance=$(( total_exp - total_imp ))
        bal_type="Surplus"
        [[ "$balance" -lt 0 ]] && bal_type="Deficit"
        echo "## Summary"
        echo ""
        echo "| Metric | Value (USD) |"
        echo "|--------|------------|"
        echo "| Total Exports | ${total_exp} |"
        echo "| Total Imports | ${total_imp} |"
        echo "| Trade Balance | ${balance} (${bal_type}) |"
        echo ""
        echo "## Top 10 Export Commodities"
        echo ""
        echo "| HS2 | Description | Value (USD) |"
        echo "|-----|-------------|------------|"
        jq -r 'sort_by(-.val) | .[:10][] | "| \(.hs) | \(.desc) | \(.val) |"' "$exp_agg" 2>/dev/null || echo "| — | — | — |"
        echo ""
        echo "## Top 10 Import Commodities"
        echo ""
        echo "| HS2 | Description | Value (USD) |"
        echo "|-----|-------------|------------|"
        jq -r 'sort_by(-.val) | .[:10][] | "| \(.hs) | \(.desc) | \(.val) |"' "$imp_agg" 2>/dev/null || echo "| — | — | — |"
        echo ""
        echo "---"
        echo ""
        echo "*Source: U.S. Census Bureau, https://www.census.gov/foreign-trade/*"
      } > "$md_file"
      TOTAL_MD=$(( TOTAL_MD + 1 ))
      echo "  country_detail: $md_file"

      rm -f "$exp_agg" "$imp_agg"
    fi
  fi
  rm -f "$exp_jsonl" "$imp_jsonl"
done

# ===== 備用路徑：處理 balance-*.json (HTML 解析來源) =====
for raw_file in "$RAW_DIR"/balance-*.json; do
  [[ -f "$raw_file" ]] || continue

  # 檢查是否為備用格式 (有 .data 陣列)
  if ! jq -e '.data' "$raw_file" >/dev/null 2>&1; then
    continue
  fi

  cty_code="$(jq -r '.country_code' "$raw_file")"
  cty_name="$(jq -r '.country_name' "$raw_file")"
  record_count="$(jq '.record_count // (.data | length)' "$raw_file")"

  echo "  Processing balance fallback: $cty_name ($cty_code)"

  # 1. Monthly Export (聚合)
  md_file="$DOCS_DIR/monthly_export/us-export-${cty_code}-${CURRENT_YEAR}.md"
  {
    echo "# United States — Monthly Exports to ${cty_name}"
    echo ""
    echo "- **Source**: US Census Bureau (Balance Summary)"
    echo "- **Source URL**: $(jq -r '.source_url' "$raw_file")"
    echo "- **Partner**: ${cty_name} (${cty_code})"
    echo "- **Fetched**: ${FETCHED_AT}"
    echo "- **confidence**: 中 (彙總數據，無 HS 商品明細)"
    echo ""
    echo "## Monthly Export Data"
    echo ""
    echo "| Year | Month | Exports (Million USD) |"
    echo "|------|-------|----------------------|"
    jq -r '.data | sort_by(.year, .month) | reverse | .[:24][] |
      "| \(.year) | \(.month) | \(.exports_millions_usd) |"
    ' "$raw_file" 2>/dev/null || echo "| — | — | — |"
    echo ""
    echo "---"
    echo "*Source: U.S. Census Bureau, https://www.census.gov/foreign-trade/*"
  } > "$md_file"
  TOTAL_MD=$(( TOTAL_MD + 1 ))
  echo "    monthly_export: $md_file"

  # 2. Monthly Import (聚合)
  md_file="$DOCS_DIR/monthly_import/us-import-${cty_code}-${CURRENT_YEAR}.md"
  {
    echo "# United States — Monthly Imports from ${cty_name}"
    echo ""
    echo "- **Source**: US Census Bureau (Balance Summary)"
    echo "- **Source URL**: $(jq -r '.source_url' "$raw_file")"
    echo "- **Partner**: ${cty_name} (${cty_code})"
    echo "- **Fetched**: ${FETCHED_AT}"
    echo "- **confidence**: 中 (彙總數據，無 HS 商品明細)"
    echo ""
    echo "## Monthly Import Data"
    echo ""
    echo "| Year | Month | Imports (Million USD) |"
    echo "|------|-------|----------------------|"
    jq -r '.data | sort_by(.year, .month) | reverse | .[:24][] |
      "| \(.year) | \(.month) | \(.imports_millions_usd) |"
    ' "$raw_file" 2>/dev/null || echo "| — | — | — |"
    echo ""
    echo "---"
    echo "*Source: U.S. Census Bureau, https://www.census.gov/foreign-trade/*"
  } > "$md_file"
  TOTAL_MD=$(( TOTAL_MD + 1 ))
  echo "    monthly_import: $md_file"

  # 3. Trade Balance
  md_file="$DOCS_DIR/trade_balance/us-balance-${cty_code}-${CURRENT_YEAR}.md"
  {
    echo "# United States — Trade Balance with ${cty_name}"
    echo ""
    echo "- **Source**: US Census Bureau (Balance Summary)"
    echo "- **Source URL**: $(jq -r '.source_url' "$raw_file")"
    echo "- **Partner**: ${cty_name} (${cty_code})"
    echo "- **Fetched**: ${FETCHED_AT}"
    echo "- **confidence**: 高"
    echo ""
    echo "## Monthly Trade Balance"
    echo ""
    echo "| Year | Month | Export (M USD) | Import (M USD) | Balance (M USD) | Type |"
    echo "|------|-------|----------------|----------------|-----------------|------|"
    jq -r '.data | sort_by(.year, .month) | reverse | .[:24][] |
      "| \(.year) | \(.month) | \(.exports_millions_usd) | \(.imports_millions_usd) | \(.balance_millions_usd) | \(if .balance_millions_usd >= 0 then "Surplus" else "Deficit" end) |"
    ' "$raw_file" 2>/dev/null || echo "| — | — | — | — | — | — |"
    echo ""
    echo "---"
    echo "*Source: U.S. Census Bureau, https://www.census.gov/foreign-trade/*"
  } > "$md_file"
  TOTAL_MD=$(( TOTAL_MD + 1 ))
  echo "    trade_balance: $md_file"

  # 4. Country Detail (年度彙整)
  md_file="$DOCS_DIR/country_detail/us-detail-${cty_code}-${CURRENT_YEAR}.md"
  {
    echo "# United States — Trade Detail with ${cty_name}"
    echo ""
    echo "- **Source**: US Census Bureau (Balance Summary)"
    echo "- **Source URL**: $(jq -r '.source_url' "$raw_file")"
    echo "- **Partner**: ${cty_name} (${cty_code})"
    echo "- **Fetched**: ${FETCHED_AT}"
    echo "- **confidence**: 高"
    echo ""
    echo "## Annual Summary"
    echo ""
    echo "| Year | Total Export (M USD) | Total Import (M USD) | Balance (M USD) |"
    echo "|------|---------------------|---------------------|-----------------|"
    jq -r '.data | group_by(.year) | map({
      year: .[0].year,
      exp: (map(.exports_millions_usd) | add | . * 10 | floor / 10),
      imp: (map(.imports_millions_usd) | add | . * 10 | floor / 10),
      bal: (map(.balance_millions_usd) | add | . * 10 | floor / 10)
    }) | sort_by(-.year) | .[:5][] |
      "| \(.year) | \(.exp) | \(.imp) | \(.bal) |"
    ' "$raw_file" 2>/dev/null || echo "| — | — | — | — |"
    echo ""
    echo "## Notes"
    echo ""
    echo "- Data from fallback source (balance summary pages)"
    echo "- Does not include HS commodity breakdown"
    echo "- Primary API (api.census.gov) was unavailable during fetch"
    echo ""
    echo "---"
    echo "*Source: U.S. Census Bureau, https://www.census.gov/foreign-trade/*"
  } > "$md_file"
  TOTAL_MD=$(( TOTAL_MD + 1 ))
  echo "    country_detail: $md_file"

done

echo ""
echo "=== Analyze Summary ==="
echo "Total .md files generated: $TOTAL_MD"
echo "Analyze completed: $LAYER_NAME"
