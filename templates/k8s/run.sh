# Install microk8s
sudo snap install microk8s --classic
echo "Waiting for MicroK8s to start"
microk8s status --wait-ready

# Shorten microk8s kube commands (example: microk8s kubectl becomes kubectl)
echo "alias kubectl='microk8s kubectl'" > ~/.bashrc
echo "alias helm='microk8s helm'" > ~/.bashrc


# Control Plane
if [ "$KUBE_SYSTEM_TYPE" -eq 1 ]; then
  . ./deploy_tmp/template/control-plane.sh
fi

# Worker
if [ "$KUBE_SYSTEM_TYPE" -eq 2 ]; then
  echo "Your worker is setup"
fi

# Standalone (Dev)
if [ "$KUBE_SYSTEM_TYPE" -eq 3 ]; then
  . ./deploy_tmp/template/standalone-dev.sh
fi