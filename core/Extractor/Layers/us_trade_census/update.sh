#!/bin/bash
# us_trade_census 資料更新腳本
# 職責：Qdrant 更新 + REVIEW_NEEDED 檢查

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"
source "$PROJECT_ROOT/lib/chatgpt.sh"

LAYER_NAME="us_trade_census"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"
COLLECTION="${QDRANT_COLLECTION:-cross-border-trade}"

for category in monthly_export monthly_import trade_balance country_detail; do
  mkdir -p "$DOCS_DIR/$category"
done

UPSERT_COUNT=0
ERROR_COUNT=0

if [[ -n "${QDRANT_URL:-}" ]]; then
  if qdrant_init_env; then
    chatgpt_init_env || echo "Warning: chatgpt_init_env failed" >&2

    MD_FILES=()
    if [[ $# -gt 0 ]]; then
      MD_FILES=("$@")
    else
      while IFS= read -r f; do
        MD_FILES+=("$f")
      done < <(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null | sort)
    fi

    for md_file in "${MD_FILES[@]}"; do
      [[ -f "$md_file" ]] || continue

      title="$(head -1 "$md_file" | sed 's/^#* *//' | sed 's/\[REVIEW_NEEDED\] *//')"
      category="$(basename "$(dirname "$md_file")")"
      source_url="census://us_trade_census/${category}/$(basename "$md_file" .md)"
      content="$(head -20 "$md_file" | tr '\n' ' ' | cut -c1-500)"

      embedding="$(chatgpt_embed "$title $content" 2>/dev/null)" || {
        ERROR_COUNT=$(( ERROR_COUNT + 1 )); continue
      }

      payload="$(jq -n \
        --arg source_url "$source_url" \
        --arg source_layer "$LAYER_NAME" \
        --arg title "$title" \
        --arg date "$(date -u '+%Y-%m-%d')" \
        --arg category "$category" \
        --arg fetched_at "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
        --arg original_content "$content" \
        '{source_url:$source_url, source_layer:$source_layer, title:$title, date:$date, category:$category, fetched_at:$fetched_at, original_content:$original_content}'
      )"

      point_id="$(_qdrant_id_to_uuid "$source_url")"
      if qdrant_upsert_point "$COLLECTION" "$point_id" "$embedding" "$payload" 2>/dev/null; then
        UPSERT_COUNT=$(( UPSERT_COUNT + 1 ))
      else
        ERROR_COUNT=$(( ERROR_COUNT + 1 ))
      fi
    done
  fi
fi

# REVIEW_NEEDED check
REVIEW_FILES=""
while IFS= read -r f; do
  grep -q "\[REVIEW_NEEDED\]" "$f" 2>/dev/null && REVIEW_FILES+="  - $f\n"
done < <(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null)

[[ -n "$REVIEW_FILES" ]] && echo "=== REVIEW_NEEDED ===" && echo -e "$REVIEW_FILES"

echo "Update completed: $LAYER_NAME (upserted=$UPSERT_COUNT, errors=$ERROR_COUNT)"
