#!/usr/bin/env bash

# A POSIX variable.
# Reset in case getopts has been used previously in the shell.
OPTIND=1

# Variables.
json=0

# Print usage.
print_usage() {
    usage="$(basename "$0") [-j] domain -- query isitup.org api.

        -h  show this usage.
        -j  output raw json data."

    printf '%s\n' "${usage}"
}

# Get json data from isitup.org
get_status() {
    domain="$1"
    if [[ ${domain} =~ .*\:\/\/.* ]]; then
        domain="$(echo "${domain}" | cut -d'/' -f3)"
    fi

    if [[ ${domain} =~ .*\..*\/.* ]]; then
        domain="$(echo "${domain}" | cut -d'/' -f1)"
    fi

    curl 2> /dev/null "https://isitup.org/${domain}.json"
}

while getopts "h?j" opt; do
    case "$opt" in
    h|\?)
        print_usage
        exit 0
        ;;
    j)
        json=1
        ;;
    *)
        print_usage
        exit 1
        ;;
    esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

if [ $# -ne 1 ]; then
    printf "%s: illegal number of arguments -- %s\n" "$(basename "$0")" "$#"
    print_usage
    exit 1
fi

if [ "${json}" -eq 1 ]; then
    status="$(get_status "$1")"
    return_code="$(echo "${status}" | jq -r '.status_code' | paste -s -d ' ')"
    if [ "${return_code}" -eq 1 ]; then
        echo "${status}"
        exit 0
    else
        echo "${status}"
        exit 1
    fi
else
    read -r domain status_code ip response_code <<<"$(get_status "$1" \
        | jq -r '.domain,.status_code,.response_ip,.response_code' \
        | paste -s -d ' ')"

    if [ "${status_code}" -eq 1 ]; then
        printf "%s is up. IP is: %s. Response code is: %s.\n" \
            "${domain}" "${ip}" "${response_code}"
        exit 0
    else
        printf "%s is not up. IP is: %s. Response code is: %s.\n" \
            "${domain}" "${ip}" "${response_code}"
        exit 1
    fi
fi



