**New: [wireguard-install](https://github.com/Nyr/wireguard-install) is also available.**

## openvpn-install
OpenVPN [road warrior](http://en.wikipedia.org/wiki/Road_warrior_%28computing%29) installer for Ubuntu, Debian, AlmaLinux, Rocky Linux, CentOS and Fedora.

This script will let you set up your own VPN server in no more than a minute, even if you haven't used OpenVPN before. It has been designed to be as unobtrusive and universal as possible.

### Installation
Run the script and follow the assistant:

<pre><code>
wget https://git.io/vpn -O openvpn-install.sh && \
bash openvpn-install.sh
</pre></code>

or

<pre><code>
bash <(wget -O - raw.githubusercontent.com/numbnet/WebPanel/master/OpeVPN/OpenVPN.sh)
</pre></code>

  Once it ends, you can run it again 
to add more users, remove some of them or
even completely uninstall OpenVPN.
