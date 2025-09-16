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
wget -q -P ./deploy_tmp https://k8s-deploy.ap-host.net/files.txt
wget -q -P ./deploy_tmp -i ./deploy_tmp/files.txt -B https://k8s-deploy.ap-host.net

nohup long-running-command &

# Enter tmux session to prevent script ending on SSH disconnect
# Load scripts from autorun folder
for FILE in ./deploy_tmp/*-*.sh; do
  echo "\n ▶️ Exacuting autorun script: $FILE \n"
  . $FILE
done

# Cleanup and reboot
rm ./deploy_tmp
rm deploy.env
reboot