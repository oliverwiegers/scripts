#!/usr/bin/env sh

# Help/Usage message definition.
usage="Usage: $(basename "$0") -m MESSAGE -c COMMAND
Simple tool to create wofi dmenu mode dialog and execute command based on decission.

    -h | --help print this help message

    -m | --message MESSAGE to display
    -c | --command COMMAND to execute
    "

# Command line argument pasing.
while [ $# -gt 0 ]; do
    key="$1"
    case $key in
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

# Call wofi in dmenu mode.
choice=$(printf "%s\n%s" 'No' 'Yes' \
    | wofi \
    --prompt="${message}" \
    --show dmenu \
    --insensitive \
    --height 60 \
    --sort default \
    --cache-file /dev/null)

# Evaluate user input.
case ${choice} in
    Yes|Y)
        eval "${cmd}"
        ;;
    *)
        exit 0
        ;;
esac
