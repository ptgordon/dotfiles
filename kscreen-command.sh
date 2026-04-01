#!/bin/sh
set -euo pipefail

HDMI="HDMI-A-1"

kwin_wayland --replace && kstart plasmashell 

# systemctl --user restart plasma-kscreen.service

if kscreen-doctor -o | awk 'NR<=5' | grep disabled; then
    kscreen-doctor output.HDMI-A-1.enable output.HDMI-A-1.scale.2 output.DP-1.disable output.DP-3.disable 
else
    kscreen-doctor output.DP-3.enable output.DP-1.enable output.DP-1.primary output.HDMI-A-1.disable 
fi
