#!/usr/bin/env sh

# Main function definition.
main() {
    killall dunst
    ln -sf "$HOME/.cache/wal/dunstrc" "$HOME/.config/dunst/"
}

# Execution of functions.
main
