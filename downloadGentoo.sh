#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   printf "Please run as root.\nUsage: sudo ./downloadGentoo.sh /dev/sdX\n"
   exit 1
fi
if [ $# -ne 1 ]; then
    printf "No path given. Or to many arguments.\nUsage: sudo ./downloadGentoo.sh /dev/sdX\n"
    exit 1
fi
if [ ! -b "$1" ]; then
    printf "The given path: \"$1\" does not exist.\nCheck if the usb-Device is plugged in and the path is correct\n"
    exit 1
fi
#format.sh is needed in same directory to use colors
if [ ! -f ./format.sh ]; then
    printf "\e[31mformat.sh musst be present to see colorized output.\nIgnore the following two error messages.\n\n\e[0m"
    echo " "
else
    source ./format.sh
    initANSI
fi
printf "${magentaf}Please be carefull running this script. Check if \"$1\" is the rigth device. It will be completely wiped.\n${reset}${redf}Correct device? (YES/n) Type uppercase YES.${reset}\n"
check=0
while [ $check -eq 0 ]; do
    read choice
    case $choice in
        "YES" )
            printf "Your responsibility...\n"
            check=1
            ;;
        *)
            printf "Restart the script and try again.\n"
            exit 1
            ;;
    esac
done
usb=$1
link='http://distfiles.gentoo.org/releases/amd64/autobuilds'
printf "${magentaf}Retrieving verion number.\n${reset}"
version=$(curl -# "$link/latest-iso.txt" | egrep '[[:digit:]]{8}/install-amd64-minimal-[[:digit:]]{8}.iso' | cut -d'/' -f1)
iso=install-amd64-minimal-$version.iso
digests=$iso.DIGESTS.asc
printf "\n${magentaf}Downloading iso file...\n${reset}"
curl -# -O $link/$version/$iso
printf "${magentaf}Downloading DIGETST.asc...\n${reset}"
curl -# -O $link/$version/$digests
printf "${magentaf}${boldon}Verifying files....\n${reset}"
printf "${magentaf}Downloading latest gpg keys...\n${reset}"
gpg --keyserver hkps.pool.sks-keyservers.net --recv-keys 0xBB572E0E2D182910
printf "${magentaf}Verifying DIGESTS...\n${reset}"
gpg --verify ./$digests
printf "${greenf}Please compare the following hashes:\n${reset}"
grep -A 1 -i sha512 ./$digests
sha512sum ./$iso
printf "${greenf}Everything okay? (y/n)\n${reset}"
check=0
while [ $check -eq 0 ]; do
    read choice
    case $choice in
        "y" )
            printf "Okay let's go on.\n"
            check=1
            ;;
        "n" )
            printf "It seems that some of the downloaded files are corrupt. Please check download source and restart.\n"
            rm ./$iso
            rm ./$digests
            check=1
            exit 1
            ;;
        *)
            printf "Sorry input: \"$choice\" could not be understood. Please try again\n==>"
            ;;
    esac
done
printf "Fomatting $usb...\n${greenf}Would you like to write the usb-drive with random data, for security reasons?${reset}\n${boldon}${redf}NOTE:${reset} This could take a while. (y/n)\n"
check=0
while [ $check -eq 0 ]; do
    read choice
    case $choice in
        "y" )
            printf "Writing random data to \"$usb\"...\nThis could take a while...\n"
            dd if=/dev/urandom of=$usb status=progress
            check=1
            ;;
        "n" )
            printf "Nothing to hide?\n"
            check=1
            ;;
        *)
            printf "Sorry input: \"$choice\" could not be understood. Please try again\n==>"
            ;;
    esac
done
wipefs -a $usb
fdisk $usb <<EOF
n




t
b
a
p
w
EOF
printf "${greenf}Everything okay? (y/n)\n${reset}"
check=0
while [ $check -eq 0 ]; do
    read choice
    case $choice in
        "y" )
            check=1
            printf "Okay let's go on.\n"
            ;;
        "n" )
            printf "${greenf}Would you like to format the usb-drive manually or abort? (y: format/n: abort)\n${reset}"
            read choice
            case $choice in
                "y" )
                    wipefs -a $usb
                    fdisk $usb
                    check=1
                    ;;
                "n" )
                    rm ./$iso
                    rm ./$digests
                    check=true
                    exit 1
                    ;;
                *)
            esac
            ;;
        *)
            printf "Sorry input: \"$choice\" could not be understood. Please try again\n==>"
            ;;
    esac
done
printf "${magentaf}Finally writing iso image to usb-drive...\n${reset}"
if [ -f /bin/pv ] || [ -f /sbin/pv ] || [ -f /usr/bin/pv ] || [ -f /usr/sbin/pv ] || [ -f /usr/local/bin/pv ] || [ -f /usr/local/bin/pv ]; then
    size=$(stat -c%s ./$iso)
    dd if=./$iso | pv -pteras $size | dd of=$usb
else
    printf "${greenf}pv is not present on your system... so no fancy status bar just dd status.\n${reset}"
    dd if=./$iso of=$usb status=progress oflag=direct
fi
rm ./$iso
rm ./$digests
printf "${redf}TODO:\nCreate Backups.\ngit commit and git push\nand don't screw up on installation.\nHave fun!\n${reset}"
