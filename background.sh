#!/bin/bash
feh=$HOME/.fehbg
check=false

printf "Change background? %s/%s\n" "y" "n"
read choice

case $choice in
    "y" )
        printf "Choose one of the following:\n\n"
        ls -l $HOME/Pictures/wallpaper/ | tail -n+2 | awk '{print $9}'
        echo " "
        while [ "$check" != true ]; do
            printf "Insert the full name of the wallpaper you want to choose.\n\n"
            read pic
            if [ -f $HOME/Pictures/wallpaper/$pic ]; then
                echo "#!/bin/bash" > $feh
                echo "feh  --bg-fill '$HOME/Pictures/wallpaper/$pic'" >> $feh
                echo "eof" >> $feh
                chmod 0744 $feh
                sh $feh
                printf "DONE! Bye...\n"
                check=true
            else
                printf "\nPlease try again...\n\n"
            fi
        done
        ;;
    *)
    printf "Why the fuck did you run this script?!\n"
    ;;
esac
