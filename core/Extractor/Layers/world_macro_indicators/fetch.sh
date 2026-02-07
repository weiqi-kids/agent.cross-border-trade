#!/bin/bash
# world_macro_indicators 資料擷取腳本（Type A — API）
# 從 World Bank API 擷取宏觀經濟指標

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/trade_api.sh"

LAYER_NAME="world_macro_indicators"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"
BASE_URL="${WORLDBANK_API_BASE:-https://api.worldbank.org/v2}"

mkdir -p "$RAW_DIR"

# Target countries (ISO3, semicolon-separated for World Bank API)
COUNTRIES_PARAM="USA;CHN;JPN;KOR;DEU;TWN"
# Note: Taiwan (TWN) has limited World Bank coverage — API may return partial/empty data

# Indicators — bash 3.2 compatible (parallel arrays instead of declare -A)
INDICATOR_CODES=("NE.TRD.GNFS.ZS" "NY.GDP.MKTP.CD" "NY.GDP.MKTP.KD.ZG" "BN.CAB.XOKA.CD")
INDICATOR_NAMES=("trade_gdp_ratio" "gdp_nominal" "gdp_growth" "current_account")

CURRENT_YEAR="$(date +%Y)"
DATE_RANGE="2018:${CURRENT_YEAR}"

echo "=== world_macro_indicators fetch ==="

FETCH_COUNT=0
ERROR_COUNT=0

# Fetch each indicator for all countries at once
for i in "${!INDICATOR_CODES[@]}"; do
  indicator="${INDICATOR_CODES[$i]}"
  indicator_name="${INDICATOR_NAMES[$i]}"

  output_file="$RAW_DIR/${indicator_name}-${CURRENT_YEAR}.json"

  url="${BASE_URL}/country/${COUNTRIES_PARAM}/indicator/${indicator}?format=json&date=${DATE_RANGE}&per_page=500"

  echo "Fetching: $indicator_name ($indicator)"

  if trade_api_fetch "$url" "$output_file" 86400; then
    # World Bank API returns [metadata, data] array
    if jq -e '.[1]' "$output_file" >/dev/null 2>&1; then
      record_count="$(jq '.[1] | length' "$output_file" 2>/dev/null || echo 0)"
      echo "  OK: $record_count records → $output_file"
      FETCH_COUNT=$(( FETCH_COUNT + 1 ))
    else
      echo "  WARNING: Unexpected response format for $indicator_name" >&2
      ERROR_COUNT=$(( ERROR_COUNT + 1 ))
    fi
  else
    echo "  ERROR: Failed to fetch $indicator_name" >&2
    ERROR_COUNT=$(( ERROR_COUNT + 1 ))
  fi

  sleep 1
done

# Also try Taiwan from alternative endpoint
echo ""
echo "Note: Taiwan (TWN) has limited World Bank coverage."
echo "Consider cross-referencing with national statistics."

date -u '+%Y-%m-%dT%H:%M:%SZ' > "$RAW_DIR/.last_fetch"

echo ""
echo "=== Fetch Summary ==="
echo "Successful: $FETCH_COUNT"
echo "Errors: $ERROR_COUNT"
echo "Fetch completed: $LAYER_NAME"
