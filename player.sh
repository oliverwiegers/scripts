#!/usr/bin/env sh


spotifyon=$(pgrep spotify)
if [ -z "$spotifyon" ]; then
    printf ""
else
	status=$(playerctl status)
	artist=$(playerctl metadata artist)
	track=$(playerctl metadata title)
	if [ "${status}" = "Paused" ]; then
		printf "  %s: %s\n" "${artist}" "${track}"
	elif [ "${status}" = "Playing" ]; then
		printf "  %s: %s\n" "${artist}" "${track}"
	else
		printf " "
	fi
fi
