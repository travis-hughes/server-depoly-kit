microk8s enable cert-manager
microk8s enable registry
microk8s enable rbac
microk8s enable metallb:10.64.140.43-10.64.140.49,192.168.0.105-192.168.0.111

microk8s enable dashboard
microk8s enable dashboard-proxy

microk8s kubectl get all --all-namespaces