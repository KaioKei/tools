#!/usr/bin/env bash

# VARIABLES
host=""
remote_path=""
local_path=""
use_sudo="false"

# FUNCTIONS
function help(){
    printf "[Overview]
! CONFIGURE THE MACHINE NAMES IN YOUR SSH CONFIG FIRST !
Use this script to download files from SSH remote machines.
The files will be downloaded to the current location.


[Arguments]
--host,-H               List of SSH hosts separated with ','.

[Options]
--path,-p [path]        Path of the file on the remote machine to download.
--output,-o [dir]       Output path to copy the downloaded files.
--root                  Enable sudoer mode.
"
}

function init() {
    # init
    if [ ! -d "${local_path}" ];then
      echo ". Create ${local_path}"
      mkdir "${local_path}"
    fi
}

function download_file(){
  output_dir="${local_path}/${host}"
  echo ". ${host}: Download '${remote_path}' to dir '${output_dir}/'"
  # extract kubeconfig file
  if [ "${use_sudo}" == "true" ]; then
    ssh -t "${host}" "sudo cp ${remote_path} ~"
    filename="$(basename -- "${remote_path}")"
    remote_path="~/${filename}"
  fi
  scp "${host}" "${output_dir}/"
}

function main(){
  # extract
  IFS=',' read -ra hosts_list <<< "$hosts"
  for host in "${hosts_list[@]}"; do
    download_file
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
    --path|-p)
        remote_path="$2"
        shift 2
        ;;
    --output|-o)
        local_path="$2"
        shift 2
        ;;
    --root)
         use_sudo="true"
         shift
         ;;
    *) # unknown option
        echo "! Unknown parameter : $1"
        exit 1
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

init
main

echo ". OK"
echo ". Please source ${env_file}"
exit 0
