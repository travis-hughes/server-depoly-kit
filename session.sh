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

# Load scripts from autorun.
for FILE in "$TEMP_DATA_PATH"/*-*.sh; do
  echo "\n ▶️ Exacuting autorun script: $FILE \n"
  . "$FILE"
done

# Cleanup and reboot
rm "$EXACUTION_DIR/run.sh"
rm "$EXACUTION_DIR/session.sh"
rm -r "$TEMP_DATA_PATH"
rm deploy.env
reboot