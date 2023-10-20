#!/usr/bin/env sh

# Metadata.
date='2020-04-11'
author='Oliver Wiegers'
email='oliver.wiegers@gmail.com'
license='GPL 3.0'
license_url='https://www.gnu.org/licenses/gpl-3.0.txt'
version='0.1.1'

# A POSIX variable.
# Reset in case getopts has been used previously in the shell.
OPTIND=1

# Initialize variables.
battery='BAT0'
state=''
notify=0
sleeping=0

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
    usage="$(basename "$0") -- check battery status.

        -h  show this usage.
        -L  print license information and exit.
        -V  print version and exit.
        -a  print about message and exit.
        -b  battery to check. default: BAT0
        -n  if set send notification
        -s  if set hibernate if capacity is below 3."

    printf '%s\n' "${usage}"
}

# Parse command line arguments.
while getopts "h?LVab:ns" opt; do
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
    b)
        battery="$OPTARG"
        exit 0
        ;;
    n)
        notify=1
        ;;
    s)
        sleeping=1
        ;;
    esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

battery_dir="/sys/class/power_supply/${battery}"
capacity="$(cat "${battery_dir}/capacity")"
state="$(cat "${battery_dir}/status")"

if [ "${state}" = "Discharging" ]; then
    # Check if battery exists.
    if ! [ -d "${battery_dir}" ]; then
        printf "%s not found.\n" "${battery}"
        exit 1
    fi

    if [ "${capacity}" -lt 15 ] && [ "${capacity}" -gt 10 ]; then
        if [ "${notify}" -eq 1 ]; then
            /bin/notify-send "Battery Alert" "Capacity: ${capacity}"
        else
            printf "Capacity: %s\n" "${capacity}"
        fi
    elif [ "${capacity}" -lt 3 ]; then
        if [ "${sleeping}" -eq 1 ]; then
            /bin/zzz
        else
            printf "Capacity: %s\n" "${capacity}"
        fi
    fi
fi
