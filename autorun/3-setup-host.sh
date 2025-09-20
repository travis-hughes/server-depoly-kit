#!/bin/bash

# Create user
echo "\n Creating new users \n"

add_user()
{
    L_USERNAME=$1
    L_GROUP=$2

    echo "Adding Username: $L_USERNAME"

    sudo adduser --gecos "" --ingroup "$L_GROUP" "$L_USERNAME"
    mkdir -p /home/"$L_USERNAME"/.ssh
    # echo "$SSH_KEY" > /home/"$F_USERNAME"/.ssh/authorized_keys

    sudo chown -R "$L_USERNAME":$L_GROUP /home/"$L_USERNAME"/.ssh
    sudo chmod 700 /home/"$L_USERNAME"/.ssh
    sudo chmod 600 /home/"$L_USERNAME"/.ssh/authorized_keys
}

add_user "$USERNAME-admin" sudo

add_user "$USERNAME" users
echo "$SSH_KEY" | sudo tee /home/"$USERNAME"/.ssh/authorized_keys > /dev/null


# if [ $USER = root ]; then
#     echo "Disabling root user access"
#     RANDOM_PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)
#     usermod --password $(echo RANDOM_PASS | openssl passwd -1 -stdin) root
#     echo "" > "~/.ssh/authorized_keys"
# else
#     echo "Please set a strong password for the current account."
#     passwd
#     echo "" > "~/.ssh/authorized_keys"
# fi


echo "\n Disabling SSH password authentication... \n"
rm -f /etc/ssh/sshd_config.d/*
mkdir -p /etc/ssh/sshd_config.d
echo "PasswordAuthentication no" > /etc/ssh/sshd_config.d/disable-password-auth.conf

# TODO: Switch account to "$USERNAME-admin" here


echo "Setting system hostname and timezone..."
hostnamectl set-hostname "$HOSTNAME"
timedatectl set-timezone Europe/London

# Install and configure Tailscale
echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | bash
tailscale up --accept-risk=all


echo "Cron Jobs"
# Add cron job to reboot at 6:00 AM
(crontab -l 2>/dev/null; echo "0 6 * * * /sbin/reboot") | crontab -


# Update packages and install required software
echo "Updating system and installing necessary packages..."
apt update && apt upgrade -y
apt install -y fail2ban ufw

# Setup UFW
echo "Enabling UFW firewall..."
ufw allow OpenSSH
ufw --force enable

# Enable and start services
echo "Enabling services..."
systemctl enable fail2ban --now