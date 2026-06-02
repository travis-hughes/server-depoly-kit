#!/bin/bash

# Create user
add_user()
{
    USERNAME=$1
    GROUP=$2

    echo "Adding Username: $USERNAME"

    sudo adduser --gecos "" --ingroup "$GROUP" "$USERNAME"
    mkdir -p /home/"$USERNAME"/.ssh

    sudo chown -R "$USERNAME":$GROUP /home/"$USERNAME"/.ssh
    sudo chmod 700 /home/"$USERNAME"/.ssh
    sudo chmod 600 /home/"$USERNAME"/.ssh/authorized_keys
}

echo "\n Create Default Admin User \n"
add_user "$USERNAME-admin" sudo

echo "\n Create Default User \n"
add_user "$USERNAME" users
echo "$SSH_KEY" | sudo tee /home/"$USERNAME"/.ssh/authorized_keys > /dev/null






# Disable root user access.
echo "Disabling root user access"
sudo passwd -l root
sudo rm .ssh/authorized_keys


echo "\n Disabling SSH password authentication... \n"
rm -f /etc/ssh/sshd_config.d/*
mkdir -p /etc/ssh/sshd_config.d
echo "PasswordAuthentication no" > /etc/ssh/sshd_config.d/disable-password-auth.conf


echo "Setting system hostname and timezone..."
hostnamectl set-hostname "$HOSTNAME"
timedatectl set-timezone Europe/London


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


echo "Cron Jobs"
# Add cron job to reboot at 6:00 AM
(crontab -l 2>/dev/null; echo "0 6 * * * /sbin/reboot") | crontab -