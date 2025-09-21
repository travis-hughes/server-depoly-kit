# Install microk8s
sudo snap install microk8s --classic
echo "Waiting for MicroK8s to start"
microk8s status --wait-ready


# Add default user to microk8s group
# We do this so we don't need to run all microk8s commands as sudo
usermod -a -G microk8s "$USERNAME-admin"


# Control Plane
if [ "$KUBE_SYSTEM_TYPE" -eq 1 ]; then
  . "$TEMPLATE_DIR/control-plane.sh"
fi

# Worker
if [ "$KUBE_SYSTEM_TYPE" -eq 2 ]; then
  echo "Your worker is setup"
fi

# Standalone (Dev)
if [ "$KUBE_SYSTEM_TYPE" -eq 3 ]; then
  . "$TEMPLATE_DIR/standalone-dev.sh"
fi