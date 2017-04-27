#!/bin/bash

if [ $(ps -a | grep "xmonad-x86_64-l" | wc -l) -eq 1 ] ; then
    sh $SCRIPT_DIR/xsettings.sh
    unclutter -idle 1 &
    compton -c &
    sh $HOME/.fehbg
    setxkbmap gb
    xinput disable 13
fi
