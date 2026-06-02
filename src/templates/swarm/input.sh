echo ""
echo "What type of server do you want to install?"
echo "1) Manager node"
echo "2) Worker node"
echo ""
IS_MANAGER_NODE=false
while true; do
    read -p "Option (1/2): " option
    case $option in
        1 ) IS_MANAGER_NODE=true; break ;;
        2 ) IS_MANAGER_NODE=false; break ;;
        * ) echo "Invalid input, try again." && exit 1 ;;
    esac
done