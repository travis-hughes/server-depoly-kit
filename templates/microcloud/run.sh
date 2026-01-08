snap install microcloud lxd microceph microovn --cohort="+"


echo "\n========================================================================================"
echo "What microcloud configuration do you want: \n"
echo "1) Init"
echo "2) Join"
echo "========================================================================================\n"

read -p "Option (0/2): " OPTION
case "$OPTION" in
    1 ) TEMPLATE="init" ;;
    2 ) TEMPLATE="join" ;;
    * ) echo "Invalid input, try again." && exit 1 ;;
esac


if [ "$TEMPLATE" -eq "init" ]; then
    microcloud init
fi

if [ "$TEMPLATE" -eq "join" ]; then
    IP_ADDRESS=$( ensure_var_defined "IP Address" $IP_ADDRESS )
    microcloud join $IP_ADDRESS
fi