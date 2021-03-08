#!/usr/bin/env sh

current_dir="$PWD"
waybar_config_dir="$HOME/.config/waybar"
displays="$(swaymsg -t get_outputs \
    | jq -r '..|try select(.active == true) | .name')"

cd "${waybar_config_dir}" || exit 1

if [ "$(echo "${displays}" | wc -l)" -gt 1 ]; then
    cp internal_external config
else
    cp internal_only config
fi

#swaymsg "reload"

cd "${current_dir}" || exit 1
