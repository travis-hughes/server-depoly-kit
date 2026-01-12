install_microcloud()
{
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
}

install_clamav()
{
    apt install clamav clamav-daemon

    # Ensure virus databases are up to date
    service clamav-freshclam stop
    freshclam
    service clamav-freshclam start


    ( sudo crontab -l 2>/dev/null; cat <<'EOF'
service clamav-freshclam stop
freshclam
service clamav-freshclam start

echo "" > /var/log/scan_daily.log
echo "Running Scan" > /var/log/scan_daily.log
clamscan -r -i --log=/var/log/clamav/scan.log /home
clamscan -r -i --log=/var/log/clamav/scan.log /var
clamscan -r -i --log=/var/log/clamav/scan.log /usr


'
EOF
    ) | sudo crontab -
}


echo "Optional Software"
OPTIONS=("Tailscale: 1" ": 2" "Skip: 3")
for OPTION in "${!OPTIONS[@]}"
    do
        case "$OPTION" in
        1 )
            curl -fsSL https://tailscale.com/install.sh | sh
            ;;
        2 ) 
            install_microcloud
            ;;
        3 )
            install_clamav
            ;; 
        4 )
            break
            ;;
        * ) echo "Invalid input, try again." && exit 1 ;;
    esac
done