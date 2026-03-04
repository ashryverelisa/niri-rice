#!/usr/bin/env bash
set -euo pipefail

MODE=$(niri msg outputs | grep -A1 'Output.*DP-1' | grep "Current mode:" | awk '{print $3}')

if [[ "$MODE" == "5120x1440" ]]; then
  niri msg output DP-1 mode 2560x1440@239.999
  niri msg output HDMI-A-1 on
  niri msg output HDMI-A-1 mode 2560x1440@239.999
else
  niri msg output HDMI-A-1 off
  sleep 0.2
  niri msg output DP-1 mode 5120x1440@239.761
fi