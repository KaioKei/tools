#!/usr/bin/env bash

# VARIABLES

# FUNCTIONS
function help(){
    printf "[Overview]
Move the default admin kubeconfig to user home directory and configure the environment to use it.
No arguments needed.
MUST be executed with root privileges.
"
}

function check(){
  if [ "$(whoami)" != "root" ]; then
    echo "! Please run with sudo"
    exit 1
  fi
}

function main(){
  user=$(who am i | awk '{print $1}')
  home_user=$(eval echo "~${user}")
  echo ". Getting K3S Kubeconfig as user '${user}'"

  destination="${home_user}/.kube/k3s.yaml"
  su -c "mkdir -p ${home_user}/.kube" "${user}"
  cp /etc/rancher/k3s/k3s.yaml "${destination}"
  chown "${user}": "${destination}"
  su -c "echo \"export KUBECONFIG=${destination}\" >> ${home_user}/.bashrc" "${user}"
  rm /etc/rancher/k3s/k3s.yaml

  echo ". Source environment with :"
  echo "source ${home_user}/.bashrc"
}

check
main


echo ". Done"
exit 0
