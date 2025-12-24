#!/bin/bash

# Ensure we're running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo." 
  exit 1
fi

echo "Launching..."

# TODO: Check if code exists, download code package and extract it.
echo "Checking files"
if [ ! -d "$TEMP_DATA_PATH" ]; then
  mkdir "$TEMP_DATA_PATH"
  wget -P "$TEMP_DATA_PATH" -i "$TEMP_DATA_PATH/package.tar.gz" -B "$FILE_URL"
  tar -xvzf "$TEMP_DATA_PATH/package.tar.gz"
  rm "$TEMP_DATA_PATH/package.tar.gz"
fi


# Create Install User

if id "$INSTALL_USER" >/dev/null 2>&1; then
  echo "$INSTALL_USER found, skipping."
else
  echo ""
  echo "Create a password for the $INSTALL_USER user"
  echo "\n You can consider this your systems main user (outside of root of course). We will preform installs using this user."
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