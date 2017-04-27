#!/bin/bash
monitors=($(xrandr | grep -iw 'connected' | cut -d' ' -f1))

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done


if [ ${#monitors[@]} -eq 2 ] && [ ${#@} -eq 0 ]; then
    polybar extTop  -r &
    polybar intern -q -r &
elif [[ "$1" == "intern" ]]; then
    polybar intern -q -r &

elif [[ "$1" == "extern" ]]; then
    polybar extTop -q -r &
else
    echo "Something went wrong..."
fi

echo "Bars launched..."
