#!/usr/bin/env sh

if [ "$#" -ne 1 ]; then
    printf 'Wrong number of arguments.\nUsage: %s <path_to_todo_list>\n' \
        "$(basename "$0")"
    exit 1
fi

todo_list_path=$1

counter=0
while read -r item; do
    if [ "$(expr "${item}" : '^[-][[:blank:]][\[][[:space:]].*$')" -eq 0 ]; then
        counter=$((counter=counter+1))
        undone=$(echo "${item}" | cut -d ' ' -f1,2,3 --complement)
        string="${string}\n<b>${counter}.</b> ${undone}"
    fi
done < "${todo_list_path}"

if [ ${counter} -ne 0 ]; then
    /usr/bin/notify-send "<b>Todo</b>" "${string}"
fi
