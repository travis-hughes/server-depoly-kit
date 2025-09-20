TEMPLATE=""
TEMPLATE_DIR="$TEMP_DATA_PATH/template"

echo "\n========================================================================================\n"
echo "Select a server template: \n"
echo "1) Kubernetes (Experimental)"
echo "2) Docker"
echo "\n========================================================================================\n"

read -p "Option (1/2): " option
case "$option" in
    1 ) TEMPLATE="k8s" ;;
    2 ) TEMPLATE="docker" ;;
    * ) echo "Invalid input, try again." && exit 1 ;;
esac

# echo "TEMPLATE=$TEMPLATE" > deploy.env

echo "Downloading Template Scripts"
mkdir -p "$TEMPLATE_DIR"

wget -q -P "$TEMPLATE_DIR" "$FILE_URL/templates/$TEMPLATE/input.sh"
wget -q -P "$TEMPLATE_DIR" "$FILE_URL/templates/$TEMPLATE/run.sh"
wget -q -P "$TEMPLATE_DIR" "$FILE_URL/templates/$TEMPLATE/files.txt"

if [ -e "$TEMPLATE_DIR/files.txt" ]; then
    wget -q -P "$TEMPLATE_DIR" -i "$TEMPLATE_DIR/files.txt" -B "$FILE_URL/templates/$TEMPLATE/"
fi

# Run template input script to collect specific inputs
if [ -e "$TEMPLATE_DIR/input.sh" ]; then
    echo "Running template input script"
    . "$TEMPLATE_DIR/input.sh"
fi