#!/bin/bash

artist=$(playerctl metadata artist)
track=$(playerctl metadata title)
album=$(playerctl metadata album)
status=$(playerctl status)
if [ "$status" == "Paused" ]; then
    printf "  Artist: $artist  Track: $track\n"
elif [ "$status" == "Playing" ]; then
    printf "  Artist: $artist   Track: $track\n"
else
    echo " "
fi
