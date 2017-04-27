#!/bin/bash

if [ ! zsh ]; then
    echo "Please istall z shell first...\n"
    exit 1
fi

# create directories
mkdir $HOME/pictures
mkdir $HOME/downlods
mkdir $HOME/documents

# clone dotfiles repo
git config --global user.name "chrootzius"
git config --global user.email "oliver.wiegers@gmail.com"
git init
git remote add origin master https://github.com/chrootzius/dotfiles
git pull origin master
git status

#todo include ssh and gpg keys
echo "Change repo address from https to ssl.\n"
options="Yes No"
select opt in $options; do
    if [ "$opt" = "Yes" ]; then
        vim $HOME/.git/config
    elif [ "$opt" = "No" ]; then
     echo "Okay do it later.\n"
    else
     clear
     echo "Bad option\n"
    fi
done

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo "source $HOME/.config/zsh/zsh_prompt" >> $HOME/.zshrc
echo "source $HOME/.config/zsh/zsh_aliases" >> $HOME/.zshrc
echo "source $HOME/.config/zsh/zsh_settings" >> $HOME/.zshrc
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

echo "Change zsh theme to \"ZSH_THEME=\"powerlevel9k/powerlevel9k\"\".\n"
options="Yes No"
select opt in $options; do
    if [ "$opt" = "Yes" ]; then
        vim $HOME/.zshrc
    elif [ "$opt" = "No" ]; then
     echo "Okay do it later.\n"
    else
     clear
     echo "Bad option\n"
    fi
done
sudo chsh -s /bin/zsh $USER
