#!/bin/bash

counter=0
regex="^[-][[:blank:]][a-z0-9\-\_[:space:]]*[[:blank:]][d][o][n][e]$"
while read -r item; do
	if [[ $item = \-* ]]; then
		((counter++))
		if [[ ${item,,} =~ $regex ]]; then
			item="${item:2}"
			item=$(echo $item | awk '{$NF="";sub(/[ \t]+$/,"")}1')
			item="<s>${item}</s>"
		else
			item=${item:2}
		fi
		string="$string\n<b>$counter.</b> ${item}"
	fi
done < /home/chrootzius/Documents/textfiles/todo.md

if [[ counter -ne 0 ]]; then
	notify-send -i /home/chrootzius/Pictures/todo.png "<b>Todo</b>" "$string"
fi
