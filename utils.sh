#!/bin/bash


# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White


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
      [Yy]* ) L_OUTPUT=1; break;;
      [Nn]* ) L_OUTPUT=2; break ;;
      * ) echo "Please answer yes or no.";;
    esac
  done

  echo "$L_OUTPUT"
}

select_field()
{
  L_OUTPUT=$(python3 "$TEMP_DATA_PATH"/select-field.py "$@") 
  echo "$L_OUTPUT"
}