#!/bin/bash

# Read inputs
echo "Please specify a system hostname (example: server-swarm-manager)"
HOSTNAME=$( ensure_var_defined "Hostname" $HOSTNAME )

echo "Enter some details for your user, the password will be specifed later on."
USERNAME=$( ensure_var_defined "Username" $USERNAME )

stty_orig=`stty -g`
stty -echo
SSH_KEY=$( ensure_var_defined "SSH Key" $SSH_KEY )
stty $stty_orig

# echo "Please specify an email (used for system reporting)"
# EMAIL=$( input_field "System Reporting Email" )

echo "\n========================================================================================\n"
echo "Select a server template: \n"
echo "1) Kubernetes (Experimental)"
echo "2) Docker"
echo "3) Swarm"
echo "4) Coolify"
echo "\n========================================================================================\n"

read -p "Option (1/2): " option
case "$option" in
    1 ) TEMPLATE="k8s" ;;
    2 ) TEMPLATE="docker" ;;
    3 ) TEMPLATE="swarm" ;;
    4 ) TEMPLATE="coolify" ;;
    * ) echo "Invalid input, try again." && exit 1 ;;
esac

# $TEMPLATE=$(select_field "Select a server template" "k8s:Kubernetes (Experimental)" "docker:Docker")