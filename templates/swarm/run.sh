# Install Docker
echo "Installing Docker."
curl -fsSL https://get.docker.com | sh


if $IS_MANAGER_NODE; then
  echo "Configuring Swarm Manager..."
  docker swarm init --advertise-addr $(tailscale ip -4)

  docker network create -d overlay reverse-proxy-network
else
echo "Configuring Swarm Worker..."
  docker volume create swarm-worker-data
fi