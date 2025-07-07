#!/bin/bash

set -e  # Exit immediately on error

# Update package lists and upgrade packages
if command -v apt-get &>/dev/null; then
    sudo apt-get update && sudo apt-get upgrade -y
elif command -v dnf &>/dev/null; then
    sudo dnf upgrade -y
elif command -v pacman &>/dev/null; then
    sudo pacman -Syu --noconfirm
else
    echo "Error: Unsupported operating system"
    exit 1
fi

# Install necessary packages
if command -v apt-get &>/dev/null; then
    sudo apt-get install -y git curl gnupg ca-certificates i2p tor dnscrypt-proxy proxychains
elif command -v dnf &>/dev/null; then
    sudo dnf install -y git curl gnupg ca-certificates i2p tor dnscrypt-proxy proxychains
elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm git curl gnupg ca-certificates i2p tor dnscrypt-proxy proxychains
fi

# Configure DNSCrypt
if [ -f /etc/dnscrypt-proxy/example-dnscrypt-proxy.toml ]; then
    sudo cp /etc/dnscrypt-proxy/example-dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
fi

sudo cp /etc/resolv.conf /etc/resolv.conf.backup
sudo bash -c 'echo -e "nameserver 127.0.0.1\noptions edns0" > /etc/resolv.conf'

if command -v systemctl &>/dev/null; then
    sudo systemctl enable --now dnscrypt-proxy.service
else
    sudo service dnscrypt-proxy start
fi

# Configure proxychains (classic and version 4)
for config in /etc/proxychains.conf /etc/proxychains4.conf; do
    if [ -f "$config" ]; then
        sudo sed -i 's/^strict_chain/#strict_chain/' "$config"
        sudo sed -i 's/^random_chain/#random_chain/' "$config"
        sudo sed -i 's/^#dynamic_chain/dynamic_chain/' "$config"
        sudo sed -i 's/^#proxy_dns/proxy_dns/' "$config"
        sudo sed -i 's/^#quiet_mode/quiet_mode/' "$config"
        sudo bash -c "echo 'socks5 127.0.0.1 9050' >> $config"
    fi
done

# Prompt for VPN
echo "Which VPN would you like to install?"
echo "1. NordVPN"
echo "2. ProtonVPN"
echo "3. Surfshark VPN"
echo "4. Other"
read -rp "Enter your choice (1-4): " vpn_choice

case "$vpn_choice" in
    1)
        vpn_pkg="nordvpn"
        ;;
    2)
        vpn_pkg="protonvpn-cli"
        ;;
    3)
        vpn_pkg="surfshark-vpn"
        ;;
    4)
        read -rp "Enter the name of the VPN package: " vpn_pkg
        ;;
    *)
        echo "Unsupported VPN choice"
        exit 1
        ;;
esac

if command -v apt-get &>/dev/null; then
    sudo apt-get install -y "$vpn_pkg"
elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm "$vpn_pkg"
elif command -v dnf &>/dev/null; then
    sudo dnf install -y "$vpn_pkg"
else
    echo "Error: Unsupported operating system"
    exit 1
fi

# Create helper script
filename="privacy-tools.sh"
cat <<EOF > "$filename"
#!/bin/bash

# Start i2p and Tor
sudo systemctl start i2p
sudo systemctl start tor

# Start dnscrypt-proxy
if command -v systemctl &>/dev/null; then
    sudo systemctl start dnscrypt-proxy.service
else
    sudo service dnscrypt-proxy start
fi

# Start VPN
EOF

case "$vpn_choice" in
    1)
        echo "sudo nordvpn connect" >> "$filename"
        ;;
    2)
        echo "sudo protonvpn-cli connect" >> "$filename"
        ;;
    3)
        echo "sudo surfshark-vpn connect" >> "$filename"
        ;;
    4)
        echo 'read -rp "Enter the VPN start command: " other_vpn_cmd' >> "$filename"
        echo 'sudo \$other_vpn_cmd' >> "$filename"
        ;;
esac

chmod +x "$filename"

echo "✅ Installation and configuration complete."
echo "➡️  A helper script named '$filename' has been created."
