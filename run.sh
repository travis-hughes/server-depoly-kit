#!/bin/bash

# For Ubuntu 24.04 LTS
# Published URL: https://k8s-deploy.ap-host.net/run.sh

TEMP_DATA_PATH=/srv/deploy_tmp
FILE_URL=https://k8s-deploy.ap-host.net

# Ensure we're running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo." 
  exit 1
fi


# Create Tempory Folder
mkdir -p "$TEMP_DATA_PATH"


# If deploy.env exists, load it.
if [ -e "deploy.env" ]; then
  echo "Environment Variables have been detected, loading them..."
  . ./deploy.env
fi


# Download dependancy files
wget -P "$TEMP_DATA_PATH" "$FILE_URL/files.txt"
wget -P "$TEMP_DATA_PATH" -i "$TEMP_DATA_PATH/files.txt" -B "$FILE_URL"

# Load scripts from autorun folder
for FILE in "$TEMP_DATA_PATH"/*-*.sh; do
  echo "\n ▶️ Exacuting autorun script: $FILE \n"
  . $FILE
done

# Cleanup and reboot
rm "$TEMP_DATA_PATH"
rm deploy.env
reboot