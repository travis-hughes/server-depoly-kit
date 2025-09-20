#!/bin/bash

input_field()
{
  FIELD_NAME=$1

  read -p "$FIELD_NAME: " OUTPUT
  if [ -z "$OUTPUT" ]; then
    echo "$FIELD_NAME is empty"
    exit 1
  fi

  # Retain value incase another call to input_field() forces an exit.
  echo "$OUTPUT"
}

ensure_var_defined()
{
  Label=$1
  INPUT=$2

  if [ -z "$INPUT" ]; then
    INPUT=$( input_field $Label)
  else
    echo "$Label already defined, skipping step..."
  fi

  echo "$INPUT"
}

input_yn()
{
  L_QUESTION=$1

  while true; do
    read -p "$L_QUESTION " yn
    case $yn in
        [Yy]* ) OUTPUT=1; break;;
        [Nn]* ) OUTPUT=2; break ;;
        * ) echo "Please answer yes or no.";;
    esac
  done

  echo "$OUTPUT"
}

select_field() {
  L_prompt="$1"
  shift

  # Create temporary files to store keys and labels
  L_KEYS_FILE=$(mktemp)
  L_LABELS_FILE=$(mktemp)
  L_option_index=1

  echo
  echo "$L_prompt"
  echo

  # Parse "key:label" pairs and display them as a numbered list
  for L_pair in "$@"; do
    L_key=$(echo "$L_pair" | cut -d':' -f1)
    L_label=$(echo "$L_pair" | cut -d':' -f2-)

    echo "$L_key" >> "$L_KEYS_FILE"
    echo "$L_label" >> "$L_LABELS_FILE"

    echo "$L_option_index) $L_label"
    L_option_index=$((L_option_index + 1))
  done

  echo
  L_total_options=$#

  # Loop until a valid numeric input is given
  while true; do
    printf "Option (1-%s): " "$L_total_options"
    read L_user_input

    case "$L_user_input" in
      ''|*[!0-9]*) echo "❌ Invalid input. Please enter a number." ;;
      *)
        if [ "$L_user_input" -ge 1 ] 2>/dev/null && [ "$L_user_input" -le "$L_total_options" ]; then
          L_SELECTED_KEY=$(sed -n "${L_user_input}p" "$L_KEYS_FILE")
          L_SELECTED_LABEL=$(sed -n "${L_user_input}p" "$L_LABELS_FILE")
          break
        else
          echo "❌ Input out of range. Please select between 1 and $L_total_options."
        fi
      ;;
    esac
  done

  # Export selected values for use outside the function
  # export L_SELECTED_KEY
  # export L_SELECTED_LABEL

  # Clean up temporary files
  rm -f "$L_KEYS_FILE" "$L_LABELS_FILE"

  echo "$L_SELECTED_KEY"
}