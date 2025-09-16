#!/bin/bash

# For Ubuntu 24.04 LTS
# Published URL: https://k8s-deploy.ap-host.net/deploy.sh

# Ensure we're running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo." 
  exit 1
fi


# Create Tempory Folder
mkdir ./deploy_tmp


# If deploy.env exists, load it.
if [ -e "deploy.env" ]; then
  echo "Environment Variables have been detected, loading them..."
  . ./deploy.env
fi

# Download dependancy files
wget -P ./deploy_tmp https://k8s-deploy.ap-host.net/control-plane.sh


# Load all include scripts
# for FILE in ./deploy_tmp/*.inc.sh; do
#   # Skip if not a file
#   [ -f "$FILE" ] || continue

#   . $FILE
# done


input_field()
{
  FIELD_NAME=$1

  read -p "$FIELD_NAME: " OUTPUT
  if [ -z "$OUTPUT" ]; then
    echo "$FIELD_NAME is empty"
    exit 1
  fi

  echo "$OUTPUT"
}

ensure_var_defined()
{
  Label=$1
  INPUT=$2

  if [ -z "$INPUT" ]; then
    INPUT=$( input_field $Label )
  else
    echo "$Label already defined, skipping step..."
  fi

  echo "$INPUT"
}


echo "======================================================================================================"
echo "Configure your host system"
echo "======================================================================================================"


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



echo "Please set a strong new password for your root user."
passwd

# Create user
echo "\n Creating new user and setting up SSH... \n"
sudo adduser --ingroup root "$USERNAME"
sudo usermod -a -G sudo "$USERNAME"
mkdir -p /home/$USERNAME/.ssh
echo "$SSH_KEY" > /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:sudo /home/$USERNAME/.ssh
chmod 600 /home/$USERNAME/.ssh/authorized_keys


echo "\n Disabling SSH password authentication... \n"
rm -f /etc/ssh/sshd_config.d/*
mkdir -p /etc/ssh/sshd_config.d
echo "PasswordAuthentication no" > /etc/ssh/sshd_config.d/disable-password-auth.conf

echo "Setting system hostname and timezone..."
hostnamectl set-hostname "$HOSTNAME"
timedatectl set-timezone Europe/London

# Add cron job to reboot at 6:00 AM
echo "Adding auto reboot cronjob"
(crontab -l 2>/dev/null; echo "0 6 * * * /sbin/reboot") | crontab -

# Install and configure Tailscale
echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | bash

if [ "$IS_MANAGER_NODE" -eq 1 ]; then
  tailscale up --accept-risk=all --advertise-tags=tag:k8s-control-plane
else
  tailscale up --accept-risk=all --advertise-tags=tag:k8s-worker
fi

# Update packages and install required software
echo "Updating system and installing necessary packages..."
apt update && apt upgrade -y
sudo apt-get install -y fail2ban ufw curl

# Setup UFW
echo "Enabling UFW firewall..."
ufw allow OpenSSH
ufw --force enable

# Enable and start services
echo "Enabling services..."
systemctl enable fail2ban --now



# Install microk8s
sudo snap install microk8s --classic
microk8s status --wait-ready

# Shorten microk8s kube commands (example: microk8s kubectl becomes kubectl)
echo "alias kubectl='microk8s kubectl'" > ~/.bashrc
echo "alias helm='microk8s helm'" > ~/.bashrc

# Setup server specfic options
if [ "$IS_MANAGER_NODE" -eq 1 ]; then
  # wget -P ./deploy_tmp https://k8s-deploy.ap-host.net/control-plane.sh
  . ./deploy_tmp/control-plane.sh
else
  echo "Your worker is setup"
fi

# Cleanup and reboot
rm ./deploy_tmp
rm deploy.env
reboot