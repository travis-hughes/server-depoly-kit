#!/bin/bash

EXACUTION_DIR=$(dirname $0)
TEMP_DATA_PATH=/srv/deploy_tmp
FILE_URL=https://k8s-deploy.ap-host.net

# If deploy.env exists, load it.
if [ -e "deploy.env" ]; then
  echo "Environment Variables have been detected, loading them..."
  . ./deploy.env
fi

# Create Tempory Folder
mkdir -p "$TEMP_DATA_PATH"


# Download dependancy files
wget -q -P "$TEMP_DATA_PATH" "$FILE_URL/files.txt"
wget -q -P "$TEMP_DATA_PATH" -i "$TEMP_DATA_PATH/files.txt" -B "$FILE_URL"

DEPLOY_USER="server-deploy-kit"
echo "Create a password for the server-deploy-kit user"
echo "\n You can consider this your systems main user (outside of root of course). We will preform installs\n using this user. \n"
sudo adduser --gecos "" --ingroup sudo "$DEPLOY_USER"

# Load scripts from autorun folder as server-deploy-kit user
su - "$DEPLOY_USER" -c "
for FILE in "$TEMP_DATA_PATH"/*-*.sh; do
  echo "\n ▶️ Exacuting autorun script: $FILE \n"
  . "$FILE"
done

logout
"

# Cleanup and reboot
rm "$EXACUTION_DIR/run.sh"
rm "$EXACUTION_DIR/session.sh"
rm -r "$TEMP_DATA_PATH"
rm deploy.env
reboot