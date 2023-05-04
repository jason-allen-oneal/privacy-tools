# privacy-tools
## Requirements
Before running the script, ensure that you have the following requirements:
- An operating system that is supported by the script (currently supports Debian-based, Fedora-based, and Arch-based systems).
- `git` is installed.
- Internet connection is available.
- Root access or sudo privileges.

## Running the Script
1. Clone the repository containing the script:
```
git clone https://github.com/jason-allen-oneal/privacy-tools.git
```
2. Navigate to the directory containing the script:
```
cd project/
```
3. Make the script executable:
```
chmod +x privacy-tools.sh
```
4. Run the script:
```
./privacy-tools.sh
```

## Script Flow
1. The script starts by updating the package lists and upgrading the installed packages on the system.
2. Necessary packages for the script are then installed depending on the package manager available on the system.
3. DNS settings are configured to use dnscrypt-proxy for increased privacy and security.
4. Proxychains is configured to use Tor for anonymous browsing and traffic routing.
5. The user is prompted to choose a VPN to install. NordVPN, ProtonVPN, and Surfshark VPN are included as options. Alternatively, the user can specify the name of another VPN package to install.
6. The script installs the selected VPN package using the available package manager.

## Additional Information
- The script uses dnscrypt-proxy to encrypt and authenticate DNS queries, which helps protect against DNS-based attacks and surveillance.
- Tor is used to route traffic through a network of volunteer nodes, making it difficult to trace the origin and destination of internet traffic.
- Proxychains is a tool that allows applications to use proxies, including Tor, to access the internet. In this script, Proxychains is configured to use Tor as the default proxy for all applications.
- The user is prompted to choose a VPN to install, and the script installs the selected VPN using the available package manager. If the user chooses to install a VPN that is not included as an option, they can specify the name of the package to install. The script uses the available package manager to install the specified package.
- The script is designed to increase privacy and security by configuring the system to use encrypted DNS, anonymous browsing, and a VPN. However, no system can be completely secure, and the user should take additional steps to secure their system and protect their privacy.
