#!/bin/sh
#
# toggles touchpads on/off
# Supported are both Synaptics and Elantech touchpads

# sanity check
if [ ! -x /usr/bin/xinput ]; then
    echo "Error: /usr/bin/xinput not found"
    exit 1
fi

getTouchDeviceId()
{
# extract the device id for the supplied touch device name
    xinput list | sed -nr "s|.*$1.*id=([0-9]+).*|\1|p"
}

# Get the xinput device number and enabling property for the touchpad
XINPUTNUM=$(getTouchDeviceId "SynPS/2 Synaptics TouchPad")
ENABLEPROP="Synaptics Off"
if [ -z "$XINPUTNUM" ]; then
    XINPUTNUM=$(getTouchDeviceId "PS/2 Elantech Touchpad")
    ENABLEPROP="Device Enabled"
fi

# if we failed to get an input, exit
[ -z "$XINPUTNUM" ] && exit 1

# get the current state of the touchpad
TPSTATUS=$(xinput list-props $XINPUTNUM | awk "/$ENABLEPROP/ { print \$NF }")

# if getting the status failed, exit
[ -z "$TPSTATUS" ] && exit 1

if [ $TPSTATUS = 0 ]; then
    xinput set-prop $XINPUTNUM "$ENABLEPROP" 1
else
    xinput set-prop $XINPUTNUM "$ENABLEPROP" 0
fi
