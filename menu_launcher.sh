#!/usr/bin/env sh

command="$1"
# Import the colors
# shellcheck source=/home/oliverwiegers/.cache/wal/colors.sh
. "${HOME}/.cache/wal/colors.sh"

"${command}" -i -nb "$color0" -nf "$color15" -sb "$color1" -sf "$color0"
