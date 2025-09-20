#!/bin/bash

TEMP_DATA_PATH=/srv/deploy_tmp
FILE_URL=https://k8s-deploy.ap-host.net


# Ensure we're running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo." 
  exit 1
fi


# Create Tempory Folder
mkdir -p "$TEMP_DATA_PATH"

wget -q -P "$TEMP_DATA_PATH" "$FILE_URL/tmux-session.sh"

echo "Starting Tmux Server"
tmux start-server

# Run tmux if not already running
if [ -z "$TMUX" ]; then
  echo "\n Launching inside tmux session: deploy_session \n"

  if tmux has-session -t deploy_session 2>/dev/null; then
    tmux attach -t deploy_session
  else
    tmux new-session -s deploy_session "sudo sh $TEMP_DATA_PATH/tmux-session.sh"
  fi
  echo "Tmux Session could not be found or created"
  exit 1
fi