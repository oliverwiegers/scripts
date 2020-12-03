#!/usr/bin/env sh

# A POSIX variable.
# Reset in case getopts has been used previously in the shell.
OPTIND=1

tmp_file="$1"

# Print usage.
print_usage() {
    usage="$(basename "$0") [OPTIONS]

    Reorder nodes after switching monitors.

        -h           show this usage.
        -g TMP_FILE  get current node config.
        -r TMP_FILE  reorder nodes."

    printf '%s\n' "${usage}"
}

_getCurrentOrder() {
    tmp_file="$1"
    desktops="$(bspc query -D)"
    
    for desktop in ${desktops}; do
        nodes="$(bspc query -d "${desktop}" --nodes)"
    
        for node in ${nodes}; do
            printf '%s %s\n' "${node}" "${desktop}" >> "${tmp_file}"
        done
    done
}

_reorderDesktops() {
    tmp_file="$1"

    while read -r node desktop; do
            bspc node "${node}" --to-desktop "${desktop}"
    done < "${tmp_file}"
}

# Parse command line arguments.
while getopts "hg:r:" opt; do
    case "$opt" in
    h)
        print_usage
        exit 0
        ;;
    g)
        _getCurrentOrder "${OPTARG}"
        ;;
    r)
        _reorderDesktops "${OPTARG}"
        ;;
    *)
        print_usage
        exit 1
        ;;
    esac
done
