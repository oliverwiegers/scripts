#!/usr/bin/env bash

_printUsage() {
    local usage
    usage="$(basename "$0") [OPTIONS]

    print overview of several services.

        --help                print this help message.
        --system-info         print general system info.
        --network-interfaces  print active network interfaces.
        --diskusage           print current diskusage.
        --taskwarrior         print taskwarrior items.
        --docker-containers   print docker containers.
        --docker-stats        print docker container system usage.
        --ssh-sessions        print current ssh sessions to remote server.
        --ssh-connections     print ssh connections to local machine.
        --tmux-sessions       print tmux sessions.
        --nginx-vhosts        print active nginx vhosts.
        --nginx-status        print nginx status.
        --apache-vhosts       print active apache vhosts.
        --apache-status       print nginx status.
        --all                 print overview for all services.
        --no-defaults         do not print default service overview.
        --no-icons            do not use Nerdfont icons.
        "

    printf '%s\n' "${usage}"
}

_depCheck() {
    local cmd
    local is_daemon

    cmd="$1"
    is_daemon="$2"
    if [ ! "$(command -v "${cmd}")" ]; then
        printf '%s is not installed.\n' "${cmd}"
        return 1
    elif [ "${is_daemon}" = "true" ]; then
        if [ "$(find /var/run/ -type f -name "${cmd}.pid" 2>&1\
            | grep -v 'Permission denied' -c)" -ne 1 ]; then
            printf '%s is not running.\n' "${cmd}"
            return 1
        fi
    fi
}

# All tool names for optional statistics.

tools=(
    task
    tmux
)

daemons=(
    docker
    nginx
    apache2
)

# Command line parsing variable.
system_info=0
network_interfaces=0
diskusage=0
taskwarrior=0
docker_containers=0
docker_stats=0
ssh_sessions=0
tmux_sessions=0
ssh_connections=0
nginx_vhosts=0
nginx_status=0
apache_vhosts=0
apache_status=0
defaults=1
icons=1

while [ $# -gt 0 ]; do
    key="$1"

    case "${key}" in
        --help)
            _printUsage
            exit 0
            ;;
        --system-info)
            system_info=1
            shift
            ;;
        --network-interfaces)
            network_interfaces=1
            shift
            ;;
        --diskusage)
            diskusage=1
            shift
            ;;
        --taskwarrior)
            if ! _depCheck "task" "false"; then
                exit 1
            fi
            taskwarrior=1
            shift
            ;;
        --docker-containers)
            if ! _depCheck "docker" "true"; then
                exit 1
            elif ! groups | grep -q docker; then
                printf '%s is not part of group "docker".\n' "$(whoami)"
                exit 1
            fi
            docker_containers=1
            shift
            ;;
        --docker-stats)
            if ! _depCheck "docker" "true"; then
                exit 1
            elif ! groups | grep -q docker; then
                printf '%s is not part of group "docker".\n' "$(whoami)"
                exit 1
            fi
            docker_stats=1
            shift
            ;;
        --ssh-sessions)
            ssh_sessions=1
            shift
            ;;
        --ssh-connections)
            ssh_connections=1
            shift
            ;;
        --tmux-sessions)
            if ! _depCheck "tmux" "false"; then
                exit 1
            fi
            tmux_sessions=1
            shift
            ;;
        --nginx-vhosts)
            if ! _depCheck "nginx" "true"; then
                exit 1
            fi
            nginx_vhosts=1
            shift
            ;;
        --nginx-status)
            if ! _depCheck "nginx" "true"; then
                exit 1
            fi
            nginx_status=1
            shift
            ;;
        --apache-vhosts)
            if ! _depCheck "apache2" "true"; then
                exit 1
            fi
            apache_vhosts=1
            shift
            ;;
        --apache-status)
            if ! _depCheck "apache2" "true"; then
                exit 1
            fi
            apache_status=1
            shift
            ;;
        --all)
            system_info=1
            network_interfaces=1
            diskusage=1
            taskwarrior=1
            docker_containers=1
            docker_stats=1
            ssh_sessions=1
            tmux_sessions=1
            ssh_connections=1
            nginx_vhosts=1
            nginx_status=1
            apache_vhosts=1
            apache_status=1
            defaults=0
            for tool in "${tools[@]}"; do
                if ! _depCheck "${tool}" "false" > /dev/null; then
                    if [ "${tool}" = 'task' ]; then
                        taskwarrior=0
                    elif [ "${tool}" = 'tmux' ]; then
                        tmux_sessions=0
                    fi
                fi
            done

            for daemon in "${daemons[@]}"; do
                if ! _depCheck "${daemon}" "true" > /dev/null; then
                    if [ "${daemon}" = 'nginx' ]; then
                        nginx_vhosts=0
                        nginx_status=0
                    elif [ "${daemon}" = 'docker' ]; then
                        docker_containers=0
                        docker_stats=0
                    elif [ "${daemon}" = 'apache2' ]; then
                        apache_vhosts=0
                        apache_status=0
                    fi
                fi
            done
            shift
            ;;
        --no-defaults)
            defaults=0
            shift
            ;;
        --no-icons)
            icons=0
            shift
            ;;
        *)
            printf 'Illegal option %s\n' "${key}"
            exit 1
            ;;
    esac
