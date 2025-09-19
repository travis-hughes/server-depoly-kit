# Read inputs
echo "Please specify a system hostname (example: server-swarm-manager)"
HOSTNAME=$( ensure_var_defined "Hostname" $HOSTNAME )

echo "Enter some details for your user, the password will be specifed later on."
USERNAME=$( ensure_var_defined "Username" $USERNAME )
SSH_KEY=$( ensure_var_defined "SSH Key" $SSH_KEY -s )


# echo "Please specify an email (used for system reporting)"
# EMAIL=$( input_field "System Reporting Email" )