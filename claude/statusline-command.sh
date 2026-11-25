#!/usr/bin/env bash

# Colors
RESET='\033[0m'
GREY='\033[38;5;242m'
YELLOW='\033[38;5;229m'
RED='\033[38;5;203m'
BLUE='\033[38;5;110m'
SEP="${GREY}  |  ${RESET}"

# Account label - CLAUDE_CONFIG_DIR is inherited from the claude-app/claude-abd
# shell functions (unset -> default account dir)
account_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

case "$account_dir" in
"$HOME/.claude") account="AcceleratorApp" ;;
"$HOME/.claude-abd") account="ABD" ;;
*) account="$(basename "$account_dir")" ;;
esac

input=$(cat)

{
  IFS= read -r model
  IFS= read -r ctx_used
  IFS= read -r fh_used
  IFS= read -r fh_reset
  IFS= read -r sd_used
  IFS= read -r sd_reset
} < <(jq -r '
  (.model.display_name // ""),
  (.context_window.used_percentage // ""),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.five_hour.resets_at // ""),
  (.rate_limits.seven_day.used_percentage // ""),
  (.rate_limits.seven_day.resets_at // "")' <<<"$input")

# Time left until reset (in hours or days)
now=$(date +%s)

time_left() {
  local reset=$1 unit=$2 # unit: h or d

  [ -z "$reset" ] && return

  local secs=$((${reset%.*} - now))

  [ "$secs" -le 0 ] && {
    printf "soon"
    return
  }

  awk -v s="$secs" -v u="$unit" 'BEGIN {
    if (u == "d" && s >= 86400) printf "%.1fd", s/86400
    else if (s >= 3600)         printf "%.1fh", s/3600
    else                        printf "%.0fmin", s/60
  }'
}

# Color by used %
pct_color() {
  local p=$1

  if [ "${p:-0}" -ge 90 ]; then
    printf '%s' "$RED"
  elif [ "${p:-0}" -ge 75 ]; then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREY"
  fi
}

fmt_pct() { printf "%.0f" "$1" 2>/dev/null; }

# Progress bar, 10 cells. Args: pct, label color to restore afterwards.
# Filled cells use a darker shade of the threshold color, empty cells a dim grey.
BAR_EMPTY='\033[38;5;236m'
bar() {
  local p=${1:-0} back=$2 w=10 filled fc i on="" off=""
  filled=$(((p * w + 50) / 100))
  [ "$filled" -gt "$w" ] && filled=$w

  if [ "$p" -ge 90 ]; then
    fc='\033[38;5;131m'
  elif [ "$p" -ge 75 ]; then
    fc='\033[38;5;143m'
  else
    fc='\033[38;5;240m'
  fi

  for ((i = 0; i < w; i++)); do
    if [ "$i" -lt "$filled" ]; then on+="█"; else off+="░"; fi
  done
  printf '%s' "${fc}${on}${BAR_EMPTY}${off}${back}"
}

# Build parts
parts=()
parts+=("${BLUE}${account}${RESET}")
[ -n "$model" ] && parts+=("${RED}${model}${RESET}")

if [ -n "$ctx_used" ]; then
  p=$(fmt_pct "$ctx_used")
  c=$(pct_color "$p")
  parts+=("${c}ctx $(bar "$p" "$c")${RESET}")
fi

if [ -n "$fh_used" ]; then
  p=$(fmt_pct "$fh_used")
  c=$(pct_color "$p")
  tl=$(time_left "$fh_reset" "h")
  parts+=("${c}5h $(bar "$p" "$c") ${tl}${RESET}")
fi

if [ -n "$sd_used" ]; then
  p=$(fmt_pct "$sd_used")
  c=$(pct_color "$p")
  tl=$(time_left "$sd_reset" "d")
  parts+=("${c}7d $(bar "$p" "$c") ${tl}${RESET}")
fi

# Join with separator
out="${parts[0]}"

for part in "${parts[@]:1}"; do
  out+="${SEP}${part}"
done

printf "%b" "$out"
