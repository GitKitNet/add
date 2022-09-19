#/bin/bash

# VAR 1 install
#================

#cd /tmp
#LINK_TERRAFORM="https://releases.hashicorp.com/terraform/1.2.9/terraform_1.2.9_linux_amd64.zip"
#"https://releases.hashicorp.com/terraform/1.2.9/terraform_1.2.9_SHA256SUMS"
#wget -O /tmp/terraform.zip $LINK_TERRAFORM


#wget -O terraform_SHA256SUMS -q ${LINK_TERRAFORM}_SHA256SUMS
#sha256sum -c --ignore-missing terraform_SHA256SUMS

#sudo unzip terraform.zip -d /usr/local/bin/

# VAR 2 install
#================

apt update
apt install gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install terraform

##-----

terraform -version

#установить автоподстановки:

terraform -install-autocomplete
#Это позволит нам завершать команды terraform с помощью клавиши Tab.

#Теперь создадим каталог, в котором будем работать со сценариями для тераформа:

mkdir -p /opt/terraform/yandex
#* в моем примере я решил работать в каталоге /opt/terraform/yandex.

#Перейдем в созданный каталог:
cd /opt/terraform/yandex

echo "Мы готовы приступить непосредственно к работе с terraform."

#-------

main.tf
terraform {
  required_version = "= 1.1.7"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "= 0.73"
    }
  }
}

provider "yandex" {
  token     = "<OAuth>"
  cloud_id  = "<идентификатор облака>"
  folder_id = "<идентификатор каталога>"
  zone      = "<зона доступности по умолчанию>"
}


#--------------------
terraform version

echo "Terraform 8s installed"






