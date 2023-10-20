#!/usr/bin/env sh

# Metadata.
date='2020-01-26'
author='Oliver Wiegers'
email='oliver.wiegers@gmail.com'
license='GPL 3.0'
license_url='https://www.gnu.org/licenses/gpl-3.0.txt'
version='0.1.1'

# A POSIX variable.
# Reset in case getopts has been used previously in the shell.
OPTIND=1

# Initialize variables.
sorted_output=0
sort_key=''
reverse=0
header=1
lines=0

# Print metadata.
print_about() {
    printf '%-15s%s\n' 'Written on:' "${date}"
    printf '%-15s%s\n' 'Written by:' "${author}"
    printf '%-15s%s\n' 'Email address:' "${email}"
    printf '%-15s%s\n' 'Version:' "${version}"
    printf '%-15s%s %s\n' 'License:' "${license}" "${license_url}"
}

# Print version.
print_version() {
    printf '%s\n' "${version}"
}

# Print license text.
print_license() {
    license_text="$(curl ${license_url} 2> /dev/null)"
    printf '%s\n' "${license_text}"
}

# Print usage.
print_usage() {
    usage="$(basename "$0") [-h] [-s KEY] -- tool to show the resource usage \
of processes.

        -h  show this usage.
        -H  don't print the header.
        -l  limit output by LINES. 0 will print all lines.
        -r  reverse order of sorted output.
        -t  print total memory usage.
        -s  sort the output by KEY.
        -S  list all keys to sort by and exit.
        -L  print license information and exit.
        -V  print version and exit.
        -a  print about message and exit."

    printf '%s\n' "${usage}"
}

# Get resource usage of processes.
get_usage () {
    ps ax -o pid,user,rss,pcpu,command \
        | awk \
        '/PID/ {next} {printf "%-10s%-15s%-15.2f%-15s%s\n",$1,$2,$3/1024,$4,$5}'
}

# Calcutlate total
calculate_total() {
    free | awk '/Mem:/ { total=$3/1000; printf ("Total: ~%.0fM\n", total) }'
}

# Parse command line arguments.
while getopts "h?LVartl:s:SH" opt; do
    case "$opt" in
    h|\?)
        print_usage
        exit 0
        ;;
    L)
        print_license
        exit 0
        ;;
    V)
        print_version
        exit 0
        ;;
    a)
        print_about
        exit 0
        ;;
    r)
        reverse=1
        ;;
    t)
        calculate_total
        exit 0
        ;;
    l)
        lines="$OPTARG"
        ;;
    s)
        sorted_output=1
        sort_key="$OPTARG"
        ;;
    S)
        printf '["%s", "%s", "%s", "%s", "%s"]\n' \
            'pid' 'owner' 'mem' 'cpu' 'cmd'
        exit 0
        ;;
    H)
        header=0
        ;;
    esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

# Print header, if wanted.
if [ $header -ne 0 ]; then
    printf "%-10s%-15s%-15s%-15s%s\n" "PID" "OWNER" "MEMORY MB" "CPU" "COMMAND"
fi

# Sort output if wanted.
if [ $sorted_output -ne 0 ]; then
    if [ "${sort_key}" = 'pid' ]; then
        output=$(get_usage | sort -bn -k1)
    elif [ "${sort_key}" = 'owner' ]; then
        output=$(get_usage | sort -br -k2)
    elif [ "${sort_key}" = 'mem' ]; then
        output=$(get_usage | sort -bnr -k3)
    elif [ "${sort_key}" = 'cpu' ]; then
        output=$(get_usage | sort -br -k4)
    elif [ "${sort_key}" = 'cmd' ]; then
        output=$(get_usage | sort -br -k5)
    fi
else
    output=$(get_usage)
fi

if [ "${reverse}" -ne 0 ]; then
    output="$(echo "${output}" | tac)"
fi

# Limit output to N lines if wanted.
if [ "${lines}" -ne 0 ]; then
    printf "%s\n" "${output}" | sed "${lines}q"
else
    printf "%s\n" "${output}"
fi
