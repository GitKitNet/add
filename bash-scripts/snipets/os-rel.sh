
# Detect OS
# ------------------
function os-ver() {
if grep -qs "ubuntu" /etc/os-release; then
 os="ubuntu"
 os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')

elif [[ -e /etc/debian_version ]]; then
 os="debian"
 os_version=$(grep -oE '[0-9]+' /etc/debian_version | head -1)

elif [[ -e /etc/almalinux-release || -e /etc/rocky-release || -e /etc/centos-release ]]; then
 os="centos"
 os_version=$(grep -shoE '[0-9]+' /etc/almalinux-release /etc/rocky-release /etc/centos-release | head -1)

elif [[ -e /etc/fedora-release ]]; then
 os="fedora"
 os_version=$(grep -oE '[0-9]+' /etc/fedora-release | head -1)

else
 echo "This installer seems to be running on an unsupported distribution.
Supported distros are Ubuntu, Debian, AlmaLinux, Rocky Linux, CentOS and Fedora.";
sleep 10 && exit

fi

echo "$os $os_version"

}
os-ver
