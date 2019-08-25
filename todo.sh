#!/usr/bin/env sh

counter=0
while read -r item; do
    if [ "$(expr "${item}" : '^[-][[:blank:]][\[][[:space:]].*$')" -eq 0 ]; then
		counter=$((counter=counter+1))
		undone=$(echo "${item}" | cut -d ' ' -f1,2,3 --complement)
		string="${string}\n<b>${counter}.</b> ${undone}"
	fi
done < "$HOME/Documents/personal/notes/todo.md"

if [ ${counter} -ne 0 ]; then
	/usr/bin/notify-send "<b>Todo</b>" "${string}"
fi