done

if [ $# -gt 0 ]; then
    printf 'Wrong number of arguments.\n'
    exit 1
fi

_printTableHelper() {
    local table_data
    local headline
    local type
    local icon
    local header
    local body
    local length
    local line

    table_data="$1"
    headline="$2"
    type="$3"
    icon="$4"

    if [ "${type}" = file ]; then
        if [ "$(wc -l "${table_data}" | awk '{print $1}')" -lt 2 ]; then
            if [ "${icons}" -eq 1 ]; then
                printf '\033[1m %b ' "${icon}"
            fi
            printf "\033[1m%s:\033[0m\n\n"\
                "${headline}"
            printf '\t\033[31mNo data found.\033[0m\n\n'
            return 0
        fi
    else
        if [ "$(echo "${table_data}" | wc -l)" -lt 2 ]; then
            if [ "${icons}" -eq 1 ]; then
                printf '\033[1m %b ' "${icon}"
            fi
            printf "\033[1m%s:\033[0m\n\n"\
                "${headline}"
            printf '\t\033[31mNo data found.\033[0m\n\n'
            return 0
        fi

    fi

    if [ "${type}" = "file" ]; then
        header="$(column -t -s ',' "${table_data}" | head -1 | sed 's/^/\t/')"
        body="$(column -t -s ',' "${table_data}" | tail -n+2 | sed 's/^/\t/')"
    else
        header="$(echo "${table_data}" | column -t -s ',' | head -1 | sed 's/^/\t/')"
        body="$(echo "${table_data}" | column -t -s ',' | tail -n+2 | sed 's/^/\t/')"
    fi

    header_length="$(echo "${header}" | sed 's/\t//g' | wc -L)"
    body_length="$(echo "${body}" | sed 's/\t//g' | wc -L)"
    length="${header_length}"
    if [ "${length}" -lt "${body_length}" ]; then
        length="${body_length}"
    fi
    line="$(printf "%-${length}s" | tr ' ' '-' | sed 's/^/\t/')"

    # Print table header.
    if [ "${icons}" -eq 1 ]; then
        printf '\033[1m %b ' "${icon}"
    else
        printf '\n'
    fi

    printf "\033[1m%s:\033[0m\n\n\033[0;36m%s\033[0m\n"\
        "${headline}" "${header}"
    printf '%s\n' "${line}"

    # Print table body.
    printf "\033[0;32m%s\033[0m\n" "${body}"
    printf '\n'

    if [ "${type}" = "file" ]; then
        rm "${table_data}"
    fi
}

_sysInfo() {
    if [ "$(uname)" = "Linux" ]; then
        local os
        local hostname
        local uptime
        local cpu_usage
        local total_ram
        local used_ram

        os="$(awk -F'"' '/^NAME/ { print $2 }' /etc/os-release)"
        hostname="$(hostname)"
        uptime="$(uptime -p | sed 's/up //;')"
        load="$(uptime | rev | cut -d':' -f1 | rev | xargs)"
        cpu_usage="$( grep 'cpu ' /proc/stat\
            | awk\
            '{usage=($2+$4)*100/($2+$4+$5)} END {printf ("%0.2f\n",usage) }')"
        total_ram="$(free\
            | awk '/Mem:/{ total=$2/1000/1000; printf ("%3.1f\n", total) }')"
        used_ram="$(free\
            | awk '/Mem:/{ used=$3/1000/1000; printf ("%3.1f\n", used) }')"

        # Print system info.
        if [ "${icons}" -eq 1 ]; then
            printf '\033[1m  '
        fi
        printf "\033[1m%-10s\033[0m \033[0;36m%s\n\033[0m"\
            "OS:" "${os}"

        if [ "${icons}" -eq 1 ]; then
            printf '\033[1m  '
        fi
        printf "\033[1m%-10s\033[0m \033[0;36m%s\n\033[0m"\
            "Uptime:" "${uptime}"

        if [ "${icons}" -eq 1 ]; then
            printf '\033[1m  '
        fi
        printf "\033[1m%-10s\033[0m \033[0;36m%s\n\033[0m"\
            "Hostname:" "${hostname}"

        if [ "${icons}" -eq 1 ]; then
            printf '\033[1m  '
        fi
        printf "\033[1m%-10s\033[0m \033[0;36m%s\n\033[0m"\
            "Load:" "${load}"

        if [ "${icons}" -eq 1 ]; then
            printf '\033[1m  '
        fi
        printf "\033[1mCPU usage:\033[0m \033[0;36m%s %%\n\033[0m"\
            "${cpu_usage}"

        if [ "${icons}" -eq 1 ]; then
            printf '\033[1m  '
        fi
        printf "\033[1mRAM usage:\033[0m \033[0;36m%s GB / %s GB\n\033[0m"\
            "${used_ram}" "${total_ram}"

        printf '\n'
    fi
}

_networkInterfaces() {
    local table_data
    local header
    local body
    local length
    local line

    table_data="$(mktemp)"
    printf 'Interface,IP Range\n' > "${table_data}"
    ip -4 -o a\
        | awk '/127.0.0.1/ { next } { print $2 "," $4 }' >> "${table_data}"

    _printTableHelper "${table_data}" "Network Interfaces" "file" "ﯱ"
}
_diskusage() {
    _printTableHelper\
        "$(df -h --output=target,size,used,avail,pcent --total)"\
        "Disk Usage"\
        "string"\
        ""
}

_taskwarrior() {
    _printTableHelper\
        "$(task list | sed '1d;3d;$ d')"\
        "Taskwarrior"\
        "string"\
        ""
}

_dockerContainers() {
    _printTableHelper\
        "$(docker ps --format 'table {{.Names}},{{.Image}},{{.Status}}')"\
        "Docker Containers"\
        "string"\
        ""
}

_dockerStats() {
    _printTableHelper\
        "$(docker stats --no-stream --format\
        "table {{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.NetIO}},{{.PIDs}}")"\
        "Docker Stats"\
        "string"\
        ""
}

_sshSessions() {
    local sessions
    local table_data
    local session
    local ip
    local port
    local rdns

    sessions="$(ss -atnp | awk '/ssh/ {print $5}')"
    table_data="$(mktemp)"

    printf 'IP,Port,rDNS Name\n' > "${table_data}"

    for session in ${sessions}; do
        IFS=':' read -r ip port <<<"${session}"
        rdns="$(dig +short -x "${ip}")"
        printf '%s,%s,%s\n' "${ip}" "${port}" "${rdns}" >> "${table_data}"
    done

    _printTableHelper "${table_data}" "SSH Sessions" "file" ""
}

_sshConnections() {
    local connections
    local table_data
    local connection
    local client_ip
    local port
    local rdns

    connections="$(ss | awk '/ssh/ {print $6}')"
    table_data="$(mktemp)"

    printf 'Client IP,rDNS Name\n' > "${table_data}"

    for connection in ${connections}; do
        IFS=':' read -r client_ip port <<<"${connection}"
        rdns="$(dig +short -x "${client_ip}")"
        printf '%s,%s\n' "${client_ip}" "${rdns}" >> "${table_data}"
    done

    _printTableHelper "${table_data}" "SSH Connections" "file" ""
}

_tmuxSessions() {
    local sessions
    local table_data
    local session
    local name
    local windows
    local pid
    local user

    sessions="$(\
        tmux list-sessions -F\
        '#{session_name},#{session_windows},#{pane_pid}' 2> /dev/null)"
    table_data="$(mktemp)"

    printf 'Name,Windows,User\n' > "${table_data}"

    for session in ${sessions}; do
        IFS=',' read -r name windows pid <<<"${session}"
        # Can't use pgrep. Not searching for for pid but for user name.
        # shellcheck disable=SC2009
        user="$(ps -axo pid,user | grep "${pid}" | awk '{print $2}')"
        printf '%s,%s,%s\n'\
            "${name}" "${windows}" "${user}" >> "${table_data}"
    done

    _printTableHelper "${table_data}" "Tmux Sessions" "file" ""
}

_nginxVhosts() {
    local vhosts
    local table_data
    local line
    local file
    local server_names

    vhosts="$(grep -r -E '( server_name ).*\;' /etc/nginx/ | awk '{$2=""; print $0}' | tr -d ';:')"
    table_data="$(mktemp)"

    printf 'vHost File,Server Names\n' > "${table_data}"
    while read -r line; do
            read -r file server_names <<<"${line}"
            printf '%s,%s\n' "${file}" "${server_names}" >> "${table_data}"
    done <<<"${vhosts}"

    _printTableHelper "${table_data}" "Nginx vHosts" "file" ""
}

_nginxStatus() {
    local status
    local table_data
    local line
    local file
    local server_names

    table_data="$(mktemp)"
    status="$(curl -s localhost:80/nginx_status)"

    printf 'Key,Value\n' > "${table_data}"

    {
    printf 'Active Connections,%s\n'\
        "$(echo "${status}" | awk '/Active/ {print $3}')"

    printf 'Server Accepts,%s\n'\
        "$(echo "${status}" | grep -A 1 server | tail -1 | awk '{print $1}')"
    printf 'Server Handled,%s\n'\
        "$(echo "${status}" | grep -A 1 server | tail -1 | awk '{print $2}')"
    printf 'Server Requestst,%s\n'\
        "$(echo "${status}" | grep -A 1 server | tail -1 | awk '{print $3}')"

    echo "${status}" | tail -1 | awk '{print $1 $2}' | tr ':' ','
    echo "${status}" | tail -1 | awk '{print $3 $4}' | tr ':' ','
    echo "${status}" | tail -1 | awk '{print $5 $6}' | tr ':' ','
    } >> "${table_data}"

    _printTableHelper "${table_data}" "Nginx Status" "file" ""
}

_apacheVhosts() {
    local vhosts
    local table_data
    local line
    local file
    local server_names

    # shellcheck disable=SC1091
    source /etc/apache2/envvars
    vhosts="$(apache2 -t -D DUMP_VHOSTS 2> /dev/null\
        | grep -v 000-default.conf\
        | awk '/namevhost/ {print $4 " " $5}'\
        | tr -d '(:)')"
    table_data="$(mktemp)"

    printf 'vHost File,Server Name\n' > "${table_data}"
    while read -r line; do
            read -r server_name file <<<"${line}"
            printf '%s,%s\n' "${file%?}" "${server_name}" >> "${table_data}"
    done <<<"${vhosts}"

    _printTableHelper "${table_data}" "Apache vHosts" "file" ""
}

_apacheStatus() {
    local status
    local table_data
    local line
    local file
    local server_names

    table_data="$(mktemp)"
    status="$(curl -s localhost:80/server-status)"

    printf 'Key,Value\n' > "${table_data}"

    {
    printf 'Current Requests,%s\n'\
        "$(echo "${status}" | awk '/idle workers/ {print $1}' | tr -d '<dt>')"
    printf 'Idle Workers,%s\n'\
        "$(echo "${status}" | awk '/idle workers/ {print $6}')"

    printf 'Total Accesses,%s\n'\
        "$(echo "${status}" | awk '/Total accesses/ {print $3}')"
    } >> "${table_data}"

    _printTableHelper "${table_data}" "Apache Status" "file" ""
}

_main() {
    if [ "${defaults}" -eq 1 ]; then
        _sysInfo
        _networkInterfaces
        _diskusage
    fi

    if [ "${system_info}" -eq 1 ] && [ "${defaults}" -ne 1 ]; then
        _sysInfo
    fi

    if [ "${network_interfaces}" -eq 1 ] && [ "${defaults}" -ne 1 ]; then
        _networkInterfaces
    fi

    if [ "${diskusage}" -eq 1 ] && [ "${defaults}" -ne 1 ]; then
        _diskusage
    fi

    if [ "${taskwarrior}" -eq 1 ]; then
        _taskwarrior
    fi

    if [ "${docker_containers}" -eq 1 ]; then
        _dockerContainers
    fi

    if [ "${docker_stats}" -eq 1 ]; then
        _dockerStats
    fi

    if [ "${ssh_sessions}" -eq 1 ]; then
        _sshSessions
    fi

    if [ "${ssh_connections}" -eq 1 ]; then
        _sshConnections
    fi

    if [ "${tmux_sessions}" -eq 1 ]; then
        _tmuxSessions
    fi

    if [ "${nginx_vhosts}" -eq 1 ]; then
        _nginxVhosts
    fi

    if [ "${nginx_status}" -eq 1 ]; then
        _nginxStatus
    fi

    if [ "${apache_vhosts}" -eq 1 ]; then
        _apacheVhosts
    fi

    if [ "${apache_status}" -eq 1 ]; then
        _apacheStatus
    fi
}

_main
