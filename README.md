# scripts

> Just some scripts to automate my workflow and some fun stuff.

I host this scripts under `$HOME/Documents/scripts`. This scripts will be
cloned by my [config](https://github.com/oliverwiegers/dotfiles) install script 
if needed.
 
## Additional information

### todo.sh

In order for this script to be usefull the following crontab is needed:

```
DISPLAY=:0
SHELL=/usr/bin/bash
PATH=/usr/bin:/bin
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
1 * * * * /home/oliverwiegers/Documents/scripts/todo.sh
```

### pacman.sh && invaders.sh

These script are aliases to `pac` and `invade` and show some ascii art.

### nmgui

Because of `nmtui` and `nmcli` not being able to manage WPA2 Enterprise
connections I use `network-manager-apllet` and this is show by trayer if I need
to see it. Normally I don't.
