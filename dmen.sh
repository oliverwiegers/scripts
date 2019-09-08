#!/usr/bin/env sh

# Import the colors
# shellcheck source=/home/oliverwiegers/.cache/wal/colors.sh
. "${HOME}/.cache/wal/colors.sh"

dmenu_run -i -nb "$color0" -nf "$color15" -sb "$color1" -sf "$color0"
