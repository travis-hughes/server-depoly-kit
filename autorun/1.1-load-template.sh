echo "\n========================================================================================\n"
echo "Select a server template: \n"
echo "1) Kubernetes (Experimental)"
echo "2) Docker Swarm"
echo "\n========================================================================================\n"

TEMPLATE=""

while true; do
    read -p "Option (1/3): " option
    case $option in
        1 ) TEMPLATE="k8s"; break ;;
        2 ) TEMPLATE="swarm"; break ;;
        * ) echo "Invalid input, try again." && exit 1 ;;
    esac
done

echo "Downloading Template Scripts"
mkdir -p ./deploy_tmp/template/

wget -q -P ./deploy_tmp/template/ https://k8s-deploy.ap-host.net/templates/"$TEMPLATE"/input.sh
wget -q -P ./deploy_tmp/template/ https://k8s-deploy.ap-host.net/templates/"$TEMPLATE"/run.sh
wget -q -P ./deploy_tmp/template/ https://k8s-deploy.ap-host.net/templates/"$TEMPLATE"/files.txt


if [ -e "./deploy_tmp/template/files.txt" ]; then
    wget -q -P ./deploy_tmp/template -i ./deploy_tmp/template/files.txt -B https://k8s-deploy.ap-host.net/templates/"$TEMPLATE"
fi

# Run template input script to collect specific inputs
if [ -e "deploy_tmp/template/input.sh" ]; then
    echo "Running template input script"
    . ./deploy_tmp/template/input.sh
fi