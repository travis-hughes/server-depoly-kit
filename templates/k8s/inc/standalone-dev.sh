HOST_PUBLIC_IP=$(tailscale ip)

sudo microk8s addons repo update core
microk8s disable ha-cluster --force

microk8s enable hostpath-storage
microk8s enable rbac
microk8s enable ingress
# microk8s enable cert-manager
# microk8s enable dns:"$DNS_SERVER"
# microk8s enable metallb:"${HOST_PUBLIC_IP}-${HOST_PUBLIC_IP}"
# TODO: Add these options -c 100Gi -s ceph-xfs
microk8s enable miniio
microk8s enable metallb:10.64.140.43-10.64.140.49,192.168.0.105-192.168.0.111
microk8s enable dashboard

# Ingress Controller
# kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

# cat <<EOF | microk8s kubectl apply -f -
# kind: StorageClass
# apiVersion: storage.k8s.io/v1
# metadata:
#   name: local-system-storage
# provisioner: microk8s.io/hostpath
# reclaimPolicy: Delete
# parameters:
#   pvDir: /srv/k8s-storage
# volumeBindingMode: WaitForFirstConsumer
# EOF


# Deploy Portainer
echo "Adding Portainer"
cat <<EOF > ./portainer_sc.yml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: portainer-sc
parameters:
  pvDir: /srv/k8s-storage/portainer
provisioner: microk8s.io/hostpath
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Delete
EOF
microk8s kubectl apply -f ./portainer_sc.yml

microk8s helm repo add portainer https://portainer.github.io/k8s/
microk8s helm repo update

microk8s helm upgrade --install --create-namespace -n portainer portainer portainer/portainer \
  --set service.type=LoadBalancer \
  --set tls.force=false \
  --set image.tag=lts \
  --set persistence.storageClass=portainer-sc


# Get Dashboard Token
token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
microk8s kubectl -n kube-system describe secret $token

# Open
microk8s kubectl port-forward -n portainer service/portainer 9443:9443
microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443
microk8s kubectl port-forward -n minio-operator service/microk8s-console 11443:443
microk8s kubectl port-forward -n minio-operator service/console 12443:443

microk8s kubectl get all --all-namespaceso