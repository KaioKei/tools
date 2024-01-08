#!/usr/bin/bash

local_addr="localhost"
local_port="8080"
remote_addr="localhost"
remote_port="8080"

function help(){
  printf "Usage:

  [Overview]
  Create an SSH bridge on localhost to a remote host and port using :
  ssh -L <local_addr>:<local_port>:<remote_addr>:<remote_port> <ssh_host> -N

  [command]
  shuttle.sh [arguments]

  [arguments]
  -h | --help    Print this.
  -la | --local-addr    Local host address for port forwarding. Default 'localhost'.
  -lp | --local-port    Local port number for port forwarding. Default '8080'.
  -ra | --remote-addr   Remote host address for port forwarding. Default 'localhost'.
  -rp | --remote-port   Remote port number for port forwarding. Default '8080'.
  -H | --ssh-host       SSH host information.
"
}

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    -h | --help)
        help
        exit 0
        ;;
    -la | --local-addr)
        local_addr="$2"
        shift 2
        ;;
    -lp | --local-port)
        local_port="$2"
        shift 2
        ;;
    -ra | --remote-addr)
        remote_addr="$2"
        shift 2
        ;;
    -rp | --remote-port)
        remote_port="$2"
        shift 2
        ;;
    -H | --ssh-host)
        ssh_host="$2"
        shift 2
        ;;
    *) # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        echo "! Unknown parameter"
        help
        shift              # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

cmd="ssh -L ${local_addr}:${local_port}:${remote_addr}:${remote_port} ${ssh_host} -N"

echo "$cmd"
exec $cmd

exit 0