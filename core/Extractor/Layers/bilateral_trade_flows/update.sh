#!/bin/bash
# bilateral_trade_flows 資料更新腳本
# 職責：Qdrant 更新 + REVIEW_NEEDED 檢查
# 注意：不處理 index.json（由 GitHub Actions 產生）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"
source "$PROJECT_ROOT/lib/chatgpt.sh"

LAYER_NAME="bilateral_trade_flows"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"
COLLECTION="${QDRANT_COLLECTION:-cross-border-trade}"

# Ensure category directories exist
for category in export_flow import_flow trade_balance market_concentration commodity_structure; do
  mkdir -p "$DOCS_DIR/$category"
done

# === Qdrant 更新 ===
UPSERT_COUNT=0
SKIP_COUNT=0
ERROR_COUNT=0

if [[ -n "${QDRANT_URL:-}" ]]; then
  if qdrant_init_env; then
    chatgpt_init_env || echo "Warning: chatgpt_init_env failed, embedding disabled" >&2

    # Find all .md files (from arguments or by scanning)
    MD_FILES=()
    if [[ $# -gt 0 ]]; then
      MD_FILES=("$@")
    else
      while IFS= read -r f; do
        MD_FILES+=("$f")
      done < <(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null | sort)
    fi

    for md_file in "${MD_FILES[@]}"; do
      if [[ ! -f "$md_file" ]]; then
        continue
      fi

      # Extract metadata from markdown
      title="$(head -1 "$md_file" | sed 's/^#* *//' | sed 's/\[REVIEW_NEEDED\] *//')"
      category="$(basename "$(dirname "$md_file")")"

      # Generate source_url as unique identifier
      source_url="comtrade://bilateral_trade_flows/${category}/$(basename "$md_file" .md)"

      # Read content for embedding (first 500 chars)
      content="$(head -20 "$md_file" | tr '\n' ' ' | cut -c1-500)"

      # Generate embedding
      embedding="$(chatgpt_embed "$title $content" 2>/dev/null)" || {
        echo "Warning: Embedding failed for $md_file" >&2
        ERROR_COUNT=$(( ERROR_COUNT + 1 ))
        continue
      }

      # Build payload
      payload="$(jq -n \
        --arg source_url "$source_url" \
        --arg source_layer "$LAYER_NAME" \
        --arg title "$title" \
        --arg date "$(date -u '+%Y-%m-%d')" \
        --arg category "$category" \
        --arg fetched_at "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
        --arg original_content "$content" \
        '{
          source_url: $source_url,
          source_layer: $source_layer,
          title: $title,
          date: $date,
          category: $category,
          fetched_at: $fetched_at,
          original_content: $original_content
        }'
      )"

      # Generate deterministic point ID from source_url
      point_id="$(_qdrant_id_to_uuid "$source_url")"

      # Upsert to Qdrant
      if qdrant_upsert_point "$COLLECTION" "$point_id" "$embedding" "$payload" 2>/dev/null; then
        UPSERT_COUNT=$(( UPSERT_COUNT + 1 ))
      else
        echo "Warning: Qdrant upsert failed for $md_file" >&2
        ERROR_COUNT=$(( ERROR_COUNT + 1 ))
      fi
    done
  else
    echo "Qdrant connection failed, skipping vector update" >&2
  fi
else
  echo "QDRANT_URL not set, skipping vector update"
fi

# === REVIEW_NEEDED 檢查 ===
REVIEW_FILES=""
while IFS= read -r f; do
  if grep -q "\[REVIEW_NEEDED\]" "$f" 2>/dev/null; then
    REVIEW_FILES+="  - $f\n"
  fi
done < <(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null)

if [[ -n "$REVIEW_FILES" ]]; then
  echo ""
  echo "=== REVIEW_NEEDED ==="
  echo -e "$REVIEW_FILES"
  command -v gh >/dev/null 2>&1 && gh issue create \
    --title "[Extractor] $LAYER_NAME - 需要人工審核" \
    --label "review-needed" \
    --body "偵測到 [REVIEW_NEEDED] 標記：
$(echo -e "$REVIEW_FILES")" 2>/dev/null || true
fi

echo ""
echo "=== Update Summary ==="
echo "Qdrant upserted: $UPSERT_COUNT"
echo "Skipped: $SKIP_COUNT"
echo "Errors: $ERROR_COUNT"
echo "Update completed: $LAYER_NAME"
