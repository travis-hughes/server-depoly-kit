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