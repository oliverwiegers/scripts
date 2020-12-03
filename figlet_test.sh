#!/usr/bin/env sh

agent='Shitposter v0.1'
url='https://www.oliverwiegers.com'
request_text="$(mktemp)"

figlet -f banner testing | tr ' ' '.' | tr '#' '8' > "${request_text}"


while read -r line; do
    curl -L "${url}/${line}" -A "${agent}" > /dev/null 2>&1
done < "${request_text}"

rm "${request_text}"
