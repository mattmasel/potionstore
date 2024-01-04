#!/bin/bash
# My potions are too strong for you traveller...

# Update APT repo and Upgrade
echo "[+] Starting update and upgrade"
sudo apt update
sudo apt upgrade -y

# Install APT packages not available on github
echo "[+] Installing APT packages"
install="sudo apt-get install"

$install -y curl
$install -y vim
$install -y jq
$install -y python3-pip
$install -y nmap
$install -y git
$install -y firefox-esr
$install -y hashcat

# Cleanup APT
echo "[+] Cleaning up APT installs"
sudo apt autoremove -y
sudo apt autoclean

# Add Tools directory if doesnt exist and cd
tools_directory=~/Tools

echo "[+] Checking if $tools_directory exists"

if [ ! -d "$tools_directory" ]; then
    echo "[!] Creating $tools_directory"
    mkdir "$tools_directory"
    echo "[+] Successfully created $tools_directory"
fi

echo "[+] Moving to $tools_directory"
cd "$tools_directory"

# Install Go

if ! which go &> /dev/null; then
    echo "[+] Downloading go"
    url="https://go.dev/dl/"
    main_page_content=$(curl -s "$url")

    target_version=$(echo "$main_page_content" | pup 'a[href*=".linux-amd64.tar.gz"] attr{href}' | sed -n '2p' | sed 's|/dl/||')
    go_download_link="${url}${target_version}"

    echo "Download URL: $go_download_link"
    wget "$go_download_link"

    # Extract checksum from the tt tag, may need to modify which tt tag if errors occur
    checksums=$(echo "$main_page_content" | pup 'tt text{}')
    checksum=$(echo "$checksums" | sed -n '7p')

    file_checksum=$(sha256sum $target_version | awk '{print $1}')
    echo "$checksum"
    echo "$file_checksum"

    if [ "$file_checksum" == "$checksum" ]; then
        echo "[+] Checksum verification success"
    else
        echo "[!] Checksum verification failed. Exiting."
        exit 1
    fi

    echo "[+] Extracting ${target_version}"
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "$target_version"

    # Setup Paths for go
    echo 'export GOROOT=/usr/local/go/bin' >> ~/.bashrc
    echo 'export GOPATH=~/go' >> ~/.bashrc
    echo 'export GOBIN=$GOPATH/bin' >> ~/.bashrc
    echo 'export PATH=$PATH:$GOROOT:$GOBIN' >> ~/.bashrc
    source ~/.bashrc
    rm "$target_version"

    if go version; then
        echo "[+] go installed successfully"
    else
        echo "[!] go installation failed"
        exit 1
    fi
else
    echo "[!] Go already installed"
fi

# Install GitHub Tools
cd "$tools_directory"

echo "[+] Installing sqlmap"
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
echo "[+] done"

echo "[+] Installing seclists"
git clone https://github.com/danielmiessler/SecLists.git
echo "[+] done"

echo "[+] Installing dcode"
git clone https://github.com/UltimateHackers/Decodify
cd Decodify
make install
echo "[+] done"
cd "$tools_directory"

# Install Go Tools

echo "[+] Installing ffuf"
if ! which ffuf &> /dev/null; then
    go install github.com/ffuf/ffuf/v2@latest; then
    echo "[+] done"
else
    echo "[!] Ffuf already installed"
fi

echo "[+] Installing subfinder"
if ! which subfinder &> /dev/null; then
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    echo "[+] done"
else
    echo "[+] Subfinder already installed"
fi

# Install Closed Source Programs

# Burp

# Add time and date to bash prompt

echo 'export PS1="-[\[$(tput sgr0)\]\[\033[38;5;10m\]\d\[$(tput sgr0)\]-\[$(tput sgr0)\]\[\033[38;5;10m\]\t\[$(tput sgr0)\]]-[\[$(tput sgr0)\]\[\033[38;5;214m\]\u\[$(tput sgr0)\]💀\[$(tput sgr0)\]\[\033[38;5;196m\]\h\[$(tput sgr0)\]]-\n-[\[$(tput sgr0)\]\[\033[38;5;33m\]\w\[$(tput sgr0)\]]\\$ \[$(tput sgr0)\]"' >> ~/.bashrc
source ~/.bashrc

# Exit

echo "[+] Upgrade complete, Have a nice day."
