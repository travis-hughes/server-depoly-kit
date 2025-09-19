# Create user
echo "\n Creating new users and setting up SSH... \n"

# echo "Setting ramdom Root password - disable access"
# if [ $USER = root ]; then
#     RANDOM_PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)
#     usermod --password $(echo RANDOM_PASS | openssl passwd -1 -stdin) root
#     echo "" > "~/.ssh/authorized_keys"
# else
#     echo "Set a strong password for the account your using"
#     passwd
#     echo "" > "~/.ssh/authorized_keys"
# fi

# sudo adduser --gecos --ingroup sudo $USERNAME

add_user()
{
    F_USERNAME=$1
    F_GROUP=$2

    sudo adduser --gecos "" --ingroup "$F_GROUP" "$F_USERNAME"
    mkdir -p /home/"$F_USERNAME"/.ssh
    # echo "$SSH_KEY" > /home/"$F_USERNAME"/.ssh/authorized_keys
    echo "$SSH_KEY" | sudo tee /home/"$F_USERNAME"/.ssh/authorized_keys > /dev/null

    sudo chown -R "$F_USERNAME":$F_GROUP /home/"$F_USERNAME"/.ssh
    sudo chmod 700 /home/"$F_USERNAME"/.ssh
    sudo chmod 600 /home/"$F_USERNAME"/.ssh/authorized_keys
}

add_user "$USERNAME-admin" sudo
add_user "$USERNAME" users

# sudo adduser --gecos --ingroup sudo "$USERNAME"
# mkdir -p /home/"$USERNAME"/.ssh
# echo "$SSH_KEY" > /home/"$USERNAME"/.ssh/authorized_keys
# sudo chown -R "$USERNAME":sudo /home/"$USERNAME"/.ssh
# sudo chmod 700 /home/"$USERNAME"/.ssh
# sudo chmod 600 /home/"$USERNAME"/.ssh/authorized_keys

# sudo adduser --gecos "$USERNAME"
# mkdir -p "/home/$USERNAME/.ssh"
# echo "$SSH_KEY" > "/home/$USERNAME/.ssh/authorized_keys"

# chown -R "$USERNAME:sudo" "/home/$USERNAME/.ssh"
# chmod 600 /home/$USERNAME/.ssh/authorized_keys


# sudo adduser --gecos "$USERNAME-admin"
# sudo usermod -a -G sudo "$USERNAME-admin"
# echo "$SSH_KEY" > "/home/$USERNAME-admin/.ssh/authorized_keys"

# chown -R "$USERNAME-admin:sudo" "/home/$USERNAME-admin/.ssh"
# chmod 600 "/home/$USERNAME-admin/.ssh/authorized_keys"


echo "\n Disabling SSH password authentication... \n"

rm -f /etc/ssh/sshd_config.d/*
mkdir -p /etc/ssh/sshd_config.d
echo "PasswordAuthentication no" > /etc/ssh/sshd_config.d/disable-password-auth.conf



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