#!/usr/bin/env bash

# VARIABLES
target_path="/etc/rancher/k3s/k3s.yaml"
output_dir="${HOME}/.kube"
env_name="bash"
ip=""
no_ip="false"
ip_int="enp1s0"

# FUNCTIONS
function help(){
    printf "[Overview]
! CONFIGURE THE MACHINE NAMES IN YOUR SSH CONFIG FIRST !
Use this script to extract the kubernetes configurations from host with ssh access.
You need to be sudoer on these hosts to run this script.
The configurations will be placed under ~/.kube/<machine-name>.
The 'KUBECONFIG' var will be replaced in your environment.

[Usage]
get-kubeconfig.sh --host mysshhost1,mysshhost2

[Arguments]
--host,-H         List of SSH hosts separated with ','.

[Options]
--path,-p [path]        Path of the kubeconfig on the target hosts. 
                        Default '/etc/rancher/k3s/k3s.yaml'.
--env,-e  [name]        Name of your shell environment to update with the variable 'KUBECONFIG'. Either '                        bash' or 'fish'. Env will be injected in ~/.bashrc if bash or in 
                        ~/.config/fish/config.fish if fish. 
                        Default 'bash'.
--output-dir,-o [dir]   Path of the directory where the kubeconfig files will be extracted.
                        Default '~/.kube'.
--int [name]            Name of the interface to extract the IP to inject in the kube config.
                        Default 'enp1s0'.
--ip [ip]               Disable automatic guess of remote IP to overwrite with user input.
"
}

function check_env(){
  if [ "${env_name}" == "bash" ];then
    set_env_string="export KUBECONFIG="
    env_file="${HOME}/.bashrc"
  elif [ "${env_name}" == "fish" ];then
    set_env_string="set -x KUBECONFIG "
    env_file="${HOME}/.config/fish/config.fish"
  else
    echo "FATAL: Environment error: Unknown environment name '${env_name}'."
    exit 1
  fi
}

function get_kubeconfigs(){
  # init
  if [ ! -d "${output_dir}" ];then
    echo ". Create ${output_dir}"
    mkdir "${output_dir}"
  fi
  # extract
  local kubeconfig_locations="\""
  IFS=',' read -ra hosts_list <<< "$hosts"
  for host in "${hosts_list[@]}"; do
    local output_file="${output_dir}/${host}"
    echo ". ${host}: Extract '${target_path}' to local file '${output_file}'"
    # extract kubeconfig file
    printf "Password: "
    ssh -t "${host}" "sudo cat ${target_path}" > "${output_file}"
    # inject context as host name
    sed -i "s/default/${host}/g" "${output_file}"
    # inject host ip as kubeconfig address
    if [ -z "${ip}" ];then
      get_ip_cmd="ip r | grep ${ip_int} | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'"
      host_ips="$(ssh "${host}" "${get_ip_cmd}")"
      # get the last ip of the list of ips for this interface
      IFS=$'\n' read -rd '' -a list_ips <<< "${host_ips}"
      sed -i "s/127\.0\.0\.1/${list_ips[-1]}/g" "${output_file}"
    else
      sed -i "s/127\.0\.0\.1/${ip}/g" "${output_file}"
    fi
    # update kubeconfig list
    kubeconfig_locations="${kubeconfig_locations}${output_file}:"
  done
  kubeconfig_locations="${kubeconfig_locations}\""
  # update env file
  local env_string="${set_env_string}${kubeconfig_locations}"
  echo ". Update env file '$env_file' with: '$env_string'"
  if grep -Fq "KUBECONFIG" "${env_file}"
  then
      # KUBECONFIG string exists so replace
      sed -i -e "s+.*KUBECONFIG.*+${env_string}+g" "${env_file}"
  else
      # KUBECONFIG string does not exist so add it
      echo "${env_string}" >> "${env_file}"
  fi

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
        target_path="$2"
        shift 2
        ;;
    --output-dir|-o)
        output_dir="$2"
        shift 2
        ;;
    --env|-e)
        env_name="$2"
        shift 2
        ;;
    --no-ip)
        no_ip="true"
        shift
        ;;
    --ip)
        ip="$2"
        shift 2
        ;;
    --int)
        ip_int="$2"
        shift 2
        ;;
    *) # unknown option
        format "$1"
        shift              # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

check_env
get_kubeconfigs

echo ". OK"
echo ". Please source ${env_file}"
exit 0
