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
OPTIONS=("Tailscale: 1" "ClamAV: 2" "Exit: 3")
for OPTION in "${!OPTIONS[@]}"
    do
        case "$OPTION" in
        1 )
            curl -fsSL https://tailscale.com/install.sh | sh
            tailscale up --accept-risk=all
            ;;
        2 )
            install_clamav
            ;; 
        3 )
            break
            ;;
        * ) echo "Invalid input, try again." ;;
    esac
done