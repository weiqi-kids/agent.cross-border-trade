#!/usr/bin/env bash
# trade_analysis.sh - Trade data calculation functions
# Provides: YoY diff, market share, HHI, ranking, trade balance
# Dependencies: jq

if [[ -n "${TRADE_ANALYSIS_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
TRADE_ANALYSIS_SH_LOADED=1

_trade_analysis_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${_trade_analysis_lib_dir}/core.sh"

require_cmd jq || true

########################################
# trade_yoy_diff INPUT_JSONL OUTPUT_FILE VALUE_FIELD PERIOD_FIELD GROUP_FIELD
#
# Calculates Year-over-Year difference for trade data.
#
# Parameters:
#   INPUT_JSONL: JSONL file with trade records
#   OUTPUT_FILE: output JSON file with YoY diffs
#   VALUE_FIELD: jq field path for value (e.g., ".primaryValue")
#   PERIOD_FIELD: jq field path for period/year (e.g., ".period")
#   GROUP_FIELD: jq field path for grouping (e.g., ".partnerCode")
########################################
trade_yoy_diff() {
  local input_jsonl="$1"
  local output_file="$2"
  local value_field="${3:-.primaryValue}"
  local period_field="${4:-.period}"
  local group_field="${5:-.partnerCode}"

  if [[ ! -f "$input_jsonl" ]]; then
    echo "[trade_yoy_diff] File not found: $input_jsonl" >&2
    return 1
  fi

  jq -sc "
    group_by(${group_field}) |
    map(
      sort_by(${period_field}) |
      . as \$sorted |
      if length < 2 then
        \$sorted[-1] + {yoy_change: null, yoy_pct: null}
      else
        \$sorted[-1] as \$curr |
        \$sorted[-2] as \$prev |
        \$curr + {
          yoy_change: ((\$curr${value_field} // 0) - (\$prev${value_field} // 0)),
          yoy_pct: (
            if (\$prev${value_field} // 0) != 0 then
              (((\$curr${value_field} // 0) - (\$prev${value_field} // 0)) / (\$prev${value_field}) * 100 | . * 100 | round / 100)
            else null end
          ),
          prev_value: (\$prev${value_field} // 0),
          prev_period: (\$prev${period_field})
        }
      end
    )
  " "$input_jsonl" > "$output_file" 2>/dev/null

  return $?
}

########################################
# trade_market_share INPUT_JSONL OUTPUT_FILE VALUE_FIELD GROUP_FIELD
#
# Calculates market share percentages.
#
# Parameters:
#   INPUT_JSONL: JSONL file
#   OUTPUT_FILE: output JSON with share data
#   VALUE_FIELD: jq field path for value
#   GROUP_FIELD: jq field path for grouping (e.g., partner country)
########################################
trade_market_share() {
  local input_jsonl="$1"
  local output_file="$2"
  local value_field="${3:-.primaryValue}"
  local group_field="${4:-.partnerCode}"

  if [[ ! -f "$input_jsonl" ]]; then
    echo "[trade_market_share] File not found: $input_jsonl" >&2
    return 1
  fi

  jq -sc "
    map(select(${value_field} != null and ${value_field} > 0)) |
    (map(${value_field}) | add) as \$total |
    if \$total == null or \$total == 0 then []
    else
      group_by(${group_field}) |
      map({
        group: (.[0]${group_field}),
        total_value: (map(${value_field}) | add),
        share_pct: ((map(${value_field}) | add) / \$total * 100 | . * 100 | round / 100)
      }) |
      sort_by(-.total_value)
    end
  " "$input_jsonl" > "$output_file" 2>/dev/null

  return $?
}

########################################
# trade_hhi INPUT_JSONL OUTPUT_FILE VALUE_FIELD GROUP_FIELD
#
# Calculates Herfindahl-Hirschman Index (market concentration).
# HHI = sum of squared market shares (0-10000 scale)
# < 1500: low concentration
# 1500-2500: moderate concentration
# > 2500: high concentration
#
# Parameters:
#   INPUT_JSONL: JSONL file
#   OUTPUT_FILE: output JSON with HHI
#   VALUE_FIELD: jq field path for value
#   GROUP_FIELD: jq field path for grouping
########################################
trade_hhi() {
  local input_jsonl="$1"
  local output_file="$2"
  local value_field="${3:-.primaryValue}"
  local group_field="${4:-.partnerCode}"

  if [[ ! -f "$input_jsonl" ]]; then
    echo "[trade_hhi] File not found: $input_jsonl" >&2
    return 1
  fi

  jq -sc "
    map(select(${value_field} != null and ${value_field} > 0)) |
    (map(${value_field}) | add) as \$total |
    if \$total == null or \$total == 0 then
      {hhi: null, concentration: \"unknown\", total: 0, groups: 0}
    else
      group_by(${group_field}) |
      map({
        group: (.[0]${group_field}),
        value: (map(${value_field}) | add),
        share: ((map(${value_field}) | add) / \$total * 100)
      }) |
      (map(.share * .share) | add | . * 100 | round / 100) as \$hhi |
      {
        hhi: \$hhi,
        concentration: (
          if \$hhi < 1500 then \"low\"
          elif \$hhi < 2500 then \"moderate\"
          else \"high\" end
        ),
        total: \$total,
        groups: length,
        top3_share: ([sort_by(-.value) | .[0:3] | .[].share] | add | . * 100 | round / 100)
      }
    end
  " "$input_jsonl" > "$output_file" 2>/dev/null

  return $?
}

########################################
# trade_rank INPUT_JSONL OUTPUT_FILE VALUE_FIELD GROUP_FIELD [TOP_N]
#
# Ranks groups by value, returns top N.
#
# Parameters:
#   INPUT_JSONL: JSONL file
#   OUTPUT_FILE: output JSON with rankings
#   VALUE_FIELD: jq field path for value
#   GROUP_FIELD: jq field path for grouping
#   TOP_N: number of top entries (default: 20)
########################################
trade_rank() {
  local input_jsonl="$1"
  local output_file="$2"
  local value_field="${3:-.primaryValue}"
  local group_field="${4:-.partnerCode}"
  local top_n="${5:-20}"

  if [[ ! -f "$input_jsonl" ]]; then
    echo "[trade_rank] File not found: $input_jsonl" >&2
    return 1
  fi

  jq -sc --argjson top_n "$top_n" "
    map(select(${value_field} != null and ${value_field} > 0)) |
    group_by(${group_field}) |
    map({
      group: (.[0]${group_field}),
      total_value: (map(${value_field}) | add),
      record_count: length
    }) |
    sort_by(-.total_value) |
    to_entries |
    map(.value + {rank: (.key + 1)}) |
    .[0:\$top_n]
  " "$input_jsonl" > "$output_file" 2>/dev/null

  return $?
}

########################################
# trade_balance INPUT_JSONL OUTPUT_FILE EXPORT_FILTER IMPORT_FILTER VALUE_FIELD GROUP_FIELD
#
# Calculates trade balance (exports - imports).
#
# Parameters:
#   INPUT_JSONL: JSONL file with both export and import records
#   OUTPUT_FILE: output JSON
#   EXPORT_FILTER: jq filter for exports (e.g., '.flowCode == "X"')
#   IMPORT_FILTER: jq filter for imports (e.g., '.flowCode == "M"')
#   VALUE_FIELD: jq field path for value
#   GROUP_FIELD: jq field path for grouping
########################################
trade_balance() {
  local input_jsonl="$1"
  local output_file="$2"
  local export_filter="${3:-.flowCode == \"X\"}"
  local import_filter="${4:-.flowCode == \"M\"}"
  local value_field="${5:-.primaryValue}"
  local group_field="${6:-.partnerCode}"

  if [[ ! -f "$input_jsonl" ]]; then
    echo "[trade_balance] File not found: $input_jsonl" >&2
    return 1
  fi

  jq -sc "
    . as \$all |
    (\$all | map(select(${export_filter}))) as \$exports |
    (\$all | map(select(${import_filter}))) as \$imports |
    (\$exports | group_by(${group_field}) | map({
      key: (.[0]${group_field} | tostring),
      value: (map(${value_field} // 0) | add)
    }) | from_entries) as \$exp_map |
    (\$imports | group_by(${group_field}) | map({
      key: (.[0]${group_field} | tostring),
      value: (map(${value_field} // 0) | add)
    }) | from_entries) as \$imp_map |
    ([\$exp_map | keys[], (\$imp_map | keys[])] | unique) |
    map(. as \$g | {
      group: \$g,
      exports: (\$exp_map[\$g] // 0),
      imports: (\$imp_map[\$g] // 0),
      balance: ((\$exp_map[\$g] // 0) - (\$imp_map[\$g] // 0)),
      balance_type: (
        if ((\$exp_map[\$g] // 0) - (\$imp_map[\$g] // 0)) > 0 then \"surplus\"
        elif ((\$exp_map[\$g] // 0) - (\$imp_map[\$g] // 0)) < 0 then \"deficit\"
        else \"balanced\" end
      )
    }) |
    sort_by(-.balance)
  " "$input_jsonl" > "$output_file" 2>/dev/null

  return $?
}
