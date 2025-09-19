TEMPLATE=""
TEMPLATE_DIR="./deploy_tmp/template"
FILE_URL=https://k8s-deploy.ap-host.net

echo "\n========================================================================================\n"
echo "Select a server template: \n"
echo "1) Kubernetes (Experimental)"
echo "2) Docker"
echo "\n========================================================================================\n"

while true; do
    read -p "Option (1/2): " option
    case $option in
        1 ) TEMPLATE="k8s"; break ;;
        2 ) TEMPLATE="docker"; break ;;
        * ) echo "Invalid input, try again." && exit 1 ;;
    esac
done
# echo "TEMPLATE=$TEMPLATE" > deploy.env

echo "Downloading Template Scripts"
mkdir -p $TEMPLATE_DIR

wget -q -P ./deploy_tmp/template "$FILE_URL/templates/$TEMPLATE/input.sh"
wget -q -P ./deploy_tmp/template "$FILE_URL/templates/$TEMPLATE/run.sh"
wget -q -P ./deploy_tmp/template "$FILE_URL/templates/$TEMPLATE/files.txt"


if [ -e "./deploy_tmp/template/files.txt" ]; then
    wget -P ./deploy_tmp/template -i ./deploy_tmp/template/files.txt -B "$FILE_URL/templates/$TEMPLATE/"
fi

# Run template input script to collect specific inputs
if [ -e "$TEMPLATE_DIR/input.sh" ]; then
    echo "Running template input script"
    . $TEMPLATE_DIR/input.sh
fi