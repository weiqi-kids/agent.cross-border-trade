#!/bin/bash
# cn_export_control 資料更新腳本
# 職責：Qdrant 更新 + REVIEW_NEEDED 檢查
# 注意：不處理 index.json（由 GitHub Actions 產生）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"
source "$PROJECT_ROOT/lib/chatgpt.sh"

LAYER_NAME="cn_export_control"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"
COLLECTION="${QDRANT_COLLECTION:-cross-border-trade}"

# Ensure category directories exist
for category in regulation_update controlled_item_change enforcement_action policy_guidance international_cooperation; do
  mkdir -p "$DOCS_DIR/$category"
done

# === Qdrant 批次更新 ===
UPSERT_COUNT=0
ERROR_COUNT=0
BATCH_SIZE="${QDRANT_BATCH_SIZE:-20}"  # 每批檔案數，可透過環境變數調整

if [[ -n "${QDRANT_URL:-}" ]]; then
  if qdrant_init_env; then
    chatgpt_init_env || echo "Warning: chatgpt_init_env failed, embedding disabled" >&2

    # Find .md files (from arguments or by scanning)
    MD_FILES=()
    if [[ $# -gt 0 ]]; then
      MD_FILES=("$@")
    else
      while IFS= read -r f; do
        MD_FILES+=("$f")
      done < <(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null | sort)
    fi

    TOTAL_FILES=${#MD_FILES[@]}
    echo "Processing $TOTAL_FILES files in batches of $BATCH_SIZE"

    # 批次處理
    for (( batch_start=0; batch_start < TOTAL_FILES; batch_start += BATCH_SIZE )); do
      batch_end=$(( batch_start + BATCH_SIZE ))
      if (( batch_end > TOTAL_FILES )); then
        batch_end=$TOTAL_FILES
      fi

      echo "  Batch $((batch_start / BATCH_SIZE + 1)): files $((batch_start + 1))-$batch_end"

      # 收集這批檔案的資料
      BATCH_TEXTS_JSON="["
      BATCH_PAYLOADS=()
      BATCH_IDS=()
      BATCH_FILES=()
      first=1

      for (( i=batch_start; i < batch_end; i++ )); do
        md_file="${MD_FILES[$i]}"
        if [[ ! -f "$md_file" ]]; then
          continue
        fi

        title="$(head -1 "$md_file" | sed 's/^#* *//' | sed 's/\[REVIEW_NEEDED\] *//')"
        category="$(basename "$(dirname "$md_file")")"

        source_url="$(grep -m1 '^\- \*\*URL\*\*:' "$md_file" | sed 's/.*: //' | tr -d ' ')" || true
        if [[ -z "$source_url" ]]; then
          source_url="mofcom://cn_export_control/${category}/$(basename "$md_file" .md)"
        fi

        content="$(head -20 "$md_file" | tr '\n' ' ' | cut -c1-500)"
        embed_text="$title $content"

        # 累積 JSON 陣列
        if [[ $first -eq 1 ]]; then
          first=0
        else
          BATCH_TEXTS_JSON+=","
        fi
        BATCH_TEXTS_JSON+="$(printf '%s' "$embed_text" | jq -Rs '.')"

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

        point_id="$(_qdrant_id_to_uuid "$source_url")"

        BATCH_PAYLOADS+=("$payload")
        BATCH_IDS+=("$point_id")
        BATCH_FILES+=("$md_file")
      done

      BATCH_TEXTS_JSON+="]"
      BATCH_COUNT=${#BATCH_IDS[@]}

      if [[ $BATCH_COUNT -eq 0 ]]; then
        continue
      fi

      # 批次取得 embeddings
      embeddings_json="$(chatgpt_embed_batch "$BATCH_TEXTS_JSON" 2>/dev/null)" || {
        echo "Warning: Batch embedding failed, falling back to individual processing" >&2
        # 降級為逐個處理
        for (( j=0; j < BATCH_COUNT; j++ )); do
          md_file="${BATCH_FILES[$j]}"
          embed_text="$(printf '%s' "$BATCH_TEXTS_JSON" | jq -r ".[$j]")"
          embedding="$(chatgpt_embed "$embed_text" 2>/dev/null)" || {
            echo "Warning: Embedding failed for $md_file" >&2
            ERROR_COUNT=$(( ERROR_COUNT + 1 ))
            continue
          }
          if qdrant_upsert_point "$COLLECTION" "${BATCH_IDS[$j]}" "$embedding" "${BATCH_PAYLOADS[$j]}" 2>/dev/null; then
            UPSERT_COUNT=$(( UPSERT_COUNT + 1 ))
          else
            ERROR_COUNT=$(( ERROR_COUNT + 1 ))
          fi
        done
        continue
      fi

      # 組裝批次 points JSON
      points_json="["
      for (( j=0; j < BATCH_COUNT; j++ )); do
        embedding="$(printf '%s' "$embeddings_json" | jq -c ".[$j]")"
        point_json="$(jq -n \
          --arg id "${BATCH_IDS[$j]}" \
          --argjson vector "$embedding" \
          --argjson payload "${BATCH_PAYLOADS[$j]}" \
          '{id: $id, vector: $vector, payload: $payload}'
        )"
        if [[ $j -gt 0 ]]; then
          points_json+=","
        fi
        points_json+="$point_json"
      done
      points_json+="]"

      # 批次 upsert
      if qdrant_upsert_points_batch "$COLLECTION" "$points_json" 2>/dev/null; then
        UPSERT_COUNT=$(( UPSERT_COUNT + BATCH_COUNT ))
      else
        echo "Warning: Batch upsert failed, falling back to individual" >&2
        for (( j=0; j < BATCH_COUNT; j++ )); do
          embedding="$(printf '%s' "$embeddings_json" | jq -c ".[$j]")"
          if qdrant_upsert_point "$COLLECTION" "${BATCH_IDS[$j]}" "$embedding" "${BATCH_PAYLOADS[$j]}" 2>/dev/null; then
            UPSERT_COUNT=$(( UPSERT_COUNT + 1 ))
          else
            ERROR_COUNT=$(( ERROR_COUNT + 1 ))
          fi
        done
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
echo "Errors: $ERROR_COUNT"
echo "Update completed: $LAYER_NAME"
