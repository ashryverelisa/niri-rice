#!/bin/bash

OUTPUTS=$(niri msg outputs)

if echo "$OUTPUTS" | grep -q "DP-1"; then
    # Desktop Pc
    niri msg output DP-1 on
    niri msg output DP-1 mode 5120x1440@239.761
    niri msg output DP-1 scale 1
    niri msg output HDMI-A-1 off
else
    # Laptop only
    niri msg output eDP-1 on
    niri msg output eDP-1 mode 2560x1440@165.000
    niri msg output eDP-1 scale 1
fi