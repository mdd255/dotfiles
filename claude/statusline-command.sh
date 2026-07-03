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

model=$(echo "$input" | jq -r '.model.display_name // ""')
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
fh_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
fh_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
sd_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
sd_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Time left until reset (in hours or days)
now=$(date +%s)

time_left() {
  local reset=$1 unit=$2 # unit: h or d

  [ -z "$reset" ] && return

  local secs=$((reset - now))

  [ "$secs" -le 0 ] && {
    printf "soon"
    return
  }

  awk -v s="$secs" -v u="$unit" 'BEGIN {
    v = (u == "h") ? s/3600 : s/86400
    if (v >= 1)      printf "%.1f%s",  v, u
    else if (s >= 3600) printf "%.1fh", s/3600
    else             printf "%.0fmin", s/60
  }'
}

# Color by used %
pct_color() {
  local p=$1

  [ -z "$p" ] && {
    printf "$GREY"
    return
  }

  if [ "$p" -ge 90 ]; then
    printf "$RED"
  elif [ "$p" -ge 75 ]; then
    printf "$YELLOW"
  else
    printf "$GREY"
  fi
}

fmt_pct() { printf "%.0f" "$1" 2>/dev/null; }

# Build parts
parts=()
parts+=("${BLUE}${account}${RESET}")
[ -n "$model" ] && parts+=("${RED}${model}${RESET}")

if [ -n "$ctx_used" ]; then
  p=$(fmt_pct "$ctx_used")
  c=$(pct_color "$p")
  parts+=("${c}ctx: ${p}%${RESET}")
fi

if [ -n "$fh_used" ]; then
  p=$(fmt_pct "$fh_used")
  c=$(pct_color "$p")
  tl=$(time_left "$fh_reset" "h")
  parts+=("${c}5h: ${p}% ${tl}${RESET}")
fi

if [ -n "$sd_used" ]; then
  p=$(fmt_pct "$sd_used")
  c=$(pct_color "$p")
  tl=$(time_left "$sd_reset" "d")
  parts+=("${c}7d: ${p}% ${tl}${RESET}")
fi

# Join with separator
out=""

for i in "${!parts[@]}"; do
  [ "$i" -gt 0 ] && out+="$SEP"
  out+="${parts[$i]}"
done

printf "%b" "$out"
