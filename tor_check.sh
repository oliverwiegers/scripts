#!/usr/bin/env sh

# Define variables.
statefile="/usr/local/share/statefiles/tor.state"
logfile="/var/log/tor_check.log"
old_ip="$(sed 1q "${statefile}" 2> /dev/null)"

# Get data from tor api.
data="$(curl https://check.torproject.org/api/ip 2> /dev/null)"
ip="$(echo "${data}" | jq -r '.IP')"

# Check if exit node changed.
if [ "${ip}" = "${old_ip}" ]; then
    whois_data="$(tail -n+2 "${statefile}")"
    printf "[%s] using local data\n" "$(date '+%F %T')" >> "${logfile}"
else
    whois_data="$(whois "${ip}")"
    printf "[%s] whois query\n" "$(date '+%F %T')" >> "${logfile}"
    printf "%s\n%s" "${ip}" "${whois_data}" > "${statefile}"
fi

# Get net data.
netname="$(echo "${whois_data}" \
    | grep -i netname | sed 1q | awk '{ print substr($0, index($0,$2))}')"
country_code="$(echo "${whois_data}" | grep -i country | awk '{print $2}')"

# Return json data.
printf "%s" "${data}" \
    | jq \
    --arg NetName "${netname}" \
    --arg CountryCode "${country_code}" \
    '. + {NetName: $NetName} + {CountryCode: $CountryCode}'
