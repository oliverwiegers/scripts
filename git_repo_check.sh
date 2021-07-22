#!/usr/bin/env bash

repos="$(find "$HOME" \
    -type d \
    -name '.git' \
    )"

printf '\e[1mGit repos with local changes:\e[0m\n\n'
for repo in ${repos}; do
    repo="${repo%.git}"

    if grep -q 'git@' "${repo}.git/config"; then
        pwd=$PWD
        cd "${repo}" || exit 1
        git update-index -q --refresh

        if ! [ "$(git diff-index --name-only HEAD | wc -l)" -eq 0 ]; then
            printf '%s\n' "${repo}"
        fi

        cd "${pwd}" || exit 1
    fi

done
