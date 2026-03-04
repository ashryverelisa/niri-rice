#!/usr/bin/env bash
set -euo pipefail

MODE=$(niri msg outputs | grep -A2 "DP-1" | grep "current mode" | awk '{print $3}' | cut -d'@' -f1)

if [[ "$MODE" == "5120x1440" ]]; then
  niri msg output DP-1 mode 2560x1440@240.000 scale 1 on
  niri msg output HDMI-A-1 mode 2560x1440@240.000 scale 1 on
else
  niri msg output HDMI-A-1 off
  sleep 0.2
  niri msg output DP-1 mode 5120x1440@239.761 scale 1 on
fi