#!/usr/bin/env sh

# Import the colors
# shellcheck source=/home/oliverwiegers/.cache/wal/colors.sh
. "${HOME}/.cache/wal/colors.sh"

if grep -q Ubuntu /etc/issue; then
    wofi --show run
else
    bemenu-run \
        --ignorecase \
        --line-height 40 \
        --tb "${color0}" --tf "${color4}" \
        --fb "${color0}" --ff "${color8}" \
        --nb "${color0}" --nf "${color8}" \
        --hb "${color0}" --hf "${color4}" \
        --tb "${color0}" --tf "${color1}" \
        --sb "${color8}" --tf "${color4}"
fi
