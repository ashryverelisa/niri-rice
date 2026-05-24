#!/usr/bin/env bash
# Emit a JSON line for waybar with a horizontal usage bar
# plus a rich multi-metric tooltip.
# Usage: usage-bar.sh <cpu|mem|temp> [width]
set -euo pipefail

metric=${1:?metric required}
state_dir=${XDG_RUNTIME_DIR:-/tmp}/waybar-usage-bar
mkdir -p "$state_dir"

read_cpu_pct() {
    local prev="$state_dir/cpu_$metric" ci ct pi pt a b c d e f g
    read -r _ a b c d e f g _ </proc/stat
    ci=$((d + e))
    ct=$((a + b + c + d + e + f + g))
    if [[ -f $prev ]]; then
        read -r pi pt <"$prev"
        local di=$((ci - pi)) dt=$((ct - pt))
        ((dt > 0)) && cpu_pct=$(( (100 * (dt - di) + dt/2) / dt )) || cpu_pct=0
    else
        cpu_pct=0
    fi
    printf '%s %s\n' "$ci" "$ct" >"$prev"
}

read_cpu_freq() {
    local sum=0 count=0 khz
    for f in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_cur_freq; do
        [[ -f $f ]] || continue
        khz=$(<"$f")
        sum=$((sum + khz))
        count=$((count + 1))
    done
    if ((count > 0)); then
        cpu_ghz=$(awk -v s="$sum" -v c="$count" 'BEGIN{printf "%.1f", s/c/1000000}')
    else
        cpu_ghz="?"
    fi
}

read_cpu_temp() {
    local raw=""
    for p in /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input; do
        [[ -f $p ]] && { raw=$(<"$p"); break; }
    done
    if [[ -z $raw ]]; then
        for p in /sys/class/hwmon/hwmon*/temp1_input; do
            [[ -f $p ]] && { raw=$(<"$p"); break; }
        done
    fi
    if [[ -n $raw ]]; then
        cpu_temp=$(( raw / 1000 ))
    else
        cpu_temp=0
    fi
}

read_load() {
    local l1 l5 l15
    read -r l1 l5 l15 _ </proc/loadavg
    load_str="${l1} · ${l5} · ${l15}"
}

read_mem_info() {
    local t=0 a=0 st=0 sa=0 k v
    while read -r k v _; do
        case "$k" in
            MemTotal:)     t=$v ;;
            MemAvailable:) a=$v ;;
            SwapTotal:)    st=$v ;;
            SwapFree:)     sa=$v ;;
        esac
    done </proc/meminfo
    mem_pct=$(( 100 * (t - a) / t ))
    mem_used_gb=$(awk -v u=$((t - a)) 'BEGIN{printf "%.1f", u/1024/1024}')
    if ((st > 0)); then
        swap_pct=$(( 100 * (st - sa) / st ))
        swap_used_gb=$(awk -v u=$((st - sa)) 'BEGIN{printf "%.1f", u/1024/1024}')
    else
        swap_pct=0
        swap_used_gb="0.0"
    fi
}

read_net() {
    local prev="$state_dir/net_$metric" rx_total=0 tx_total=0 line iface rest rb tb
    while read -r line; do
        [[ $line == *:* ]] || continue
        iface=${line%%:*}
        iface=${iface// /}
        [[ $iface == "lo" ]] && continue
        [[ $iface == Inter* || $iface == face* ]] && continue
        rest=${line#*:}
        read -r rb _ _ _ _ _ _ _ tb _ <<<"$rest"
        rx_total=$((rx_total + rb))
        tx_total=$((tx_total + tb))
    done </proc/net/dev

    local now prx=0 ptx=0 pnow=0
    now=$(date +%s%N)
    if [[ -f $prev ]]; then
        read -r prx ptx pnow <"$prev"
        dl_kbs=$(awk -v b=$((rx_total - prx)) -v n="$now" -v p="$pnow" \
            'BEGIN{dt=(n-p)/1000000000; if(dt<=0)dt=1; printf "%.1f", (b/dt)/1024}')
        ul_kbs=$(awk -v b=$((tx_total - ptx)) -v n="$now" -v p="$pnow" \
            'BEGIN{dt=(n-p)/1000000000; if(dt<=0)dt=1; printf "%.1f", (b/dt)/1024}')
    else
        dl_kbs="0.0"
        ul_kbs="0.0"
    fi
    printf '%s %s %s\n' "$rx_total" "$tx_total" "$now" >"$prev"
}

read_disk() {
    local size used avail pct
    read -r _ size used avail pct _ < <(df -B1 --output=source,size,used,avail,pcent,target / | tail -n1)
    disk_pct=${pct%\%}
    disk_used_gb=$(awk  -v v="$used"  'BEGIN{printf "%.1f", v/1024/1024/1024}')
    disk_total_gb=$(awk -v v="$size"  'BEGIN{printf "%.1f", v/1024/1024/1024}')
    disk_avail_gb=$(awk -v v="$avail" 'BEGIN{printf "%.1f", v/1024/1024/1024}')
}

read_cpu_pct
read_cpu_freq
read_cpu_temp
read_load
read_mem_info
read_net
read_disk

case "$metric" in
    cpu)  pct=$cpu_pct ;;
    mem)  pct=$mem_pct ;;
    temp) pct=$cpu_temp; ((pct > 100)) && pct=100 ;;
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

tip=$(printf '<tt><b>%-15s</b>%s\n<b>%-15s</b>%s\n<b>%-15s</b>%s\n<b>%-15s</b>%s\n<b>%-15s</b>%s\n<b>%-15s</b>%s\n<b>%-15s</b>%s\n<b>%-15s</b>%s\n<b>%-15s</b>%s</tt>' \
    "CPU usage"      "${cpu_pct}% (${cpu_ghz} GHz)" \
    "CPU temp"       "${cpu_temp}°C" \
    "Load average"   "${load_str}" \
    "Memory"         "${mem_pct}% (${mem_used_gb} GiB)" \
    "Swap usage"     "${swap_pct}% (${swap_used_gb} GiB)" \
    "Download speed" "${dl_kbs} KB/s" \
    "Upload speed"   "${ul_kbs} KB/s" \
    "Disk"           "${disk_pct}% (${disk_used_gb} / ${disk_total_gb} GB)" \
    "Available"      "${disk_avail_gb} GB")

tip_json=${tip//$'\n'/\\n}

printf '{"text":"%s","tooltip":"%s","class":"%s","percentage":%s}\n' \
    "$bar" "$tip_json" "$class" "$pct"
