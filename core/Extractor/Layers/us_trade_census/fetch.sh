#!/bin/bash
# us_trade_census 資料擷取腳本（Type A — API）
# 從 US Census Bureau 擷取月度貿易數據
#
# 資料來源優先順序：
# 1. api.census.gov (主 API，含 HS 商品明細)
# 2. www.census.gov/foreign-trade/balance (備用，國家彙總數據)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/trade_api.sh"

LAYER_NAME="us_trade_census"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"
BASE_URL="${CENSUS_API_BASE:-https://api.census.gov/data/timeseries/intltrade}"
FALLBACK_URL="https://www.census.gov/foreign-trade/balance"

mkdir -p "$RAW_DIR"

CURRENT_YEAR="$(date +%Y)"
PREV_YEAR=$(( CURRENT_YEAR - 1 ))

PARTNER_CODES=(5830 5700 5800 5880 4280)
PARTNER_NAMES=("Taiwan" "China" "South Korea" "Japan" "Germany")

echo "=== us_trade_census fetch ==="

# Step 1: 測試主 API 可用性
echo "Testing primary API (api.census.gov)..."
API_AVAILABLE=false
if timeout 15 curl -sS -o /dev/null -w "%{http_code}" --connect-timeout 10 "https://api.census.gov" 2>/dev/null | grep -q "200\|301\|302"; then
  API_AVAILABLE=true
  echo "  Primary API: AVAILABLE"
else
  echo "  Primary API: UNAVAILABLE (using fallback)"
fi

FETCH_COUNT=0
ERROR_COUNT=0

if [[ "$API_AVAILABLE" == "true" ]]; then
  # ===== 主 API 路徑 =====
  echo ""
  echo "--- Using Primary API (HS detail data) ---"

  for i in "${!PARTNER_CODES[@]}"; do
    cty_code="${PARTNER_CODES[$i]}"
    partner_name="${PARTNER_NAMES[$i]}"
    output_file="$RAW_DIR/exports-${cty_code}-${CURRENT_YEAR}.json"
    url="${BASE_URL}/exports/hs?get=CTY_CODE,CTY_NAME,ALL_VAL_MO,QTY_1_MO,E_COMMODITY,E_COMMODITY_LDESC&CTY_CODE=${cty_code}&time=from+${PREV_YEAR}&COMM_LVL=HS2"

    echo "Fetching exports: $partner_name ($cty_code)"
    if trade_api_fetch "$url" "$output_file" 86400; then
      if [[ -s "$output_file" ]]; then
        echo "  OK → $output_file"
        FETCH_COUNT=$(( FETCH_COUNT + 1 ))
      else
        echo "  WARNING: Empty response" >&2
        ERROR_COUNT=$(( ERROR_COUNT + 1 ))
        rm -f "$output_file"
      fi
    else
      echo "  ERROR: Failed" >&2
      ERROR_COUNT=$(( ERROR_COUNT + 1 ))
    fi
    sleep 2
  done

  for i in "${!PARTNER_CODES[@]}"; do
    cty_code="${PARTNER_CODES[$i]}"
    partner_name="${PARTNER_NAMES[$i]}"
    output_file="$RAW_DIR/imports-${cty_code}-${CURRENT_YEAR}.json"
    url="${BASE_URL}/imports/hs?get=CTY_CODE,CTY_NAME,GEN_VAL_MO,I_COMMODITY,I_COMMODITY_LDESC&CTY_CODE=${cty_code}&time=from+${PREV_YEAR}&COMM_LVL=HS2"

    echo "Fetching imports: $partner_name ($cty_code)"
    if trade_api_fetch "$url" "$output_file" 86400; then
      if [[ -s "$output_file" ]]; then
        echo "  OK → $output_file"
        FETCH_COUNT=$(( FETCH_COUNT + 1 ))
      else
        echo "  WARNING: Empty response" >&2
        ERROR_COUNT=$(( ERROR_COUNT + 1 ))
        rm -f "$output_file"
      fi
    else
      echo "  ERROR: Failed" >&2
      ERROR_COUNT=$(( ERROR_COUNT + 1 ))
    fi
    sleep 2
  done

else
  # ===== 備用路徑：HTML 頁面解析 =====
  echo ""
  echo "--- Using Fallback (HTML balance pages) ---"

  for i in "${!PARTNER_CODES[@]}"; do
    cty_code="${PARTNER_CODES[$i]}"
    partner_name="${PARTNER_NAMES[$i]}"
    html_file="$RAW_DIR/balance-${cty_code}-${CURRENT_YEAR}.html"
    json_file="$RAW_DIR/balance-${cty_code}-${CURRENT_YEAR}.json"
    url="${FALLBACK_URL}/c${cty_code}.html"

    echo "Fetching balance: $partner_name ($cty_code)"

    http_code=$(curl -sS -o "$html_file" -w "%{http_code}" --max-time 30 "$url" 2>/dev/null || echo "000")

    if [[ "$http_code" == "200" ]] && [[ -s "$html_file" ]]; then
      # 用 Python 解析 HTML → JSON
      python3 - "$html_file" "$json_file" "$cty_code" "$partner_name" << 'PYEOF'
import re, json, sys
from datetime import datetime

html_file, json_file, code, name = sys.argv[1:5]
with open(html_file, 'r') as f:
    html = f.read()

pattern = r"<td id='row\d+'>\s*(\w+)\s+(\d{4})\s*</td>.*?align='right'>\s*([\d,.-]+)\s*</td>.*?align='right'>\s*([\d,.-]+)\s*</td>.*?align='right'>\s*([\d,.-]+)\s*</td>"
matches = re.findall(pattern, html, re.DOTALL)

data = []
for m in matches:
    try:
        data.append({
            "month": m[0].strip(), "year": int(m[1]),
            "exports_millions_usd": float(m[2].replace(',', '')),
            "imports_millions_usd": float(m[3].replace(',', '')),
            "balance_millions_usd": float(m[4].replace(',', ''))
        })
    except: pass

result = {
    "source": "www.census.gov/foreign-trade/balance",
    "source_url": f"https://www.census.gov/foreign-trade/balance/c{code}.html",
    "fetched_at": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
    "country_code": code, "country_name": name,
    "record_count": len(data), "data": data
}
with open(json_file, 'w') as f:
    json.dump(result, f, indent=2)
print(len(data))
PYEOF
      record_count=$?
      echo "  OK → $json_file ($(jq '.record_count' "$json_file" 2>/dev/null || echo '?') records)"
      FETCH_COUNT=$(( FETCH_COUNT + 1 ))
    else
      echo "  ERROR: HTTP $http_code" >&2
      ERROR_COUNT=$(( ERROR_COUNT + 1 ))
    fi

    sleep 1
  done
fi

date -u '+%Y-%m-%dT%H:%M:%SZ' > "$RAW_DIR/.last_fetch"

echo ""
echo "=== Fetch Summary ==="
echo "Successful: $FETCH_COUNT"
echo "Errors: $ERROR_COUNT"
[[ "$API_AVAILABLE" == "false" ]] && echo "Note: Used fallback source (balance pages, no HS detail)"
echo "Fetch completed: $LAYER_NAME"
