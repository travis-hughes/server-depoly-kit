#!/bin/bash

# The "real" entrypoint

ROOT_USER_DIR=/root
TEMP_DATA_PATH=/srv/deploy_tmp
FILE_URL=https://server-depoly-kit.github.io

# If deploy.env exists, load it.
# if [ -e "deploy.env" ]; then
#   echo "Environment Variables have been detected, loading them..."
#   . ./deploy.env
# fi


# Download dependancies
wget -q -P "$TEMP_DATA_PATH" "$FILE_URL/files.txt"
wget -q -P "$TEMP_DATA_PATH" -i "$TEMP_DATA_PATH/files.txt" -B "$FILE_URL"
# wget -q -x -nH --cut-dirs=0 -i "$TEMP_DATA_PATH/files.txt" -B "$FILE_URL" -P "$TEMP_DATA_PATH"


while IFS= read -r line || [ -n "$line" ]; do
  if [ ! -f "$FILE" ]; then
    # wget -q -P "$TEMP_DATA_PATH" "$FILE_URL/$line"
    wget -q -O "$TEMP_DATA_PATH" "$FILE_URL/$line"
  fi
done < $TEMP_DATA_PATH/files.txt


# Include util script
. "$TEMP_DATA_PATH/utils.sh"


# Load scripts from autorun.
for FILE in "$TEMP_DATA_PATH"/*-*.sh; do
  echo "\n ▶️ Exacuting autorun script: $FILE \n"
  . "$FILE"
done


# Cleanup and reboot
rm "$ROOT_USER_DIR/run.sh"
rm -r "$TEMP_DATA_PATH"
rm deploy.env
reboot