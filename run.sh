#!/bin/bash

# For Ubuntu 24.04 LTS
# Published URL: https://k8s-deploy.ap-host.net/run.sh

# EXACUTION_DIR=$(dirname $0)
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
wget -q -P "$TEMP_DATA_PATH" "$FILE_URL/files.txt"
wget -q -P "$TEMP_DATA_PATH" -i "$TEMP_DATA_PATH/files.txt" -B "$FILE_URL"


# Run tmux if not already running
# if [ -z "$TMUX" ]; then
#   echo "🔁 Relaunching inside tmux session: deploy_session"
#   if tmux has-session -t deploy_session 2>/dev/null; then
#     tmux attach -t deploy_session
#   else
#     tmux new-session -s deploy_session "bash $TEMP_DATA_PATH/session.sh"
#   fi
#   exit
# fi

# Load scripts from autorun folder
for FILE in "$TEMP_DATA_PATH"/*-*.sh; do
  echo "\n ▶️ Exacuting autorun script: $FILE \n"
  . "$FILE"
done

# Cleanup and reboot
rm -r "$TEMP_DATA_PATH"
rm deploy.env
reboot