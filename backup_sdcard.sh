#!/usr/bin/env zsh

fs_type="exfat"
picture_dir="$HOME/Pictures/eos_550d"
readme_text="Fast Backup without readme."
disk_name="EOS_DIGITAL"
backup_dir=${picture_dir}/$(date "+%Y-%m-%d_%H-%M")
required_software=(pv)
batch_mode=""
no_color=""

colorize(){
    source ./format.sh > /dev/null 2>&1
    initANSI > /dev/null 2>&1
}

usage() {
    colorize
    printf "
    ${cyanf}INFO:${reset}
    $(basename $1) is a simple tool to backup sdcards and other external
    drives. It does so by creating a backup directory ans splitting raw
    pictures and jpeg files in different directorys.

    ${cyanf}USAGE:${reset}
    $(basename $1) 

    ${cyanf}Optional parameters:${reset}
    ${cyanf}-f${reset}  set filesystem type of disk 
    ${cyanf}-p${reset}  set picture directory to create backupfolder in it
    ${cyanf}-t${reset}  set README message for backup directory
    ${cyanf}-d${reset}  set disk name
    ${cyanf}-b${reset}  force backup, execute without asking
    ${cyanf}-c${reset}  force backup, execute without asking
    ${cyanf}-h${reset}  show this help message
    \n"
}

check_required_software(){
    for tool in ${required_software}; do
        if ! [ $(command -v  ${tool}) ]; then
            printf "\n${redf}${tool} needs to be installed.${reset}\n"
            exit 1
        fi
    done
}
            

choose_device(){
    local blockdevices=($(mount | grep ${fs_type} | \
        awk '{result=$1":"$3;print result}'))

    if [ ${#blockdevices[*]} -gt 1 ]; then
        select item in ${blockdevices[*]}; do
            sdcard=$(echo ${item} | cut -d: -f1)
            mountpoint=$(echo ${item} | cut -d: -f2)
            return
        done
    elif [ ${#blockdevices[*]} -eq 1 ]; then
        sdcard=$(echo ${blockdevices[1]} | cut -d: -f1)
        mountpoint=$(echo ${blockdevices[1]} | cut -d: -f2)
    else
        printf "${redf}No sdcard found.${reset}\n"
        exit 1
    fi
}

mk_backup_dir(){
    jpeg_dir=${backup_dir}/jpeg
    raw_dir=${backup_dir}/raw
    if [ -d ${backup_dir} ]; then
        printf "\n${redf}${backup_dir} already exists.${reset}\n"
        exit 1
    else
        mkdir ${backup_dir} ${raw_dir} ${jpeg_dir}
    fi
}

create_backup(){
    rsync_func(){
        source_directory=$1
        dest_dir=$2
        pattern=$3
        working_dir=$PWD
        cd ${source_directory}
        if [ "${pattern}" = "*.JPG" ]; then
            is_full=$(find $source_directory -name $pattern -type f | wc -l\
                | xargs)
            if ! [ "${is_full}" = "0" ]; then
                (( size = $(du -sck ${source_directory}/*.JPG | tail -1 |\
                    awk '{print $1}') * 1024 ))
                find ./ -name "${pattern}" -maxdepth 1 | tar -c -T -\
                    | pv -s ${size} | tar x -C ${dest_dir}
            else
                print "${redf}No files found.${reset}\n"
            fi
        elif [ "${pattern}" = "*.CR2" ]; then
            is_full=$(find $source_directory -name $pattern -type f | wc -l\
                | xargs)
            if ! [ "${is_full}" = "0" ]; then
                (( size = $(du -sck ${source_directory}/*.CR2 | tail -1 |\
                    awk '{print $1}') * 1024 ))
                find ./ -name "${pattern}" -maxdepth 1 | tar -c -T -\
                    | pv -s ${size} | tar x -C ${dest_dir}
            else
                print "${redf}No files found.${reset}\n"
            fi
        fi
        cd ${working_dir}
    }

    source_dir="${mountpoint}/DCIM/100CANON"

    printf "\nCopying ${magentaf}jepg${reset} files.\n"
    rsync_func ${source_dir} ${jpeg_dir} "*.JPG"

    printf "\nCopying ${magentaf}raw${reset} files.\n"
    rsync_func ${source_dir} ${raw_dir} "*.CR2"

    echo ${readme_text} > ${backup_dir}/README.md
}

format_sdcard(){
    diskutil eraseVolume ${fs_type} ${disk_name} ${sdcard}
}

unmount_sdcard(){
    diskutil umount ${mountpoint}
}


if [ $EUID -eq 0 ]; then
   printf "${redf}Please not run as root.${reset}\n"
   usage $0
   exit 1
fi

while getopts f:p:t:d:bch option; do
    case "${option}" in
        f) 
            fs_type=${OPTARG}
            ;;
        p)
            picture_dir=${OPTARG}
            ;;
        t)
            readme_text=${OPTARG}
            ;;
        d)
            disk_name=${OPTARG}
            ;;
        b)
            batch_mode="true"
            ;;
        c)
            no_color="true"
            ;;
        h)
            usage $0
            exit 0
            ;;
        \*) 
            usage $0
            exit 1
            ;;
        \?) 
            usage $0
            exit 1
            ;;
    esac
done

if [ -z ${no_color} ]; then
    colorize
fi

check_required_software
choose_device

if [ -z ${batch_mode} ]; then

    printf "\nCreate backup of: ${magentaf}%s${reset} currently mounted at:\
 ${magentaf}%s${reset} to: ${magentaf}%s${reset}?\n" \
        "${sdcard}" "${mountpoint}" "${backup_dir}"

    choices="${greenf}yes${reset} ${redf}no${reset}"
    emulate -L zsh
    setopt sh_word_split
    select choice in $choices; do
        if [ "${choice}" = "${greenf}yes${reset}" ]; then
            mk_backup_dir
            create_backup
            break 
        else
            break
        fi
    done   

    printf "\nFormat disk: ${magentaf}%s${reset} currently mounted at:\
 ${magentaf}%s${reset}?\n" \
        "${sdcard}" "${mountpoint}"
    
    select choice in $choices; do
        if [ "${choice}" = "${greenf}yes${reset}" ]; then
            format_sdcard
            break
        else
            break
        fi
    done
    printf "\nUnmount sdcard: ${magentaf}%s${reset} currently mounted at:\
 ${magentaf}%s${reset}?\n" \
        "${sdcard}" "${mountpoint}"
    
    select choice in $choices; do
        if [ "${choice}" = "${greenf}yes${reset}" ]; then
            unmount_sdcard
            break
        else
            break
        fi
    done
else
    mk_backup_dir
    create_backup
    format_sdcard
    unmount_sdcard
fi

