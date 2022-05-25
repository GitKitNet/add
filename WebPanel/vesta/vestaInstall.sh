#!/bin/bash

title="Installation Vesta Web Panel Control"

##=========================
# VARIABLE
function wait { 
	echo -en "\n\t\tДля продолжения, нажмите любую клавишу";read -s -n 1;
}
function title {
  clear
  echo "$title"
  wait
}



##=========================
# Install Ubuntu, Debian, Centos 
function VestaInstall {
  title
  read -p "Enter Domain name: " domainname
  read -p "Enter Email admina: " AdminEmail
  read -p "Enter Admin Password: " AdminPassword
  
  # Download installation script
  curl -O http://vestacp.com/pub/vst-install.sh

  # Run it
  bash vst-install.sh \
    --nginx yes --apache yes \
    --phpfpm no \
    --named yes \
    --remi yes \
    --vsftpd yes --proftpd no \
    --iptables yes --fail2ban yes \
    --quota no \
    --exim yes --dovecot yes \
    --spamassassin yes --clamav yes \
    --softaculous yes \
    --mysql yes --postgresql no \
    --hostname ${domainname} \
    --email ${AdminEmail} \
    --password ${AdminPassword}
  echo -en "\t===== Installation is END =====\n"
  echo -en "Domain name: ${domainname}\n ADMIN PASSWORD: ${AdminPassword}\n ADMIN MAIL:  ${AdminEmail}"
  wait
  
  }
VestaInstall

  
  
  
  
  
