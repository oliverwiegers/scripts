#!/usr/bin/env sh

sessions="$HOME/.tmux/resurrect"
if [ "$(find "${sessions}" -type f -not -name '*tar.gz' | wc -l)" -gt 1 ]; then
    find "${sessions}" \
        -type f \
        -not -name '*tar.gz' \
        -not -name "*$(date +%Y%m%d)*" \
        -delete
fi
