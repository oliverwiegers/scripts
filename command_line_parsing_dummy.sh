#!/usr/bin/env sh

# A POSIX variable.
# Reset in case getopts has been used previously in the shell.
OPTIND=1

# Print usage.
print_usage() {
    usage="$(basename "$0") [OPTIONS]

    Dummy message.

        -h          show this usage.
        -u  TEXT    do stuff."

    printf '%s\n' "${usage}"
}


# Parse command line arguments.
while getopts "h?u:" opt; do
    case "$opt" in
    h)
        print_usage
        exit 0
        ;;
    u)
        arg=$OPTARG
        ;;
    *)
        print_usage
        exit 1
        ;;
    esac
done
