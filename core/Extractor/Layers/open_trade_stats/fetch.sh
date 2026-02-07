#!/bin/bash
# open_trade_stats 資料擷取腳本（Type A — API）
# 從 Open Trade Statistics API 擷取 HS6 級別貿易數據

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/trade_api.sh"

LAYER_NAME="open_trade_stats"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"
BASE_URL="${OTS_API_BASE:-https://api.tradestatistics.io}"

mkdir -p "$RAW_DIR"

# Target countries (ISO3 lowercase for OTS API)
COUNTRIES=("usa" "chn" "jpn" "kor" "deu")
# Note: OTS may not have Taiwan (twn) data; try separately

CURRENT_YEAR="$(date +%Y)"
# OTS data typically available up to 3 years ago (e.g. in 2026, latest is 2023)
# Try year-2 first; if API returns 500 or empty, fallback to year-3
YEAR=$(( CURRENT_YEAR - 2 ))
FALLBACK_YEAR=$(( CURRENT_YEAR - 3 ))

# Quick probe: test if YEAR data is available
probe_url="${BASE_URL}/yr?y=${YEAR}&r=usa"
probe_file=$(mktemp)
if trade_api_fetch "$probe_url" "$probe_file" 3600 2>/dev/null; then
  if [[ -s "$probe_file" ]] && jq -e '.[0]' "$probe_file" >/dev/null 2>&1; then
    echo "OTS data available for $YEAR"
  else
    echo "OTS data not yet available for $YEAR, falling back to $FALLBACK_YEAR"
    YEAR=$FALLBACK_YEAR
  fi
else
  echo "OTS probe failed for $YEAR, falling back to $FALLBACK_YEAR"
  YEAR=$FALLBACK_YEAR
fi
rm -f "$probe_file"

echo "=== open_trade_stats fetch ==="
echo "Year: $YEAR"
echo "Countries: ${COUNTRIES[*]}"
echo ""

FETCH_COUNT=0
ERROR_COUNT=0

# 1. Fetch country profiles (yr endpoint)
echo "--- Country Profiles (yr) ---"
for country in "${COUNTRIES[@]}"; do
  output_file="$RAW_DIR/yr-${country}-${YEAR}.json"
  url="${BASE_URL}/yr?y=${YEAR}&r=${country}"

  echo "Fetching country profile: $country ($YEAR)"

  if trade_api_fetch "$url" "$output_file" 86400; then
    if [[ -s "$output_file" ]] && jq empty "$output_file" 2>/dev/null; then
      echo "  OK -> $output_file"
      FETCH_COUNT=$(( FETCH_COUNT + 1 ))
    else
      echo "  WARNING: Empty or invalid response for $country" >&2
      ERROR_COUNT=$(( ERROR_COUNT + 1 ))
      rm -f "$output_file"
    fi
  else
    echo "  ERROR: Failed to fetch profile for $country" >&2
    ERROR_COUNT=$(( ERROR_COUNT + 1 ))
  fi

  sleep 1
done

# Try Taiwan separately (may not be available)
echo "Fetching country profile: twn ($YEAR) [may not be available]"
twn_output="$RAW_DIR/yr-twn-${YEAR}.json"
twn_url="${BASE_URL}/yr?y=${YEAR}&r=twn"
if trade_api_fetch "$twn_url" "$twn_output" 86400; then
  if [[ -s "$twn_output" ]] && jq empty "$twn_output" 2>/dev/null; then
    echo "  OK -> $twn_output"
    FETCH_COUNT=$(( FETCH_COUNT + 1 ))
  else
    echo "  INFO: Taiwan data not available in OTS" >&2
    rm -f "$twn_output"
  fi
else
  echo "  INFO: Taiwan data not available in OTS" >&2
fi
sleep 1

# 2. Fetch bilateral flows for key pairs (yrp endpoint)
echo ""
echo "--- Bilateral Flows (yrp) ---"
KEY_PAIRS=(
  "usa:chn" "usa:jpn" "usa:kor" "usa:deu"
  "chn:jpn" "chn:kor" "chn:deu"
  "jpn:kor" "jpn:deu"
)

for pair in "${KEY_PAIRS[@]}"; do
  reporter="${pair%%:*}"
  partner="${pair##*:}"
  output_file="$RAW_DIR/yrp-${reporter}-${partner}-${YEAR}.json"
  url="${BASE_URL}/yrp?y=${YEAR}&r=${reporter}&p=${partner}"

  echo "Fetching bilateral: $reporter -> $partner ($YEAR)"

  if trade_api_fetch "$url" "$output_file" 86400; then
    if [[ -s "$output_file" ]] && jq empty "$output_file" 2>/dev/null; then
      echo "  OK -> $output_file"
      FETCH_COUNT=$(( FETCH_COUNT + 1 ))
    else
      echo "  WARNING: Empty or invalid response" >&2
      ERROR_COUNT=$(( ERROR_COUNT + 1 ))
      rm -f "$output_file"
    fi
  else
    echo "  ERROR: Failed to fetch ${reporter}->${partner}" >&2
    ERROR_COUNT=$(( ERROR_COUNT + 1 ))
  fi

  sleep 1
done

# 3. Fetch commodity structure for target countries (yrc endpoint)
echo ""
echo "--- Commodity Structure (yrc) ---"
for country in "${COUNTRIES[@]}"; do
  output_file="$RAW_DIR/yrc-${country}-${YEAR}.json"
  url="${BASE_URL}/yrc?y=${YEAR}&r=${country}"

  echo "Fetching commodity structure: $country ($YEAR)"

  if trade_api_fetch "$url" "$output_file" 86400; then
    if [[ -s "$output_file" ]] && jq empty "$output_file" 2>/dev/null; then
      echo "  OK -> $output_file"
      FETCH_COUNT=$(( FETCH_COUNT + 1 ))
    else
      echo "  WARNING: Empty or invalid response" >&2
      ERROR_COUNT=$(( ERROR_COUNT + 1 ))
      rm -f "$output_file"
    fi
  else
    echo "  ERROR: Failed to fetch commodities for $country" >&2
    ERROR_COUNT=$(( ERROR_COUNT + 1 ))
  fi

  sleep 1
done

date -u '+%Y-%m-%dT%H:%M:%SZ' > "$RAW_DIR/.last_fetch"

echo ""
echo "=== Fetch Summary ==="
echo "Successful: $FETCH_COUNT"
echo "Errors: $ERROR_COUNT"
echo "Fetch completed: $LAYER_NAME"
