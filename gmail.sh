#!/bin/bash

username="$GOOGLE_USER"
password="$GOOGLE_PASS"

curl -u $username:$password --silent "https://mail.google.com/mail/feed/atom" \
	> /tmp/gmail.xml

read_dom () {
	local IFS=\>
	read -d \< entity content
}

while read_dom; do
	if [[ $entity = "fullcount" ]]; then
		count=$content
	fi
done  < /tmp/gmail.xml
echo $count
