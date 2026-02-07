#!/bin/bash
# world_macro_indicators 數據分析腳本（Type A — jq 計算）
# 讀取 World Bank API 回傳的 JSON，產出宏觀指標分析 Markdown

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/trade_analysis.sh"

LAYER_NAME="world_macro_indicators"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

for cat_dir in trade_gdp_ratio trade_openness gdp_growth current_account; do
  mkdir -p "$DOCS_DIR/$cat_dir"
done

FETCHED_AT="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
CURRENT_YEAR="$(date +%Y)"

echo "=== world_macro_indicators analyze ==="

TOTAL_MD=0

# World Bank API returns: [metadata, [data_array]]
# Each data item: {indicator, country, countryiso3code, date, value, ...}

# Bash 3.2 compatible mappings (no declare -A)
category_description_for() {
  case "$1" in
    trade_gdp_ratio)  echo "Trade (% of GDP)" ;;
    gdp_nominal)      echo "GDP (current USD)" ;;
    gdp_growth)       echo "GDP Growth (%)" ;;
    current_account)  echo "Current Account Balance (USD)" ;;
    *)                echo "$1" ;;
  esac
}

category_dir_for() {
  case "$1" in
    trade_gdp_ratio)  echo "trade_gdp_ratio" ;;
    gdp_nominal)      echo "trade_openness" ;;
    gdp_growth)       echo "gdp_growth" ;;
    current_account)  echo "current_account" ;;
    *)                echo "$1" ;;
  esac
}

for raw_file in "$RAW_DIR"/*-${CURRENT_YEAR}.json; do
  [[ -f "$raw_file" ]] || continue

  indicator_name="$(basename "$raw_file" "-${CURRENT_YEAR}.json")"
  category="$(category_dir_for "$indicator_name")"
  description="$(category_description_for "$indicator_name")"

  echo "Processing: $indicator_name -> $category"

  # Extract data array from World Bank response format [metadata, data]
  tmp_jsonl="$(mktemp)"
  jq -c '.[1][]? // empty' "$raw_file" > "$tmp_jsonl" 2>/dev/null || true
  record_count="$(wc -l < "$tmp_jsonl" | tr -d ' ')"

  if [[ "$record_count" -gt 0 ]]; then
    # Group by country and generate per-country analysis
    countries="$(jq -r '.countryiso3code' "$tmp_jsonl" 2>/dev/null | sort -u)"

    for country in $countries; do
      country_name="$(jq -r "select(.countryiso3code == \"$country\") | .country.value" "$tmp_jsonl" 2>/dev/null | head -1)"

      md_file="$DOCS_DIR/$category/${country}-${indicator_name}-${CURRENT_YEAR}.md"
      {
        echo "# ${country_name} — ${description}"
        echo ""
        echo "- **Source**: World Bank API v2"
        echo "- **Country**: ${country_name} (${country})"
        echo "- **Indicator**: ${indicator_name}"
        echo "- **Fetched**: ${FETCHED_AT}"
        echo "- **confidence**: 高"
        echo ""
        echo "## Time Series"
        echo ""
        echo "| Year | Value |"
        echo "|------|-------|"
        jq -r "select(.countryiso3code == \"$country\" and .value != null) | \"| \(.date) | \(.value) |\"" "$tmp_jsonl" 2>/dev/null | sort || echo "| — | — |"
        echo ""
        echo "---"
        echo ""
        echo "*Source: World Bank Open Data, https://data.worldbank.org/*"
      } > "$md_file"

      TOTAL_MD=$(( TOTAL_MD + 1 ))
    done

    echo "  Generated: $(echo "$countries" | wc -w | tr -d ' ') country files"
  else
    echo "  No data found in $raw_file"
  fi

  rm -f "$tmp_jsonl"
done

echo ""
echo "=== Analyze Summary ==="
echo "Total .md files generated: $TOTAL_MD"
echo "Analyze completed: $LAYER_NAME"
