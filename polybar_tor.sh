#!/usr/bin/env bash

read -r is_tor ip country_code<<<"$(sh "$SCRIPT_DIR/tor_check.sh" \
    | jq -r '.IsTor,.IP,.CountryCode' | paste -s -d ' ')"

state=''

if [ -z "${is_tor}" ]; then
    if ! ping google.com 2> /dev/null; then
        state='%{F#DC143C}NO CONNECTION%{F-}'
        printf "%b" "${state}"
    fi
elif [ "${is_tor}" = "true" ]; then
    state='%{F#69aa86}TOR%{F-}'
    printf "%b IP: %s Country: %s" \
        "${state}" "${ip}" "${country_code}"
else
    state='%{F#DC143C}UNSECURE%{F-}'
    printf "%b" "${state}"
fi
