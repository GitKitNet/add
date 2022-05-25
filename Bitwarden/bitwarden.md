

# Install Bitwarden on Ubuntu 20.04

### How to Install Bitwarden on Ubuntu 20.04
### In this article, we’ll explain how to install Bitwarden on Ubuntu 20.04.

Bitwarden is open source password manager. It stores sensitive information such as website credentials in an encrypted vault. The Bitwarden platform offers a variety of client applications including a web interface, desktop applications, browser extensions, mobile apps, and a CLI.

This article will guide you to install self-hosted Bitwarden on Ubuntu 20.04 server.

Prerequisites

A Ubuntu 20.04 install KVM VPS.
A root user access or normal user with administrative privileges.
Bitwarden needs a Hosting Installation Id and Key to install. Please Request your Hosting Installation ID and Key.
Let’s get started with the installation process.

Install Bitwarden on Ubuntu 20.04

## 1. Keep the server up to date
apt update -y && \
    apt upgrade -y

2. Install Docker CE

Bitwarden will be deployed and run on your machine using an array of Docker containers. Bitwarden can be run with any Docker Edition or plan. Evaluate which edition is best for your installation.

Install repository over HTTPS using following command:

# apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
Add Docker’s official GPG key:

# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88 by searching for the last 8 characters of the fingerprint:

# apt-key fingerprint 0EBFCD88
Use the following command to set up the stable repository:

# add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
Update the apt package index:

# apt-get update
Install the latest version of Docker CE and containerd:

# apt-get install docker-ce docker-ce-cli containerd.io -y
Start and enable docker service

# systemctl start docker

# systemctl enable docker
3. Install Docker Compose

Docker Compose requires Python and the pip package manager.

# apt install -y python3 python3-pip -y
Install Docker Compose with pip.

# pip3 install docker-compose
4. Create a Bitwarden User (Optional)

# adduser bitwarden
Set password for bitwarden user (strong password):

# passwd bitwarden
Add the bitwarden user to the docker group:

# usermod -aG docker bitwarden
Create a working directory and grant user bitwarden full permission for it.

# mkdir -p /opt/bitwarden
# chown bitwarden: /opt/bitwarden
# chmod 700 /opt/bitwarden
Switch to the new user.

# su - bitwarden
5. Install Bitwarden Server

Download the official Bitwarden deployment script:

# wget -O bitwarden.sh https://go.btwrdn.co/bw-sh
# chmod +x bitwarden.sh
Execute the script.

# ./bitwarden.sh install
Enter your domain, such as bitw.example.com.
Enter the installation id.
Enter the installation key.
Enter Y to get a free SSL certificate from Let’s Encrypt.
Enter an email address to receive Let’s Encrypt reminders.
Wait for the installation to finish.
6. Configure the Environment

Run ./bitwarden.sh start to start the Bitwarden Server.

Note: Some Bitwarden features are not configured by the bitwarden.sh installer, and must be configured in the environment file, located at ./bwdata/env/global.override.env. At a minimum, you should configure:

…
globalSettings__mail__smtp__host=<placeholder>
globalSettings__mail__smtp__port=<placeholder>
globalSettings__mail__smtp__ssl=<placeholder>
globalSettings__mail__smtp__username=<placeholder>
globalSettings__mail__smtp__password=<placeholder>
…
adminSettings__admins=john@example.com
Run the following command to apply your changes:

./bitwarden.sh restart
See the official docs for more configuration information specific to your needs.

7. Create an Account

Visit your domain in a web browser, then click the button Create Account to register an account on your server.

The installation has been completed successfully. Now install Bitwarden Client on your devices. Set the server address to your domain by clicking the Setting button in the login page’s upper left corner.

In this article, we have shown how to install Bitwarden on Ubuntu 20.04.
