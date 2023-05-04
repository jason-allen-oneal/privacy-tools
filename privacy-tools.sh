#!/bin/bash

echo "Simple Online Privacy Tool Installer"
echo "This tool will install tor, I2P, dnscrypt-proxy, and proxychains if not found."
echo "It is highly recommended that you read the documentation for these tools"
echo
echo "Testing for Tor"
if ! command -v tor &> /dev/null
then
	echo "Installing Tor..."
	sudo apt install -y tor
fi
echo "Tor installation complete."
echo
echo

echo "Testing for I2P"
if ! command -v i2prouter &> /dev/null
then
	echo "Installing I2P..."
	sudo apt install -y i2p
fi
echo "I2P installation complete."
echo
echo

echo "Testing for dnscrypt-proxy"
if sudo dnscrypt-proxy -version | grep -q 'not found';
then
	echo "Installing dnscrypt."
	sudo apt purge dnscrypt-proxy
	sudo apt install dnscrypt-proxy
	sudo cp /etc/dnscrypt-proxy/example-dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
	sudo apt remove resolvconf
	sudo cp /etc/resolv.conf /etc/resolv.conf.backup
	sudo rm -f /etc/resolv.conf
	sudo touch /etc/resolv.conf
	sudo echo -e "nameserver 127.0.0.1\noptions edns0" >> /etc/resolv.conf
	sudo dnscrypt-proxy -service install
fi
echo "dnscrypt-proxy installation complete."
echo
echo

echo "Testing for proxychains"
if ! command -v proxychains4 &> /dev/null
then
	echo "Installing proxychains..."
	sudo apt install -y proxychains4
fi

sed -in "s/^strict_chain.*/#strict_chain/" /etc/proxychains4.conf
sed -in "s/^random_chain.*/#random_chain/" /etc/proxychains4.conf
sed -in "s/^#dynamic_chain.*/dynamic_chain/" /etc/proxychains4.conf
sed -in "s/^#proxy_dns.*/proxy_dns/" /etc/proxychains4.conf
sed -in "s/^#quiet_mode.*/quiet_mode/" /etc/proxychains4.conf
echo "socks5 127.0.0.1 9050" >> /etc/proxychains4.conf

touch ~/privacy-tools
echo "#!/bin/bash" >> ~/privacy-tools
echo "# Simple Online Privacy Tools" >> ~/privacy-tools
echo "sudo killall tor" >> ~/privacy-tools
echo "sudo service tor start" >> ~/privacy-tools
echo "i2prouter start" >> ~/privacy-tools
echo "sudo dnscrypt-proxy -service start" >> ~/privacy-tools

echo "Would you like to install a VPN? (Manual registration required) [y/n]: "
read -n 1 installVPN
if [[ "${installVPN,,}" == "y" ]]; then
	declare -a VPNS=('NordVPN' 'ExpressVPN' 'ProtonVPN')
	echo "Install which VPN?"
	for val in ${StringArray[@]}; do
		str="${k}. ${VPNs[$k-1]}"
		echo "${str}"
	done
	echo "[1-${#VPNS[@]}]: "
	read -n 1 vpnChoice
	
	echo "echo 'Starting VPN...'" >> ~/privacy-tools

	if [[ "${vpnChoice}" == 1 ]]; then
		echo "Installing NordVPN..."
		wget -qnc https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb
		sudo dpkg -i ./nordvpn-release_1.0.0_all.deb
		sudo apt update
		sudo apt -y install nordvpn
		rm nordvpn*.deb
		nordvpn login
		echo "nordvpn connect" >> ~/privacy-tools
	fi
	
	if [[ "${vpnChoice}" == 2 ]]; then
		echo "Installing ExpressVPN..."
		sudo apt install -y openvpn resolvconf
		echo "Enter filepath of your ovpn config file: "
		read configPath
		echo "sudo openvpn --config ${configPath} --script-security 2 --up /etc/openvpn/update-resolv-conf --down /etc/openvpn/update-resolv-conf" >> ~/privacy-tools
	fi

	if [[ "${vpnChoice}" == 3 ]]; then
		sudo apt install -y openvpn dialog python3-pip python3-setuptools
		sudo pip3 install protonvpn-cli
		sudo protonvpn-cli init
		echo "sudo protonvpn-cli c" >> ~/privacy-tools
	fi
fi

echo "echo 'Connected and ready. You may now do your work in anonymity.'" >> ~/privacy-tools
sudo chmod 777 ~/privacy-tools

echo "You may now run '~/privacy-tools' whenever you need to be anonymous."
exit 0
#!/bin/bash

# Check if running on Ubuntu or Debian
if [[ -n "$(command -v apt-get)" ]]; then
    # Install required packages
    sudo apt-get update
    sudo apt-get install i2p tor dnscrypt-proxy nordvpn protonvpn-cli openvpn

# Check if running on Arch Linux
elif [[ -n "$(command -v pacman)" ]]; then
    # Install required packages
    sudo pacman -Syu
    sudo pacman -S i2p tor dnscrypt-proxy nordvpn protonvpn-cli openvpn

# Check if running on Fedora
elif [[ -n "$(command -v dnf)" ]]; then
    # Install required packages
    sudo dnf update
    sudo dnf install i2p tor dnscrypt-proxy nordvpn protonvpn-cli openvpn

else
    # Unsupported operating system
    echo "Error: Unsupported operating system"
    exit 1
fi

# Prompt user for their VPN choice
echo "Which VPN would you like to install? (nordvpn/protonvpn/surfsharkvpn/expressvpn/other)"
read vpn_choice

# Install user's VPN choice
case $vpn_choice in
    "nordvpn")
        sudo nordvpn install
        ;;
    "protonvpn")
        sudo protonvpn-cli --install
        ;;
    "surfsharkvpn")
        sudo apt-get install openvpn
        wget https://o58jpn9mxrs1yibne2xa57ff.s3.amazonaws.com/surfshark-release_1.0.0_amd64.deb
        sudo dpkg -i surfshark-release_1.0.0_amd64.deb
        sudo apt-get update
        sudo apt-get install surfshark-vpn
        ;;
    "expressvpn")
        sudo apt-get update
        sudo apt-get install curl unzip openvpn
        curl -L -o expressvpn.deb https://download.expressvpn.xyz/clients/linux/expressvpn_3.9.0.75-1_amd64.deb
        sudo dpkg -i expressvpn.deb
        ;;
    "other")
        echo "Please enter the name of the VPN package you would like to install:"
        read vpn_package
        sudo $PACKAGE_MANAGER install $vpn_package
        ;;
    *)
        echo "Invalid choice. Please select a valid VPN option."
        ;;
esac

# Check if VPN installation was successful
if [ $? -eq 0 ]; then
    echo "VPN installation successful."
else
    echo "Error: VPN installation failed."
fi

# Done
echo "Installation complete."
