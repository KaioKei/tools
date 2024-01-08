#!/usr/bin/env bash

# VARIABLES
hosts=""
domain=""

# FUNCTIONS
function help(){
    printf "[Overview]
Reset the ssh known access to a guest using :
ssh-keygen -f <known_hosts_path> -R <hostname>

[Arguments]
--host,-H               List of SSH hosts separated with ','.

[Options]
--domain,-d             Parent DNS domain for the hosts.
"
}

function main(){
  # extract
  IFS=',' read -ra hosts_list <<< "$hosts"
  for host in "${hosts_list[@]}"; do
    echo ". Remove known host ${host} access."
    if [ -n "${domain}" ]; then
      host="${host}.${domain}"
    fi
    ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "${host}"
  done
}

# PARSING
if [ $# -eq 0 ]; then help; fi
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    -h|--help|help)
        help
        exit 0
        ;;
    --host | -H)
        hosts="$2"
        shift 2
        ;;
    --domain | -d)
        domain="$2"
        shift 2
        ;;
    *) # unknown option
        echo "! Unknown parameter : $1"
        exit 1
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

main

echo ". Done"
exit 0
