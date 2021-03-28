# Scripts

> Just some scripts to automate my workflow and some fun stuff.

This repo is a subrepo of my
[.dotfiles](https://github.com/oliverwiegers/dotfiles) and the install script
in there will create a symlink to `$HOME/.local/bin/`. This is contained in my
PATH variable.

## Helper Scripts

Scripts that pose as helper scripts for specific tools are always prefixed
with the tool name.

For example: `tmux_create_sessions.sh` is a helper script to manage tmux
sessions.
 
## Additional information

### todo.sh

In order for this script to be usefull a crontab like the following is needed:

```
DISPLAY=:0
SHELL=/usr/bin/bash
PATH=/usr/bin:/bin
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
1 * * * * /home/oliverwiegers/Documents/scripts/todo.sh
```
