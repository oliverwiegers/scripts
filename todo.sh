#!/bin/bash

counter=0
regex="^[-][[:blank:]][\[][[:space:]].*$"
while read -r item; do
	if [[ ${item} =~ $regex ]]; then
		((counter++))
		undone=$(echo $item | cut -d ' ' -f1,2,3 --complement)
		string="$string\n<b>$counter.</b> ${undone}"
	fi
done < $HOME/Documents/personal/notes/todo.md

if [[ $counter -ne 0 ]]; then
	/usr/bin/notify-send "<b>Todo</b>" "$string"
fi
