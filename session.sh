#!/bin/bash

# Load scripts from autorun folder
for FILE in "$TEMP_DATA_PATH"/*-*.sh; do
  echo "\n ▶️ Exacuting autorun script: $FILE \n"
  . "$FILE"
done

# Cleanup and reboot
rm "$TEMP_DATA_PATH"
rm deploy.env
reboot