#!/bin/bash

# For Ubuntu 24.04 LTS

set -euo pipefail # Exit script if command fails

# Ensure we're running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo." 
  exit 1
fi

# if [ ! $(id -u) = 0 ]; then
#   echo "This script must be run as root. Use sudo." 
#   exit 1
# fi

# If depoly.env exists, load it.
if [ -e "deploy.env" ]; then
  echo "Environment Variables have been detected, loading them..."
  . ./deploy.env
fi

# Create Tempory Folder
mkdir ./depoly_tmp

# Utils
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


echo "======================================================================================================"
echo "Setting up your software. No more input is required. Sit back and watch..."
echo "======================================================================================================"


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
  wget -P ./depoly_tmp https://k8s-deploy.ap-host.net/control-plane.sh
  . ./control-plane.sh
#   microk8s disable dns --force

#   # microk8s enable community
#   microk8s enable dashboard
#   microk8s enable cert-manager
#   microk8s enable dns:100.100.100.100
#   microk8s enable registry
#   microk8s enable rbac
#   microk8s enable cis-hardening
#   microk8s enable metallb:"$(tailscale ip -4)"

#   microk8s kubectl get all --all-namespaces

#   TAILSCALE_IP=$(tailscale ip -4 | head -n1)

#   # Expose dashboard with Loadbalencer and not dashboard-proxy (meant for local development)
#   cat <<EOF | microk8s kubectl apply -f -
# apiVersion: v1
# kind: Service
# metadata:
#   name: kubernetes-dashboard-lb
#   namespace: kube-system
# spec:
#   type: LoadBalancer
#   externalIPs:
#   - $TAILSCALE_IP
#   ports:
#   - port: 9901
#     targetPort: 443
#     protocol: TCP
#     name: https
#   selector:
#     k8s-app: kubernetes-dashboard
# EOF

#   echo "Waiting for dashboard to be available at https://$TAILSCALE_IP:9901 ..."
#   for i in {1..10}; do
#     sleep 3
#     if nc -zv "$TAILSCALE_IP" 9901 &>/dev/null; then
#       echo "✅ Dashboard is now accessible at: https://$TAILSCALE_IP:9901"
#       break
#     else
#       echo "Still waiting..."
#     fi
#   done

#   echo "Fetching dashboard admin token..."
#   SECRET_NAME=$(microk8s kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
#   microk8s kubectl -n kube-system describe secret "$SECRET_NAME" | grep 'token:'

#   # Setup Hetzner S3
#   # Write Hetzner secret
#   cat <<EOF > ./deploy_tmp/hetzner_secrets.yml
# apiVersion: v1
# kind: Secret
# metadata:
#   name: hcloud
#   namespace: kube-system
# stringData:
#   token: $HETZNER_S3_TOKEN
# EOF

#   microk8s kubectl apply -f ./deploy_tmp/hetzner_secrets.yml
#   rm ./deploy_tmp/hetzner_secrets.yml

#   # Add S3 CSI Driver
#   microk8s helm repo add hcloud https://charts.hetzner.cloud
#   microk8s helm repo update hcloud
#   microk8s helm install hcloud-csi hcloud/hcloud-csi -n kube-system

#   # Write StorageClass and PVC
#   cat <<EOF > ./deploy_tmp/hetzner_pvc.yml
# kind: StorageClass
# apiVersion: storage.k8s.io/v1
# metadata:
#   name: hcloud-volumes
#   annotations:
#     storageclass.kubernetes.io/is-default-class: "true"
# provisioner: csi.hetzner.cloud
# volumeBindingMode: WaitForFirstConsumer
# allowVolumeExpansion: true
# reclaimPolicy: Retain
# ---
# apiVersion: v1
# kind: PersistentVolumeClaim
# metadata:
#   name: hetzner-pvc
# spec:
#   accessModes:
#   - ReadWriteOnce
#   resources:
#     requests:
#       storage: 500Gi
#   storageClassName: hcloud-volumes
# EOF

#   # Apply ingress controller
#   echo "Adding Contour (Ingress Controller)"
#   microk8s kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

#   # Deploy Portainer
#   echo "Adding Portainer"
#   microk8s helm repo add portainer https://portainer.github.io/k8s/
#   microk8s helm repo update

#   microk8s helm upgrade --install --create-namespace -n portainer portainer portainer/portainer \
#     --set service.type=LoadBalancer \
#     --set tls.force=true \
#     --set image.tag=lts \
#     --set service.httpNodePort=8001 \
#     --set persistence.storageClass=hcloud-volumes
else
  echo "Your worker is setup"
fi

# Cleanup and reboot
rm ./depoly_tmp
rm deploy.env
reboot