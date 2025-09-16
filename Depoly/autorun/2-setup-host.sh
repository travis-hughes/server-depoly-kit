# Install and configure Tailscale
echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | bash

# Control Plane
if [ "$SERVER_TEMPLATE" == 1 ]; then
  tailscale up --accept-risk=all --advertise-tags=tag:k8s-control-plane
fi

# Worker
if [ "$SERVER_TEMPLATE" == 2 ]; then
  tailscale up --accept-risk=all --advertise-tags=tag:k8s-worker
fi

# Standalone (dev)
if [ "$SERVER_TEMPLATE" == 3 ]; then
  tailscale up --accept-risk=all --advertise-tags=tag:k8s-control-plane
fi


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