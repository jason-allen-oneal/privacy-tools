#!/bin/bash

# Update package lists and upgrade packages
if [ -x "$(command -v apt-get)" ]; then
    sudo apt-get update && sudo apt-get upgrade -y
elif [ -x "$(command -v dnf)" ]; then
    sudo dnf upgrade -y
fi

# Install necessary packages
if [ -x "$(command -v apt-get)" ]; then
    sudo apt-get install -y git curl gnupg ca-certificates i2p tor dnscrypt-proxy
elif [ -x "$(command -v dnf)" ]; then
    sudo dnf install -y git curl gnupg ca-certificates i2p tor dnscrypt-proxy
elif [ -x "$(command -v pacman)" ]; then
    sudo pacman -Syu i2p tor dnscrypt-proxy
else
    echo "Error: Unsupported operating system"
    exit 1
fi

# Configure DNS settings to use dnscrypt-proxy
sudo cp /etc/dnscrypt-proxy/example-dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
sudo cp /etc/resolv.conf /etc/resolv.conf.backup
sudo rm -f /etc/resolv.conf
sudo touch /etc/resolv.conf
sudo echo -e "nameserver 127.0.0.1\noptions edns0" >> /etc/resolv.conf
if [ -x "$(command -v systemctl)" ]; then
    sudo systemctl enable --now dnscrypt-proxy.service
else
    sudo service dnscrypt-proxy start
fi

# Configure proxychains to use Tor
if [ -f /etc/proxychains.conf ]; then
    sudo sed -i 's/^strict_chain/#strict_chain/' /etc/proxychains.conf
    sudo sed -i 's/^random_chain/#random_chain/' /etc/proxychains.conf
    sudo sed -i 's/^#dynamic_chain/dynamic_chain/' /etc/proxychains.conf
    sudo sed -i 's/^#proxy_dns/proxy_dns/' /etc/proxychains.conf
    sudo sed -i 's/^#quiet_mode/quiet_mode/' /etc/proxychains.conf
    sudo echo "socks5 127.0.0.1 9050" >> /etc/proxychains.conf
elif [ -f /etc/proxychains4.conf ]; then
    sudo sed -i 's/^strict_chain/#strict_chain/' /etc/proxychains4.conf
    sudo sed -i 's/^random_chain/#random_chain/' /etc/proxychains4.conf
    sudo sed -i 's/^#dynamic_chain/dynamic_chain/' /etc/proxychains4.conf
    sudo sed -i 's/^#proxy_dns/proxy_dns/' /etc/proxychains4.conf
    sudo sed -i 's/^#quiet_mode/quiet_mode/' /etc/proxychains4.conf
    sudo echo "socks5 127.0.0.1 9050" >> /etc/proxychains4.conf
fi

# Prompt user for VPN choice
echo "Which VPN would you like to install?"
echo "1. NordVPN"
echo "2. ProtonVPN"
echo "3. Surfshark VPN"
echo "4. Other"
read -p "Enter your choice (1-4): " vpn_choice

if [ "$vpn_choice" = "1" ]; then
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install -y nordvpn
    elif [ -x "$(command -v pacman)" ]; then
        sudo pacman -S nordvpn
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install -y nordvpn
    else
        echo "Error: Unsupported operating system"
        exit 1
    fi
elif [ "$vpn_choice" = "2" ]; then
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install -y protonvpn-cli
    elif [ -x "$(command -v pacman)" ]; then
        sudo pacman -S protonvpn-cli
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install -y protonvpn-cli
    else
        echo "Error: Unsupported operating system"
        exit 1
    fi
elif [ "$vpn_choice" = "3" ]; then
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install -y surfshark-vpn
    elif [ -x "$(command -v pacman)" ]; then
        sudo pacman -S surfshark-vpn
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install -y surfshark-vpn
    else
        echo "Error: Unsupported operating system"
        exit 1
    fi
elif [ "$vpn_choice" = "4" ]; then
    echo "Please enter the name of the VPN package you would like to install"
    read other_vpn
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install -y $other_vpn
    elif [ -x "$(command -v pacman)" ]; then
        sudo pacman -S $other_vpn
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install -y $other_vpn
    else
        echo "Error: Unsupported operating system"
        exit 1
    fi
else
    echo "Unsupported VPN choice"
    exit 1
fi

filename="privacy-tools.sh"
exec 3<> "$filename"

echo "$item" >&3
echo "#!/bin/bash" >&3
echo "# Start i2p and Tor services" >&3
echo "sudo systemctl start i2p" >&3
echo "sudo systemctl start tor" >&3

echo "# Start dnscrypt-proxy service" >&3
echo "if [ -x "$(command -v systemctl)" ]; then" >&3
echo "	sudo systemctl start dnscrypt-proxy.service" >&3
echo "else" >&3
echo "	sudo service dnscrypt-proxy start" >&3
echo "fi" >&3

echo "# Start VPN service" >&3
if [ "$vpn_choice" = "1" ]; then
	echo "sudo nordvpn connect" >&3
elif [ "$vpn_choice" = "2" ]; then
	echo "sudo protonvpn-cli connect" >&3
elif [ "$vpn_choice" = "3" ]; then
	echo "sudo surfshark-vpn attack" >&3
elif [ "$vpn_choice" = "4" ]; then
	echo "echo \"Please enter the name of the VPN command to start\"" >&3
	echo "read other_vpn_cmd" >&3
	echo "sudo $other_vpn_cmd" >&3
echo "fi" >&3

# Close the file
exec 3>&-

echo "Installation and configuration complete. However, we recommend reviewing documentation for the installed packages to ensure proper usage. Thank you for using our script!"
