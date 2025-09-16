# Install microk8s
sudo snap install microk8s --classic
microk8s status --wait-ready

# Shorten microk8s kube commands (example: microk8s kubectl becomes kubectl)
echo "alias kubectl='microk8s kubectl'" > ~/.bashrc
echo "alias helm='microk8s helm'" > ~/.bashrc

# Setup server specfic options
if [ "$IS_MANAGER_NODE" -eq 1 ]; then
  . ./deploy_tmp/control-plane.sh
else
  echo "Your worker is setup"
fi


# Control Plane
if [ "$SERVER_TEMPLATE" == 1 ]; then
  . ./deploy_tmp/control-plane.sh
fi

# Worker
if [ "$SERVER_TEMPLATE" == 2 ]; then
  echo "Your worker is setup"
fi

# Standalone (dev)
if [ "$SERVER_TEMPLATE" == 3 ]; then
  . ./deploy_tmp/standalone-dev.sh
fi