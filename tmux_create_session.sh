#!/usr/bin/env bash

set -euo pipefail;

template='code'
language=''
project_name='default'
create_working_dir=1
working_dir="$HOME/Documents/projects/${project_name}"

# Print usage.
_print_usage() {
    usage="$(basename "$0") [OPTIONS]

    Dummy message

        -p  TEXT    project name. [default: default]
        -l  TEXT    programmig language of project. [default: empty]
                    Options: [rust]
        -t  TEXT    choose session template. [default: code]
                    Options: [code|daywork]
        -n          do not create new working dir.
        "

    printf '%s\n' "${usage}"
}

_create_code_session() {
        # Create session..
        tmux new-session -d -s "${project_name}" -c "${working_dir}" -n "editor"

        # Create additional windows.
        tmux new-window -d -t "${project_name}:" -c "${working_dir}" -n "shell"
        tmux new-window -d -t "${project_name}:" -c "${working_dir}" -n "testing"
        tmux new-window -d -t "${project_name}:" -c "${working_dir}" -n "man-pages"
        tmux new-window -d -t "${project_name}:" -c "${working_dir}" -n "docs"

        case "${language}" in
            "rust")
                tmux new-window \
                    -d \
                    -t "${project_name}:" \
                    -c "${working_dir}" \
                    'cargo init'
                ;;
            "python")
                tmux new-window \
                    -d \
                    -t "${project_name}:" \
                    -c "${working_dir}" \
                    "mkdir docs  etc \"${project_name}\" && touch LICENSE MANIFEST.in  README.md  setup.py"
                ;;
        esac

}

_create_daywork_session() {
        # Create session..
        tmux new-session -d -s "${project_name}" -c "${working_dir}"

        # Create additional windows.
        tmux new-window -d -t "${project_name}:" -c "${working_dir}"
        tmux new-window -d -t "${project_name}:" -c "${working_dir}"
}

_create_and_attach_session() {
    if [ "${create_working_dir}" -eq 1 ]; then
        # Check if project dir already exists and create if not.
        if ! [ -d "${working_dir}" ]; then
            mkdir -p "${working_dir}"
        fi
    fi

    # Create new session if none with right name exists.
    if ! [ "$(tmux ls -F '#S' | grep -E "^${project_name}$")" = "${project_name}" ]; then
        case "${template}" in
            code)
                _create_code_session
                ;;
            daywork)
                _create_daywork_session
                ;;
        esac
    fi

    # Check if already attached to tmux session.
    # Switch session if already attached.
    # Open tmux and attach to session if not already attached.
    if [ -n "$TMUX" ]; then
        tmux switch-client -t "${project_name}"
    else
        tmux attach -t "${project_name}"
    fi
}

_run() {
    # A POSIX variable.
    # Reset in case getopts has been used previously in the shell.
    OPTIND=1

    # Parse command line arguments.
    while getopts "h?t:l:p:n" opt; do
        case "$opt" in
        h)
            _print_usage
            exit 0
            ;;
        t)
            template=$OPTARG
            ;;
        l)
            language=$OPTARG
            ;;
        p)
            project_name=$OPTARG
            working_dir="$HOME/Documents/projects/${project_name}"
            ;;
        n)
            working_dir="$HOME"
            create_working_dir=0
            ;;
        *)
            _print_usage
            exit 1
            ;;
        esac
    done

    _create_and_attach_session
}

_run "$@"
