#/bin/bash

# VAR 1 install
#================

apt update
apt install gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install terraform


# VAR 2 install
#================
#cd /tmp
#LINK_TERRAFORM="https://releases.hashicorp.com/terraform/1.2.9/terraform_1.2.9_linux_amd64.zip"
#"https://releases.hashicorp.com/terraform/1.2.9/terraform_1.2.9_SHA256SUMS"
#wget -O /tmp/terraform.zip $LINK_TERRAFORM


#wget -O terraform_SHA256SUMS -q ${LINK_TERRAFORM}_SHA256SUMS
#sha256sum -c --ignore-missing terraform_SHA256SUMS

#sudo unzip terraform.zip -d /usr/local/bin/

#--------------------
terraform version

echo "Terraform 8s installed"






