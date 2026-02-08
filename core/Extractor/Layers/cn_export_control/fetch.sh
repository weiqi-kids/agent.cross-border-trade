#!/bin/bash
# cn_export_control 資料擷取腳本（Type B — POST API）
# 從中國商務部出口管制資訊網擷取文章列表

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"

require_cmd curl jq

# Check for iconv (optional but recommended for encoding conversion)
HAVE_ICONV=0
if command -v iconv >/dev/null 2>&1; then
  HAVE_ICONV=1
fi

# Convert file encoding from GBK/GB2312 to UTF-8
# Usage: convert_to_utf8 <input_file> <output_file>
# Falls back to copy if iconv fails or is unavailable
convert_to_utf8() {
  local input="$1"
  local output="$2"

  if [[ $HAVE_ICONV -eq 1 ]]; then
    # Try GBK first (superset of GB2312), fallback to GB2312
    if iconv -f GBK -t UTF-8 "$input" > "$output" 2>/dev/null; then
      return 0
    elif iconv -f GB2312 -t UTF-8 "$input" > "$output" 2>/dev/null; then
      return 0
    elif iconv -f GB18030 -t UTF-8 "$input" > "$output" 2>/dev/null; then
      return 0
    fi
  fi

  # Fallback: copy as-is (might already be UTF-8 or iconv unavailable)
  cp "$input" "$output"
  return 0
}

LAYER_NAME="cn_export_control"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"
BASE_URL="http://exportcontrol.mofcom.gov.cn"
API_URL="${BASE_URL}/edi_ecms_web_front/front/column/getColumnList"

mkdir -p "$RAW_DIR"

echo "=== cn_export_control fetch ==="

# Column IDs from the MOFCOM website (discovered via site inspection)
# columnID → section mapping
COLUMN_IDS=(13 14 15)
COLUMN_NAMES=("laws" "regulations" "rules_normative")
SECTION_LABELS=("法律 (Laws)" "法規 (Regulations)" "規章及規範性文件 (Rules & Normative Documents)")

OUTPUT_JSONL="$RAW_DIR/articles-$(date +%Y%m%d).jsonl"
> "$OUTPUT_JSONL"

TOTAL=0
ERRORS=0

for i in "${!COLUMN_IDS[@]}"; do
  col_id="${COLUMN_IDS[$i]}"
  col_name="${COLUMN_NAMES[$i]}"
  col_label="${SECTION_LABELS[$i]}"

  echo "Fetching section: $col_label (columnID=$col_id)"

  tmp_raw="$(mktemp)"
  tmp_json="$(mktemp)"

  if curl -sS -L \
    -X POST \
    -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
    -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
    -H "Accept: application/json, text/javascript, */*; q=0.01" \
    -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8" \
    -H "Accept-Encoding: identity" \
    -H "Referer: ${BASE_URL}/article/zcfg/" \
    -d "pageNumber=1&columnID=${col_id}" \
    -o "$tmp_raw" \
    --connect-timeout 30 \
    --max-time 60 \
    "$API_URL" 2>/dev/null; then

    # Convert encoding (fallback in case server sends GBK)
    convert_to_utf8 "$tmp_raw" "$tmp_json"

    # Check if response is valid JSON
    if jq empty "$tmp_json" 2>/dev/null; then
      # Extract articles from pageInfo.rows[]
      article_count="$(jq '.pageInfo.rows | length // 0' "$tmp_json" 2>/dev/null || echo 0)"

      if [[ "$article_count" -gt 0 ]]; then
        # Convert each article to our JSONL format
        jq -c --arg base_url "$BASE_URL" --arg section "$col_name" \
          '.pageInfo.rows[] | {
            title: .title,
            url: ($base_url + .url),
            date: (.publishTimeStr // "" | split(" ")[0] // ""),
            source_page: ($base_url + "/article/zcfg/"),
            section: $section,
            source: (.source // ""),
            article_id: (.id // "" | tostring)
          }' "$tmp_json" >> "$OUTPUT_JSONL" 2>/dev/null

        TOTAL=$(( TOTAL + article_count ))
        echo "  Found $article_count articles"
      else
        echo "  No articles found in response"
      fi
    else
      echo "  WARNING: Invalid JSON response" >&2
      ERRORS=$(( ERRORS + 1 ))
    fi
  else
    echo "  ERROR: Failed to fetch columnID=$col_id" >&2
    ERRORS=$(( ERRORS + 1 ))
  fi

  rm -f "$tmp_raw" "$tmp_json"

  # Politeness delay
  sleep 2
done

# Also try domestic/international news sections
NEWS_COLUMN_IDS=(1 2)
NEWS_COLUMN_NAMES=("domestic_news" "international_news")
NEWS_LABELS=("國內動態 (Domestic News)" "國際動態 (International News)")

for i in "${!NEWS_COLUMN_IDS[@]}"; do
  col_id="${NEWS_COLUMN_IDS[$i]}"
  col_name="${NEWS_COLUMN_NAMES[$i]}"
  col_label="${NEWS_LABELS[$i]}"

  echo "Fetching section: $col_label (columnID=$col_id)"

  tmp_raw="$(mktemp)"
  tmp_json="$(mktemp)"

  if curl -sS -L \
    -X POST \
    -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
    -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
    -H "Accept: application/json, text/javascript, */*; q=0.01" \
    -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8" \
    -H "Accept-Encoding: identity" \
    -H "Referer: ${BASE_URL}/" \
    -d "pageNumber=1&columnID=${col_id}" \
    -o "$tmp_raw" \
    --connect-timeout 30 \
    --max-time 60 \
    "$API_URL" 2>/dev/null; then

    # Convert encoding (fallback in case server sends GBK)
    convert_to_utf8 "$tmp_raw" "$tmp_json"

    if jq empty "$tmp_json" 2>/dev/null; then
      article_count="$(jq '.pageInfo.rows | length // 0' "$tmp_json" 2>/dev/null || echo 0)"

      if [[ "$article_count" -gt 0 ]]; then
        jq -c --arg base_url "$BASE_URL" --arg section "$col_name" \
          '.pageInfo.rows[] | {
            title: .title,
            url: ($base_url + .url),
            date: (.publishTimeStr // "" | split(" ")[0] // ""),
            source_page: ($base_url),
            section: $section,
            source: (.source // ""),
            article_id: (.id // "" | tostring)
          }' "$tmp_json" >> "$OUTPUT_JSONL" 2>/dev/null

        TOTAL=$(( TOTAL + article_count ))
        echo "  Found $article_count articles"
      else
        echo "  No articles found"
      fi
    fi
  else
    echo "  ERROR: Failed to fetch columnID=$col_id" >&2
    ERRORS=$(( ERRORS + 1 ))
  fi

  rm -f "$tmp_raw" "$tmp_json"
  sleep 2
done

# Write timestamp
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$RAW_DIR/.last_fetch"

echo ""
echo "=== Fetch Summary ==="
echo "Total articles found: $TOTAL"
echo "Errors: $ERRORS"
echo "Output: $OUTPUT_JSONL"
echo "Fetch completed: $LAYER_NAME"
