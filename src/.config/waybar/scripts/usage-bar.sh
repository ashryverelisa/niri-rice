#!/usr/bin/env bash
# Emit a JSON line for waybar with a horizontal usage bar.
# Usage: usage-bar.sh <cpu|mem|temp> [width]
set -euo pipefail

metric=${1:?metric required}
width=${2:-10}
state_dir=${XDG_RUNTIME_DIR:-/tmp}/waybar-usage-bar
mkdir -p "$state_dir"

read_cpu() {
    local prev="$state_dir/cpu" ci ct pi pt
    read -r _ a b c d e f g _ </proc/stat
    ci=$((d + e))
    ct=$((a + b + c + d + e + f + g))
    if [[ -f $prev ]]; then
        read -r pi pt <"$prev"
        local di=$((ci - pi)) dt=$((ct - pt))
        ((dt > 0)) && pct=$(( (100 * (dt - di) + dt/2) / dt )) || pct=0
    else
        pct=0
    fi
    printf '%s %s\n' "$ci" "$ct" >"$prev"
    tip="CPU $pct%"
}

read_mem() {
    local t a
    read -r t a < <(awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{print t,a}' /proc/meminfo)
    pct=$(( 100 * (t - a) / t ))
    local used_gb total_gb
    used_gb=$(awk -v u=$((t - a)) 'BEGIN{printf "%.1f", u/1024/1024}')
    total_gb=$(awk -v t="$t"     'BEGIN{printf "%.1f", t/1024/1024}')
    tip="Memory ${used_gb}/${total_gb} GiB (${pct}%)"
}

read_temp() {
    local f=/sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input
    local raw
    raw=$(cat $f 2>/dev/null | head -n1)
    local c=$(( raw / 1000 ))
    pct=$c
    ((pct > 100)) && pct=100
    tip="CPU ${c}°C"
}

case "$metric" in
    cpu)  read_cpu ;;
    mem)  read_mem ;;
    temp) read_temp ;;
    *) echo "{\"text\":\"?\",\"tooltip\":\"unknown metric $metric\"}"; exit 0 ;;
esac

blocks=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
idx=$(( pct * 8 / 100 ))
((idx < 0)) && idx=0
((idx > 7)) && idx=7
bar=${blocks[$idx]}

class=normal
((pct >= 90)) && class=critical
((pct >= 75 && pct < 90)) && class=warning

printf '{"text":"%s","tooltip":"%s","class":"%s","percentage":%s}\n' \
    "$bar" "$tip" "$class" "$pct"
