#!/usr/bin/env sh

# A POSIX variable.
# Reset in case getopts has been used previously in the shell.
OPTIND=1

# Print usage.
print_usage() {
    usage="$(basename "$0") [OPTIONS]

    Script to interact with luks encrypted USB stick.

        -h            show this usage.
        -m  DEVICE    luks mount device.
        -u            unmount device."

    printf '%s\n' "${usage}"
}

luks_mount() {
    cryptsetup open "/dev/$1" private
    mount /dev/mapper/private /mnt/root
}

luks_umount() {
    umount /mnt/root
    cryptsetup close /dev/mapper/private
}


# Parse command line arguments.
while getopts "hm:u" opt; do
    case "$opt" in
    h)
        print_usage
        exit 0
        ;;
    m)
        arg=$OPTARG
        luks_mount "${arg}"
        ;;
    u)
        luks_umount
        ;;
    *)
        print_usage
        exit 1
        ;;
    esac
done
