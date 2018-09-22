#!/bin/bash
export DISPLAY=:=0
counter=0
done=0
regex="^[-][[:blank:]][a-z0-9\-\_[:space:]]*[[:blank:]][d][o][n][e]$"
while read -r item; do
	if [[ $item = \-* ]]; then
		((counter++))
		if [[ ${item,,} =~ $regex ]]; then
			((done++))
		fi
	fi
done < $HOME/Documents/textfiles/todo.md

echo $done/$counter
