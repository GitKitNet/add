#/bin/bash

cd /tmp
LINK_TERRAFORM="https://releases.hashicorp.com/terraform/1.2.9/terraform_1.2.9_linux_amd64.zip"
"https://releases.hashicorp.com/terraform/1.2.9/terraform_1.2.9_SHA256SUMS"
wget -O /tmp/terraform.zip $LINK_TERRAFORM


wget -O terraform_SHA256SUMS -q ${LINK_TERRAFORM}_SHA256SUMS
sha256sum -c --ignore-missing terraform_SHA256SUMS

sudo unzip terraform.zip -d /usr/local/bin/

#Для проверки можно запросить версию Terraform.
terraform version


