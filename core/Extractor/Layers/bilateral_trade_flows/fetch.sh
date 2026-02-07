#!/bin/bash
# bilateral_trade_flows 資料擷取腳本（Type A — API）
# 從 UN Comtrade Preview API 擷取雙邊貿易數據

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/trade_api.sh"

LAYER_NAME="bilateral_trade_flows"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"
BASE_URL="${COMTRADE_BASE_URL:-https://comtradeapi.un.org/public/v1}"

mkdir -p "$RAW_DIR"

# Target reporters from env (comma-separated ISO codes)
IFS=',' read -ra REPORTERS <<< "${TRADE_TARGET_REPORTERS:-158,842,156,392,410,276}"

# UN Comtrade reporter code mapping
# Taiwan (ISO 158) is not available as reporter in Comtrade due to UN political restrictions.
# Use code 490 ("Other Asia, nes") which contains Taiwan's trade data.
comtrade_reporter_code() {
  local code="$1"
  case "$code" in
    158) echo "490" ;;  # Taiwan → Other Asia, nes
    *)   echo "$code" ;;
  esac
}

# Comtrade Preview API only allows ONE period per request
CURRENT_YEAR="$(date +%Y)"
YEARS=( $(( CURRENT_YEAR - 2 )) $(( CURRENT_YEAR - 3 )) )

# Flow codes
FLOWS=("X" "M")  # X=Export, M=Import

echo "=== bilateral_trade_flows fetch ==="
echo "Reporters: ${REPORTERS[*]}"
echo "Note: Taiwan (158) mapped to Comtrade code 490"
echo "Years: ${YEARS[*]}"
echo "Flows: ${FLOWS[*]}"
echo ""

FETCH_COUNT=0
ERROR_COUNT=0

for reporter in "${REPORTERS[@]}"; do
  # Map reporter code for Comtrade API (e.g. Taiwan 158 → 490)
  api_reporter=$(comtrade_reporter_code "$reporter")

  for flow in "${FLOWS[@]}"; do
    flow_name="export"
    [[ "$flow" == "M" ]] && flow_name="import"

    for year in "${YEARS[@]}"; do
      # Output file uses original reporter code (158) for consistency
      output_file="$RAW_DIR/${reporter}-${flow_name}-${year}.json"

      # UN Comtrade Preview API: single period per request
      # Omit partnerCode to get per-partner breakdown (partnerCode=0 returns only World aggregate)
      url="${BASE_URL}/preview/C/A/HS?reporterCode=${api_reporter}&period=${year}&flowCode=${flow}"

      if [[ "$reporter" != "$api_reporter" ]]; then
        echo "Fetching: reporter=$reporter (API code=$api_reporter) flow=$flow_name year=$year"
      else
        echo "Fetching: reporter=$reporter flow=$flow_name year=$year"
      fi

      if trade_api_fetch "$url" "$output_file" 3600; then
        # Validate JSON
        if jq empty "$output_file" 2>/dev/null; then
          record_count="$(jq '.data | length // 0' "$output_file" 2>/dev/null || echo "0")"
          echo "  OK: $record_count records -> $output_file"
          FETCH_COUNT=$(( FETCH_COUNT + 1 ))
        else
          echo "  WARNING: Invalid JSON for reporter=$reporter flow=$flow_name year=$year" >&2
          ERROR_COUNT=$(( ERROR_COUNT + 1 ))
          rm -f "$output_file"
        fi
      else
        echo "  ERROR: Failed reporter=$reporter flow=$flow_name year=$year" >&2
        ERROR_COUNT=$(( ERROR_COUNT + 1 ))
      fi

      # Rate limit: Comtrade ~100 requests/minute for preview
      sleep 1
    done
  done
done

# Write timestamp
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$RAW_DIR/.last_fetch"

echo ""
echo "=== Fetch Summary ==="
echo "Successful: $FETCH_COUNT"
echo "Errors: $ERROR_COUNT"
echo "Fetch completed: $LAYER_NAME"
