#!/usr/bin/env sh

# Help/Usage message definition.
usage="Usage: $(basename "$0") -m MESSAGE -c COMMAND
Simple tool to create dmenu dialog and execute command based on decission.

    -h | --help print this help message

    -m | --message MESSAGE to display
    -c | --command COMMAND to execute
    -w | --wal-colors use wal colors for dmenu if existent
    "

# Command line argument pasing.
while [ $# -gt 0 ]; do
    key="$1"
    case $key in
        -w|--wal-colors)
            # Check wether wal colors exist and import.
            # If not use dmenu with default colors.
            if [ -f "${HOME}/.cache/wal/colors.sh" ]; then
                # shellcheck source=/home/oliverwiegers/.cache/wal/colors.sh
                . "${HOME}/.cache/wal/colors.sh"
                wal=1
            else
                wal=0
            fi
            shift
            ;;
        -m|--message)
            # Set prompt messeage.
            message="$2"
            shift 2
            ;;
        -c|--command)
            # Set command to execute.
            cmd="$2"
            shift 2
            ;;
        -h|--help)
            # Print help message and exit.
            printf "%s\n" "${usage}"    
            exit 1
            ;;
        *)
            # Print help message and exit if wrong argument occours.
            printf "Unknown argument: %s\n\n%s" "$1" "${usage}" 
            exit 1
            ;;
    esac
done

# Call dmenu with or without wal colors.
if [ "${wal}" -eq 1 ]; then
    choice=$(printf "No\nYes" \
        | dmenu -i -p "${message}"\
        -nb "$color0" \
        -nf "$color15" \
        -sb "$color1" \
        -sf "$color0")
else
    choice=$(printf "No\nYes" \
        | dmenu -i -p "${message}")
fi

# Evaluate user input.
case ${choice} in
    Yes|Y)
        eval "${cmd}"
        ;;
    *)
        exit 0
        ;;
esac
