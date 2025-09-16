#!/bin/bash

# For Ubuntu 24.04 LTS
# Published URL: https://k8s-deploy.ap-host.net/run.sh

# Ensure we're running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo." 
  exit 1
fi


# Create Tempory Folder
mkdir ./deploy_tmp


# If deploy.env exists, load it.
if [ -e "deploy.env" ]; then
  echo "Environment Variables have been detected, loading them..."
  . ./deploy.env
fi


# Download dependancy files
wget -P ./deploy_tmp https://k8s-deploy.ap-host.net/files.txt
wget -P ./deploy_tmp -i ./deploy_tmp/files.txt 

# wget -P ./deploy_tmp https://k8s-deploy.ap-host.net/autorun/0-utils.sh
# wget -P ./deploy_tmp https://k8s-deploy.ap-host.net/autorun/1-start.sh
# wget -P ./deploy_tmp https://k8s-deploy.ap-host.net/autorun/2-setup-host.sh
# wget -P ./deploy_tmp https://k8s-deploy.ap-host.net/autorun/3-setup-k8s.sh
# wget -P ./deploy_tmp https://k8s-deploy.ap-host.net/inc/control-plane.sh


# Load autorun Scripts
for FILE in ./deploy_tmp/*-*.sh; do
  . $FILE
done


# Cleanup and reboot
rm ./deploy_tmp
rm deploy.env
reboot