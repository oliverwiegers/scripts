#!/usr/bin/env sh

monitor_count="$(xrandr --listmonitors | awk 'NR==1 {print $2; exit}')"

if [ "${monitor_count}" -eq 1 ]; then
    xrandr --output LVDS1 --auto --primary --output DP1
    /bin/sh "$HOME/.fehbg"
    /bin/bspc wm -r
    echo "External off" >> /home/oliverwiegers/screen.log
elif [ "${monitor_count}" -eq 2 ]; then
    external_monitor="$(xrandr --listmonitors \
        | awk 'NR==2 {gsub(/\+|\*/,"",$2); print $2; exit}')"
    xrandr --output "${external_monitor}"  --auto --primary --output LVDS1 \
        --auto --noprimary --below "${external_monitor}"
    /bin/sh "$HOME/.fehbg"
    /bin/bspc wm -r
    echo "External on" >> /home/oliverwiegers/screen.log
else
    echo "More than two monitors are not supported" \
        >> /home/oliverwiegers/screen.log
fi
