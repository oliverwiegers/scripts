#!/bin/bash

initializeANSI()
{
    esc="$(echo -en '\e')"
    purplef="${esc}[35m"
    boldon="${esc}[1m"
    coloron="${purplef}${boldon}"
    reset="${esc}[0m"
}

reloadConfig(){
    source $HOME/.zshrc && echo 'Successfully reloaded zsh_config_files'
}

initializeANSI

printf "Hello $USER please insert one of the following:\n
${coloron}0:${reset} to edit the ${coloron}.zshrc${reset}\n
${coloron}1:${reset} to edit the ${coloron}zsh_aliases${reset}\n
${coloron}2:${reset} to edit the ${coloron}zsh_settings${reset}\n
${coloron}3:${reset} to edit the ${coloron}xmonad_config${reset}\n
${coloron}4:${reset} to edit the ${coloron}.xinitrc${reset}\n
${coloron}5:${reset} to edit the ${coloron}.vimrc${reset}\n
${coloron}6:${reset} to edit the ${coloron}polybar_config${reset}\n
${coloron}hack:${reset} for ${coloron}this${reset} script\n
${coloron}anything else:${reset} to ${coloron}leave....${reset}\n
${boldon}=>>${reset}"
read choice
case $choice in
    "0" )
        $EDITOR $HOME/.zshrc
        ;;
    "1" )
        $EDITOR $HOME/.config/zsh/zsh_aliases
        ;;
    "2" )
        $EDITOR $HOME/.config/zsh/zsh_settings
        ;;
    "3" )
        $EDITOR $HOME/.xmonad/xmonad.hs
        xmonad --recompile
        ;;
    "4" )
        $EDITOR $HOME/.xinitrc
        ;;
    "5" )
        $EDITOR $HOME/.vimrc
        ;;
    "6" )
        $EDITOR $HOME/.config/polybar/config
        ;;
    "hack" )
        $EDITOR $SCRIPT_DIR/edit_config.sh
        ;;
    *)
esac
printf "Well done! See you!\n"
