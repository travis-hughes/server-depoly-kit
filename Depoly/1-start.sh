# Read inputs
echo "Please specify a system hostname (example: server-swarm-manager)"
HOSTNAME=$( ensure_var_defined "Hostname" $HOSTNAME )

echo "Enter some details for your user, the password will be specifed later on."
USERNAME=$( ensure_var_defined "Username" $USERNAME )
SSH_KEY=$( ensure_var_defined "SSH Key" $SSH_KEY )
HETZNER_S3_TOKEN=$( ensure_var_defined "Hetzner S3 Token" $HETZNER_S3_TOKEN )


# echo "Please specify an email (used for system reporting)"
# REPORTING_EMAIL=$( input_field "Reporting Email" )

echo ""
echo "What type of server do you want to install?"
echo "1) Control-Plane Node"
echo "2) Worker Node"
echo ""
IS_MANAGER_NODE=0
while true; do
    read -p "Option (1/2): " option
    case $option in
        1 ) IS_MANAGER_NODE=1; break ;;
        2 ) IS_MANAGER_NODE=0; break ;;
        * ) echo "Invalid input, try again." && exit 1 ;;
    esac
done