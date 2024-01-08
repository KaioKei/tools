#!/usr/bin/env bash

# VARIABLES
hosts=""
path=""
user=""

# FUNCTIONS
function help(){
    printf "[Overview]
Reset the ssh known access to a guest using :
ssh-keygen -f <known_hosts_path> -R <hostname>

[Arguments]
--host,-H [names]               List of SSH hosts separated with ','.
--path,-p <path>                Path of the public key to upload on host.

[Options]
--user,-u                       Provide a user to inject keys.
"
}

function main(){
  # extract
  IFS=',' read -ra hosts_list <<< "$hosts"
  content="$(cat "${path}")"
  for host in "${hosts_list[@]}"; do
    if [ -n "${user}" ]; then
      host="${user}@${host}"
    fi
    echo ". Upload ${path} key content to host ${host}"
    ssh -o StrictHostKeyChecking=no "${host}" "echo '${content}' >> .ssh/authorized_keys"
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
    --host|-H)
        hosts="$2"
        shift 2
        ;;
    --path|-p)
        path="$2"
        shift 2
        ;;
    --user|-u)
        user="$2"
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
