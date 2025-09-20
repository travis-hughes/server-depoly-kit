#!/bin/bash

# Download dependancy files
wget -q -P "$TEMP_DATA_PATH" "$FILE_URL/files.txt"
wget -q -P "$TEMP_DATA_PATH" -i "$TEMP_DATA_PATH/files.txt" -B "$FILE_URL"

# Load scripts from autorun folder
for FILE in "$TEMP_DATA_PATH"/*-*.sh; do
  echo "\n ▶️ Exacuting autorun script: $FILE \n"
  . "$FILE"
done

# Cleanup and reboot
rm "$TEMP_DATA_PATH"
rm deploy.env
reboot