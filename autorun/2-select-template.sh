#!/bin/bash

TEMPLATE_DIR="$TEMP_DATA_PATH/template"

echo "Downloading Template Scripts"
mkdir -p "$TEMPLATE_DIR"

wget -q -P "$TEMPLATE_DIR" "$FILE_URL/templates/$TEMPLATE/input.sh"
wget -q -P "$TEMPLATE_DIR" "$FILE_URL/templates/$TEMPLATE/run.sh"
wget -q -P "$TEMPLATE_DIR" "$FILE_URL/templates/$TEMPLATE/files.txt"

if [ -e "$TEMPLATE_DIR/files.txt" ]; then
    wget -q -P "$TEMPLATE_DIR" -i "$TEMPLATE_DIR/files.txt" -B "$FILE_URL/templates/$TEMPLATE/"
fi

# Run template input script to collect specific inputs
if [ -e "$TEMPLATE_DIR/input.sh" ]; then
    echo "Running template input script"
    . "$TEMPLATE_DIR/input.sh"
fi