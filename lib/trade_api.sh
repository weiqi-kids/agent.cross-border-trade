#!/usr/bin/env bash
# trade_api.sh - JSON REST API client for trade data sources
# Provides: trade_api_fetch (HTTP GET + retry + cache), trade_api_to_jsonl (JSON array → JSONL)
# Dependencies: lib/core.sh, curl, jq

if [[ -n "${TRADE_API_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
TRADE_API_SH_LOADED=1

_trade_api_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${_trade_api_lib_dir}/core.sh"

########################################
# trade_api_fetch URL OUTPUT_FILE [CACHE_TTL_SECONDS]
#
# HTTP GET with retry, optional caching.
#
# Parameters:
#   URL: API endpoint
#   OUTPUT_FILE: path to save response
#   CACHE_TTL_SECONDS: if set and cache exists within TTL, skip fetch (default: 0 = no cache)
#
# Returns:
#   0 = success (or cache hit)
#   >0 = failure
########################################
trade_api_fetch() {
  local url="$1"
  local output_file="$2"
  local cache_ttl="${3:-0}"

  require_cmd curl || return 1

  # Cache check
  if [[ "$cache_ttl" -gt 0 && -f "$output_file" ]]; then
    local file_age now file_mtime
    now="$(date +%s)"
    if [[ "$(uname -s)" == "Darwin" ]]; then
      file_mtime="$(stat -f '%m' "$output_file" 2>/dev/null || echo 0)"
    else
      file_mtime="$(stat -c '%Y' "$output_file" 2>/dev/null || echo 0)"
    fi
    file_age=$(( now - file_mtime ))
    if [[ "$file_age" -lt "$cache_ttl" ]]; then
      echo "[trade_api_fetch] Cache hit (age=${file_age}s < ttl=${cache_ttl}s): $output_file" >&2
      return 0
    fi
  fi

  local max_retries=3
  local retry_delay=3
  local http_code

  for ((attempt=1; attempt<=max_retries; attempt++)); do
    http_code="$(
      curl -sS -L \
        -H "User-Agent: TradeIntelligenceSystem/1.0" \
        -H "Accept: application/json" \
        -w '%{http_code}' \
        -o "$output_file" \
        --connect-timeout 30 \
        --max-time 120 \
        "$url" 2>/dev/null
    )" || {
      local rc=$?
      if [[ $attempt -lt $max_retries ]]; then
        echo "[trade_api_fetch] curl failed (exit=$rc), retry $attempt/$max_retries..." >&2
        sleep $retry_delay
        retry_delay=$(( retry_delay * 2 ))
        continue
      fi
      echo "[trade_api_fetch] curl failed (exit=$rc) after $max_retries retries" >&2
      return 1
    }

    case "$http_code" in
      200)
        return 0
        ;;
      429)
        # Rate limited — wait longer
        if [[ $attempt -lt $max_retries ]]; then
          echo "[trade_api_fetch] HTTP 429 rate limited, waiting ${retry_delay}s..." >&2
          sleep $retry_delay
          retry_delay=$(( retry_delay * 3 ))
          continue
        fi
        echo "[trade_api_fetch] HTTP 429 after $max_retries retries" >&2
        rm -f "$output_file"
        return 1
        ;;
      *)
        if [[ $attempt -lt $max_retries ]]; then
          echo "[trade_api_fetch] HTTP=${http_code}, retry $attempt/$max_retries..." >&2
          sleep $retry_delay
          retry_delay=$(( retry_delay * 2 ))
        else
          echo "[trade_api_fetch] HTTP=${http_code} after $max_retries retries" >&2
          rm -f "$output_file"
          return 1
        fi
        ;;
    esac
  done

  return 1
}

########################################
# trade_api_fetch_paginated BASE_URL OUTPUT_FILE PAGE_PARAM [PAGE_SIZE_PARAM] [PAGE_SIZE]
#
# Fetches paginated API, concatenates all pages.
# Assumes JSON response with array at .data or top-level array.
#
# Parameters:
#   BASE_URL: API endpoint (without page param)
#   OUTPUT_FILE: combined output JSONL
#   PAGE_PARAM: query parameter name for page number (e.g., "page")
#   PAGE_SIZE_PARAM: query parameter for page size (default: "pageSize")
#   PAGE_SIZE: items per page (default: 100)
########################################
trade_api_fetch_paginated() {
  local base_url="$1"
  local output_file="$2"
  local page_param="${3:-page}"
  local page_size_param="${4:-pageSize}"
  local page_size="${5:-100}"

  require_cmd curl jq || return 1

  local page=1
  local total_records=0
  local tmp_page
  tmp_page="$(mktemp)"

  # Clear output
  > "$output_file"

  local separator="?"
  [[ "$base_url" == *"?"* ]] && separator="&"

  while true; do
    local url="${base_url}${separator}${page_param}=${page}&${page_size_param}=${page_size}"

    if ! trade_api_fetch "$url" "$tmp_page"; then
      echo "[trade_api_fetch_paginated] Failed at page $page" >&2
      rm -f "$tmp_page"
      return 1
    fi

    # Count records in this page
    local count
    count="$(jq 'if type == "array" then length elif .data? then (.data | length) else 0 end' "$tmp_page" 2>/dev/null)" || count=0

    if [[ "$count" -eq 0 ]]; then
      break
    fi

    # Append as JSONL
    jq -c 'if type == "array" then .[] elif .data? then .data[] else . end' "$tmp_page" >> "$output_file" 2>/dev/null
    total_records=$(( total_records + count ))
    echo "[trade_api_fetch_paginated] Page $page: $count records (total: $total_records)" >&2

    if [[ "$count" -lt "$page_size" ]]; then
      break
    fi

    page=$(( page + 1 ))
    # Rate limit courtesy
    sleep 1
  done

  rm -f "$tmp_page"
  echo "[trade_api_fetch_paginated] Done: $total_records total records" >&2
  return 0
}

########################################
# trade_api_to_jsonl INPUT_JSON OUTPUT_JSONL [JQ_FILTER]
#
# Converts a JSON file (array or object with .data array) to JSONL.
#
# Parameters:
#   INPUT_JSON: source JSON file
#   OUTPUT_JSONL: output JSONL file (one JSON object per line)
#   JQ_FILTER: optional jq expression to extract array (default: auto-detect)
########################################
trade_api_to_jsonl() {
  local input_json="$1"
  local output_jsonl="$2"
  local jq_filter="${3:-}"

  require_cmd jq || return 1

  if [[ ! -f "$input_json" ]]; then
    echo "[trade_api_to_jsonl] File not found: $input_json" >&2
    return 1
  fi

  if [[ -n "$jq_filter" ]]; then
    jq -c "$jq_filter | .[]" "$input_json" > "$output_jsonl" 2>/dev/null
  else
    # Auto-detect: top-level array, .data array, or single object
    jq -c '
      if type == "array" then .[]
      elif .data? and (.data | type) == "array" then .data[]
      elif .dataset? and (.dataset | type) == "array" then .dataset[]
      else .
      end
    ' "$input_json" > "$output_jsonl" 2>/dev/null
  fi

  local count
  count="$(wc -l < "$output_jsonl" | tr -d ' ')"
  echo "[trade_api_to_jsonl] Converted $count records to $output_jsonl" >&2
  return 0
}
