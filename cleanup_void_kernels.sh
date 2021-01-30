#!/usr/bin/env bash

path='/boot/'
current_version="$(uname -r | cut -d '_' -f1)"

versions="$(ls -1 ${path} \
    | grep -o -E '[0-9]+\.[0-9]+\.[0-9]+' \
    | sed '$ d' \
    | grep -v "${current_version}")"

for version in ${versions}; do
    rm -rf "$(eval "/boot/*${version:?}*")"
    rm -rf "$(eval "/usr/src/*${version:?}*")"
done
