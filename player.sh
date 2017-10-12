#!/bin/bash


spotifyon=$(ps -e |grep spotify)
if [ -z "$spotifyon" ]; then
    echo ""
else
	stat=$(playerctl status)
	artist=$(playerctl metadata artist)
	track=$(playerctl metadata title)
	album=$(playerctl metadata album)
	if [ "$stat" = "Paused" ]; then
		printf "  Artist: $artist	Track: $track\n"
	elif [ "$stat" = "Playing" ]; then
		printf "  Artist: $artist	 Track: $track\n"
	else
		echo " "
	fi
fi
