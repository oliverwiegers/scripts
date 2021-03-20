#!/usr/bin/env bash

set -euo pipefail;

# Print usage.
print_usage() {
    usage="$(basename "$0") [OPTIONS]

    Dummy message

        -u  TEXT    do stuff.
        "

    printf '%s\n' "${usage}"
}

run() {
    # A POSIX variable.
    # Reset in case getopts has been used previously in the shell.
    OPTIND=1
    
    # Parse command line arguments.
    while getopts "h?u:" opt; do
        case "$opt" in
        h)
            print_usage
            exit 0
            ;;
        u)
            arg=$OPTARG
            print '%s\n' "${arg}"
            ;;
        *)
            print_usage
            exit 1
            ;;
        esac
    done
}

run "$@"
