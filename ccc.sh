#!/usr/bin/env bash

response_code=$(curl -I -X GET https://events.ccc.de/congress/2018/ | head -n1 \
    | awk '{print $2}')

if ! [ "$response_code" = "404" ]; then
    notify-send 'CCC Notification' '35c3 is now online.'
fi
