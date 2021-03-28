#!/usr/bin/env sh

project_name="$1"
project_dir="$HOME/Documents/projects/${project_name}"

# Check if project dir already exists and create if not.
if ! [ -d "${project_dir}" ]; then
    mkdir -p "${project_dir}"
fi

# Create new session if none with right name exists.
if ! [ "$(tmux ls -F '#S' | grep -E "^${project_name}$")" = "${project_name}" ]; then
    # Create session..
    tmux new-session -d -s "${project_name}" -c "${project_dir}" -n "editor"

    # Create additional windows.
    tmux new-window -d -t "${project_name}:" -c "${project_dir}" -n "shell"
    tmux new-window -d -t "${project_name}:" -c "${project_dir}" -n "testing"
    tmux new-window -d -t "${project_name}:" -c "${project_dir}" -n "man-pages"
    tmux new-window -d -t "${project_name}:" -c "${project_dir}" -n "docs"
fi

# Check if already attached to tmux session.
# Switch session if already attached.
# Open tmux and attach to session if not already attached.
if [ -n "$TMUX" ]; then
    tmux switch-client -t "${project_name}"
else
    tmux attach -t "${project_name}"
fi
