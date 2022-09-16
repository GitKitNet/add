#/bin/bash

cd /tmp
wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.12.12/terraform_0.12.12_linux_amd64.zip


wget -O terraform_SHA256SUMS -q https://releases.hashicorp.com/terraform/0.12.12/terraform_0.12.12_SHA256SUMS
sha256sum -c --ignore-missing terraform_SHA256SUMS



