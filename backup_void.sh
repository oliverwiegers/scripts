#!/usr/bin/env sh

# A POSIX variable.
# Reset in case getopts has been used previously in the shell.
OPTIND=1

local_user="$(whoami)"
remote_user='root'
target='192.168.1.1'
target_dir='/mnt/backup'
incremental=0
key="/home/${local_user}/.ssh/id_rsa"
logfile="$HOME/.local/var/log/backup.log"
create_date_dir=1

# Print usage.
print_usage() {
    usage="$(basename "$0") [OPTIONS]

    Dummy message.

        -h                  show this usage.
        -l  LOCAL_USER      user to take ssh key from.
        -r  REMOTE_USER     user to login into target host.
        -t  TARGET          IP of target host.
        -d  TARGET_DIR      target dir on target host.
        -i                  create incremental backup.
        -k  KEY             SSH key to use.
        -f  LOGFILE         logfile."

    printf '%s\n' "${usage}"
}


# Parse command line arguments.
while getopts "h?l:r:t:id:k:" opt; do
    case "$opt" in
    h)
        print_usage
        exit 0
        ;;
    l)
        local_user=$OPTARG
        key="/home/${local_user}/.ssh/id_rsa"
        ;;
    r)
        remote_user=$OPTARG
        ;;
    t)
        target=$OPTARG
        ;;
    i)
        incremental=1
        ;;
    d)
        target_dir=$OPTARG
        create_date_dir=0
        ;;
    k)
        key=$OPTARG
        ;;
    *)
        print_usage
        exit 1
        ;;
    esac
done


if [ "${incremental}" -eq 1 ]; then
    target_path='/mnt/backup/incremental'
else
    target_path="${target_dir}"
fi

date_string="$(date +%Y%d%m)"

if [ "${create_date_dir}" -ne 1 ]; then
    target_path="${target_dir}/${date_string}"
    ssh -i "${key}" "${remote_user}@${target}" \
        mkdir "${target_path}" >> "${logfile}" 2>&1
fi

rsync -e "ssh -i \"${key}\"" \
    -avuP --exclude '.git' \
    /etc "/home/${local_user}" \
    "${remote_user}@${target}:${target_path}" >> "${logfile}" 2>&1

