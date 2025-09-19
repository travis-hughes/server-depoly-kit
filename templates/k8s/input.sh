echo ""
echo "What type of server do you want to install?"
echo "1) Control Plane"
echo "2) Worker"
echo "3) Standalone (Dev)"
echo ""
KUBE_SYSTEM_TYPE=0
while true; do
    read -p "Option (1/3): " option
    case $option in
        1 ) KUBE_SYSTEM_TYPE=1; break ;;
        2 ) KUBE_SYSTEM_TYPE=2; break ;;
        3 ) KUBE_SYSTEM_TYPE=3; break ;;
        * ) echo "Invalid input, try again." && exit 1 ;;
    esac
done