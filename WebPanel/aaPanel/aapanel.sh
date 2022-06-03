#/bin/bash

#  bash <(curl -L -sS https://raw.githubusercontent.com/numbnet/WebPanel/master/aaPanel/aapanel.sh)
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/numbnet/WebPanel/master/aaPanel/aapanel.sh)"
# bash <(curl -fsSL raw.githubusercontent.com/numbnet/WebPanel/master/aaPanel/aapanel.sh || wget -O - raw.githubusercontent.com/numbnet/WebPanel/master/aaPanel/aapanel.sh)

# -------------------------------------
# VARIABLE
function wait {
    echo -en "\n\t\tНажмите любую клавишу для продолжения";read -s -n 1;
}

OS="$(cat /etc/*release |grep '^ID=' |sed 's/"//g' |awk -F= '{print $2 }' )";
release="$(cat /etc/*release |grep '^VERSION_ID=' |sed  's/"//g' |awk -F= '{print $2 }' )";

function title
{
clear
title="Install aaPanel on ${OS} ${release}";
wait
}

function MyIP
{
IP_ADDR_ETH="$(ip addr show eth0 |grep inet |awk '{ print $2; }' |sed 's/\/.*$//' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' )";
IP_ICANHAZIP="$(echo $(curl -4 icanhazip.com))";
IP_MY=$(hostname -I|cut -f1 -d ' ');
## ======
if [ "$IP_ADDR_ETH" == "$IP_ICANHAZIP" ]; then
  myip="$IP_ADDR_ETH";
  echo "Внешний ip (eth0): $myip";
else
  if [ "$MY_IP" == "$IP_ICANHAZIP" ]; then
    myip="$MY_IP";
    echo "Внешний ip (hostname): $myip";
  else
    myip="$IP_ICANHAZIP";
    echo "Внешний ip (icanhazip.com): $myip";
  fi;
fi
};
# echo ${OS} ${release}

function StartInstall {
# ===== centos
if [ "$OS" == 'centos' ]; then
  echo "Is $OS ..."; title
  yum install -y wget
  wait
    bash <(wget -O - raw.githubusercontent.com/numbnet/WebPanel/master/aaPanel/lib/install_6.0_en.sh)
else
  echo "Not centos..."
  ## === Ubuntu/Deepin:
  if [ "$OS" == 'ubuntu' ]; then
    echo "Is $OS ..."; title
    wait
    wget -O install.sh https://raw.githubusercontent.com/numbnet/WebPanel/master/aaPanel/lib/install-ubuntu_6.0_en.sh && bash install.sh aapanel
  else
    echo "Not ubuntu..."
    # ===== debian
    if [ "$OS" == 'debian' ]; then
      echo "Is $OS ..."; title
      wait
      wget -O install.sh https://raw.githubusercontent.com/numbnet/WebPanel/master/aaPanel/lib/install-ubuntu_6.0_en.sh && bash install.sh aapanel
    else
      echo "Not debian..."
      # ===== Fedora
      if [ "$OS" == 'fedora' ]; then
        echo "Is $OS ..."; title
	wait
        yum install -y wget && wget -O install.sh https://raw.githubusercontent.com/numbnet/WebPanel/master/aaPanel/lib/install_6.0_en.sh && bash install.sh
      else
        echo -en "Is $OS ...\nScript NOT work.\n EXIT";
		wait
		exit
      fi
    fi
  fi  
fi

}
StartInstall


# Перейдите в ssh и введите следующую команду для сброса пароля (замените "testpasswd" в конце команды новым паролем, который вы хотите изменить)
# Примечание. Для пользователей debian / ubuntu используйте учетную запись с правами root для выполнения этой команды.
# cd /www/server/panel && python tools.py panel admin

# Если вам будет предложено войти несколько раз, временно отключите вход. Введите следующую команду, чтобы снять ограничения входа.

# rm -f /www/server/panel/data/*.login

exit
