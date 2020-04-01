#!/usr/bin/env sh

# Metadata.
date='2020-03-31'
author='Oliver Wiegers'
email='oliver.wiegers@gmail.com'
license='GPL 3.0'
license_url='https://www.gnu.org/licenses/gpl-3.0.txt'
version='0.1.1'

# A POSIX variable.
# Reset in case getopts has been used previously in the shell.
OPTIND=1

# Initialize variables.
name="$(basename "$0")"
tor_rules_file="/etc/iptables/tor.rules"
default_rules_file="/etc/iptables/non_tor.rules"
active_rules_file="/etc/iptables/iptables.rules"
active_ipv6_rules_file="/etc/iptables/ip6tables.rules"
tor_rules="
*nat
:PREROUTING ACCEPT [6:2126]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [17:6239]
:POSTROUTING ACCEPT [6:408]

-A PREROUTING ! -i lo -p udp -m udp --dport 53 -j REDIRECT --to-ports 5353
-A PREROUTING ! -i lo -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports 9040
-A OUTPUT -o lo -j RETURN
--ipv4 -A OUTPUT -d 192.168.0.0/16 -j RETURN
-A OUTPUT -m owner --uid-owner \"tor\" -j RETURN
-A OUTPUT -p udp -m udp --dport 53 -j REDIRECT --to-ports 5353
-A OUTPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports 9040
COMMIT

*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]

-A INPUT -i lo -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
--ipv4 -A INPUT -p tcp -j REJECT --reject-with tcp-reset
--ipv4 -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
--ipv4 -A INPUT -j REJECT --reject-with icmp-proto-unreachable
--ipv6 -A INPUT -j REJECT
--ipv4 -A OUTPUT -d 127.0.0.0/8 -j ACCEPT
--ipv4 -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
--ipv6 -A OUTPUT -d ::1/8 -j ACCEPT
-A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A OUTPUT -m owner --uid-owner \"tor\" -j ACCEPT
--ipv4 -A OUTPUT -j REJECT --reject-with icmp-port-unreachable
--ipv6 -A OUTPUT -j REJECT
COMMIT
"

# Print metadata.
print_about() {
    printf '%-15s%s\n' 'Written on:' "${date}"
    printf '%-15s%s\n' 'Written by:' "${author}"
    printf '%-15s%s\n' 'Email adress:' "${email}"
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
    usage="${name} [-h] command -- tool to switch routing from normal to
transparent tor routing.

This script needs to be run as root.

        FLAGS:
        -h  show this usage.
        -L  print license information and exit.
        -V  print version and exit.
        -a  print about message and exit.

        COMMANDS:
        init     create all neede iptables rules.
        cleanup  delete all iptables rule and restore defualt state.
        start    start tor routing.
        stop     stop tor routing.
        reload   reload tor service to get new ip."

    printf '%s\n' "${usage}"
}

check_init() {
    if [ ! -f "${tor_rules_file}" ] || [ ! -f "${default_rules_file}" ]; then
        printf "Iptables rules seem not to be initialized.
Are you running %s the first time?
Please run \"%s init\".\n" "${name}" "${name}"
        exit 1
    fi
}

if [ "$(id -u)" -ne 0 ]; then
    printf "Please run as root.\nExiting...\n\n"
    print_usage
    exit 1
fi

# Parse command line arguments.
while getopts "h?LVa" opt; do
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
    esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

arg="$1"
case "${arg}" in
    init)
        printf "Initializing iptables rules.\n"
        printf "%s" "${tor_rules}" > "${tor_rules_file}"
        /bin/iptables-save > "${default_rules_file}"
        shift
        ;;
    cleanup)
        check_init
        printf "Cleanup all files.\n"
        /bin/iptables --flush
        cp "${default_rules_file}" "${active_rules_file}"
        if ! [ -e "${active_ipv6_rules_file}" ]; then
            ln -s "${active_rules_file}" "${active_ipv6_rules_file}"
        fi
        /bin/sv restart iptables
        /bin/sv restart ip6tables
        /bin/sv stop tor
        if [ -f "${tor_rules_file}" ]; then
            rm "${tor_rules_file}"
        fi
        if [ -f "${default_rules_file}" ]; then
            rm "${default_rules_file}*"
        fi
        ;;
    start)
        check_init
        printf "Starting tor service.\n"
        /bin/iptables --flush
        /bin/sv start tor
        cp "${default_rules_file}" "${default_rules_file}-$(date +%Y%m%d%H%M)"
        cp "${tor_rules_file}" "${active_rules_file}"
        if ! [ -e "${active_ipv6_rules_file}" ]; then
            ln -s "${active_rules_file}" "${active_ipv6_rules_file}"
        fi
        /bin/sv restart iptables
        /bin/sv restart ip6tables
        # shellcheck source=/home/oliverwiegers/Documents/scripts/tor_check.sh
        shift
        ;;
    stop)
        check_init
        printf "Stopping tor service.\n"
        /bin/iptables --flush
        cp "${default_rules_file}" "${active_rules_file}"
        if ! [ -e "${active_ipv6_rules_file}" ]; then
            ln -s "${active_rules_file}" "${active_ipv6_rules_file}"
        fi
        /bin/sv restart iptables
        /bin/sv restart ip6tables
        /bin/sv stop tor
        shift
        ;;
    reload)
        check_init
        printf "Reloading tor service.\n"
        /bin/killall -HUP tor
        shift
        ;;
    *)
        printf "Illegal option %s\n" "${arg}"
        print_usage
        exit 1
esac
