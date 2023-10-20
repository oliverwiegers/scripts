#!/usr/bin/env bash

_print_rabbit() {
    cat << EOF
                (\`.         ,-,
                \`\ \`.    ,;' /
                 \`. \ ,'/ .'
           __     \`.\ Y /.'
        .-'  ' '--.._\` \`(
      .'            /   \`
     ,           \` '   Q '
     ,         ,   \`._    \\
  ,.|          '     \`-.;_'
  :  . \`  ;    \`  \` --,.._;
   ' \`    ,   )   .'
      \`._ ,  '   /_
         ; ,''-,;' \`\`-
          \`\`-..__\\\`\`--\`
EOF
}

# Define lines to be printed character by character.
lines=(
    'Wake up, Neo...'
    'The Matrix has you...'
    'Follow the white rabbit.'
)

# Clear screen.
clear

# Get some space between prompt and output.
printf '\n'

# Print lines character by character.
for line in "${lines[@]}"; do
    # Set color and formatting
    printf '\e[1m\e[32m'
    # Get some space between screen border and output.
    printf '  '

    # Per line character by character printing.
    while [ ${#line} -gt 0 ]; do
        printf '%s' "${line%"${line#?}"}"
        line=${line#?}
        sleep 0.1
    done

    # Sleep between lines being printed.
    sleep 0.5

    # Reset formatting.
    printf '\e[0m'
    printf '\n'
done

# Print knock, knock.
sleep 0.5
printf '\e[1m'
printf '\n  Knock, knock, Neo.\n\n'
printf '\e[0m'

# Hide cursor.
tput civis

# Print first rabbit representation.
printf '\e[1m\e[32m'
_print_rabbit
printf '\e[0m'

# Print rabbit ascii art.
for _ in $(seq 0 1); do
    sleep 1
    # Set cursor on line 7 column 0.
    tput cup 7 0
    # Clear screen from current position to end of screen.
    tput ed
    sleep 1
    printf '\e[1m\e[32m'
    _print_rabbit
    printf '\e[0m'
done

# Print transmission status.
sleep 1
printf '\n  Call tans opt: received. 2-19-98 13:24:28 REC:Loc\n\n'

# Print trace program status.
printf '  Trace program: \e[1mrunning\e[0m\n'
for _ in $(seq 0 3); do
    sleep 1
    # Set cursor on line 24 column 17.
    tput cup 24 17
    # Clear screen from current position to end of screen.
    tput ed
    sleep 1
    printf '\e[1mrunning\e[0m\n'
printf '\n'
done

# Reset formatting.
printf '\e[0m'

# Unhide cursor.
tput cnorm
