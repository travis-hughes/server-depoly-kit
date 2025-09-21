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

# Get tmux session script
wget -q -P "$TEMP_DATA_PATH" "$FILE_URL/session.sh"


# Create install user
INSTALL_USER="server-deploy-kit"
if id "$INSTALL_USER" >/dev/null 2>&1; then
  echo "$INSTALL_USER found, skipping."
else
  echo "Create a password for the $INSTALL_USER user"
  echo "\n You can consider this your systems main user (outside of root of course). We will preform installs\n using this user. \n"
  sudo adduser --gecos "" --ingroup sudo "$INSTALL_USER"
fi

echo "Starting Tmux Server"
tmux start-server

# Run tmux session if not already running
if sudo -u "$INSTALL_USER" tmux has-session -t deploy_session 2>/dev/null; then
  sudo -u "$INSTALL_USER" tmux attach -t deploy_session
else
  sudo -u "$INSTALL_USER" tmux new-session -s deploy_session "sudo sh $TEMP_DATA_PATH/session.sh"
fi