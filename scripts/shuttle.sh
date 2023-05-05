#!/usr/bin/bash

host=""
port=""

function help(){
  printf "Usage:

  [Overview]
  Create an SSH bridge on localhost to a remote host and port using :
  ssh -L <host_port>:localhost:<remote_port> <remote_host> -N

  [command]
  shuttle.sh [arguments]

  [arguments]
  -h | --help    Print this.
  -H | --host    Remote host to target for the SSH bridge.
  -p | --port    Remote port to target for the SSH bridge.
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
    -p | --port)
        port="$2"
        shift 2
        ;;
    -H | --host)
        host="$2"
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

cmd="ssh -L ${port}:localhost:${port} ${host} -N"
echo "$cmd"
exec $cmd
