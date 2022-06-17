#!/usr/bin/env bash

#set +x
set -Eeuo pipefail

LINK="raw.githubusercontent.com/GitKitNet/add/main/cptoolkit.sh";
#bash -c "$(wget -O - $LINK || curl -fsSL $LINK)";
#bash -c "$(curl -L -fSs $LINK)"
#bash <(wget -O - $LINK)



# - - - - - - - - - - - - - - - - -
#            COLOR
# - - - - - - - - - - - - - - - - -
#BLACK='\033[1;40m';           # Black
#RED='\033[7;31m';             # Red
#GREEN='\033[7;32m';           # Green
#YELLOW='\033[1;33m';          # Yellow
#BLUE='\033[7;34m';            # Blue
#PURPLE='\033[1;35m';          # Purple
#CYAN='\033[4;36m';            # Cyan

BLACK='\033[0;40m';           # Black
RED='\033[0;31m'              # Red
GREEN='\033[0;32m'            # Green
YELLOW='\033[0;33m'           # Yellow
BLUE='\033[0;34m'             # Blue
PURPLE='\033[0;35m'           # Purple
CYAN='\033[0;36m'             # Cyan
NC='\033[0m'                  # No Color

Black="`tput setaf 0`"        # Black
Red="`tput setaf 1`"          # Red
Green="`tput setaf 2`"        # Green
Yellow="`tput setaf 3`"       # Yellow
Blue="`tput setaf 4`"         # Blue
Cyan="`tput setaf 5`"         # Cyan
Purple="`tput setaf 6`"       # Purple
White="`tput setaf 7`"        # White

BGBlack="`tput setab 0`"      # Black
BGRed="`tput setab 1`"        # Red
BGGreen="`tput setab 2`"      # Green
BGYellow="`tput setab 3`"     # Yellow
BGBlue="`tput setab 4`"       # Blue
BGCyan="`tput setab 5`"       # Cyan
BGPurple="`tput setab 6`"     # Purple
BGWhite="`tput setab 7`"      # White
RC="`tput sgr0`"              # Reset Color

TEXTCOLOR=$White;
BGCOLOR=$BLACK;




# - - - - - - - - - - - - - - - - - - - - - -
#       ASK START
# - - - - - - - - - - - - - - - - - - - - - -
function THIS() { 
clear;
while true; do 
echo -en "\t${Yellow}Do you want Run This script [y/N] .?${RC} "; 
read -e syn; 
case $syn in 
[Yy]* ) clear; echo -e "\n\t${GREEN}Starting NOW..${NC}"; sleep 3 && break ;; 
[Nn]* ) exit 0;;
esac; 
done;
};

# = = = = = = = = = = = = = = = = = = = = = = 
#      CHECK IF USER IS ROOT
# = = = = = = = = = = = = = = = = = = = = = = 
function CheckIFroot() {
  if [ "$(id -u)" != "0" ]; then
  while true; do 
  clear && \
  echo -en "
${Blue}# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =           
${RED} ERROR:\t You must be ${CYAN} [root user] ${RED} to install the software. 
${RED}\t Use 'sudo su - root' to login as root!                               
${Blue}\n# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
${GREEN}\n\tDo you want Run ${CYAN}as root ${GREEN}script [ y/N ] ..? ${RC}";
  read -e syn; 
  case $syn in 
    [Yy]* ) sleep 3; 
    sudo su; 
    break ;; 
    [Nn]* ) exit 1 ;;
  esac; 
  done;
elif [ "$(id -u)" == "0" ]; then
  echo -e "\n\t${YELLOW}Checking ROOT ${GREEN}IS - OK! \n ${RC}";
  sleep 5;
  fi;
}; 
# CheckIFroot


#  MAKE SURE SUDO AVAILABLE
#[ -z "$(command -v sudo)" ] && { apt-get -y install sudo >>/dev/null 2>&1; }
#[ -z "$(command -v curl)" ] && { apt-get -y install curl >>/dev/null 2>&1; }





# = = = = = = = = = = = = = = = = = = = = = = 
#      VARIABLE & function
# = = = = = = = = = = = = = = = = = = = = = = 


# A best practices Bash script template with many useful functions. This file is suitable for sourcing into other scripts and so only contains functions which are unlikely to need modification. 
# It omits the following functions:
#            - main()
#            - parse_params()
#            - script_usage()

# DESC:      Handler for unexpected errors
# ARGS:      $1 (optional): Exit code (defaults to 1)
# OUTS:      None
function script_trap_err() {
    local exit_code=1

    # Disable the error trap handler to prevent potential recursion
    trap - ERR

    # Consider any further errors non-fatal to ensure we run to completion
    set +o errexit
    set +o pipefail

    # Validate any provided exit code
    if [[ ${1-} =~ ^[0-9]+$ ]]; then
        exit_code="$1"
    fi

    # Output debug data if in Cron mode
    if [[ -n ${cron-} ]]; then
        # Restore original file output descriptors
        if [[ -n ${script_output-} ]]; then
            exec 1>&3 2>&4
        fi

        # Print basic debugging information
        printf '%b\n' "$ta_none"
        printf '***** Abnormal termination of script *****\n'
        printf 'Script Path:            %s\n' "$script_path"
        printf 'Script Parameters:      %s\n' "$script_params"
        printf 'Script Exit Code:       %s\n' "$exit_code"

        # Print the script log if we have it. It's possible we may not if we
        # failed before we even called cron_init(). This can happen if bad
        # parameters were passed to the script so we bailed out very early.
        if [[ -n ${script_output-} ]]; then
            # shellcheck disable=SC2312
            printf 'Script Output:\n\n%s' "$(cat "$script_output")"
        else
            printf 'Script Output:          None (failed before log init)\n'
        fi
    fi

    # Exit with failure status
    exit "$exit_code"
}

# DESC: Handler for exiting the script
# ARGS: None
# OUTS: None
function script_trap_exit() {
    cd "$orig_cwd"

    # Remove Cron mode script log
    if [[ -n ${cron-} && -f ${script_output-} ]]; then
        rm "$script_output"
    fi

    # Remove script execution lock
    if [[ -d ${script_lock-} ]]; then
        rmdir "$script_lock"
    fi

    # Restore terminal colours
    printf '%b' "$ta_none"
}

# DESC: Exit script with the given message
# ARGS: $1 (required): Message to print on exit
#       $2 (optional): Exit code (defaults to 0)
# OUTS: None
# NOTE: The convention used in this script for exit codes is:
#       0: Normal exit
#       1: Abnormal exit due to external error
#       2: Abnormal exit due to script error
function script_exit() {
    if [[ $# -eq 1 ]]; then
        printf '%s\n' "$1"
        exit 0
    fi

    if [[ ${2-} =~ ^[0-9]+$ ]]; then
        printf '%b\n' "$1"
        # If we've been provided a non-zero exit code run the error trap
        if [[ $2 -ne 0 ]]; then
            script_trap_err "$2"
        else
            exit 0
        fi
    fi

    script_exit 'Missing required argument to script_exit()!' 2
}

# DESC: Validate we have superuser access as root (via sudo if requested)
# ARGS: $1 (optional): Set to any value to not attempt root access via sudo
# OUTS: None
function check_superuser() {
    local superuser
    if [[ $EUID -eq 0 ]]; then
        superuser=true
    elif [[ -z ${1-} ]]; then
        # shellcheck disable=SC2310
        if check_binary sudo; then
            verbose_print 'Sudo: Updating cached credentials ...'
            if ! sudo -v; then
                verbose_print "Sudo: Couldn't acquire credentials ..." \
                    "${fg_red-}"
            else
                local test_euid
                test_euid="$(sudo -H -- "$BASH" -c 'printf "%s" "$EUID"')"
                if [[ $test_euid -eq 0 ]]; then
                    superuser=true
                fi
            fi
        fi
    fi;
    if [[ -z ${superuser-} ]]; then
        verbose_print 'Unable to acquire superuser credentials.' "${fg_red-}"
        return 1
    fi;
    verbose_print 'Successfully acquired superuser credentials.'
    return 0;
}


#  DESC:  Exit script with the given message
#  ARGS:  $1 (required): Message to print on exit
#         $2 (optional): Exit code (defaults to 0)
#  OUTS:  None
#  NOTE:  The convention used in this script for exit codes is:
#         0: Normal exit
#         1: Abnormal exit due to external error
#         2: Abnormal exit due to script error
function script_exit() {
    if [[ $# -eq 1 ]]; then printf '%s\n' "$1"; exit 0; fi;

    # If we've been provided a non-zero exit code run the error trap
    if [[ ${2-} =~ ^[0-9]+$ ]]; then printf '%b\n' "$1"; 
      if [[ $2 -ne 0 ]]; then script_trap_err "$2"; else exit 0; fi;
    fi;

    script_exit 'Missing required argument to script_exit()!' 2;
}


# DESC: Run the requested command as root (via sudo if requested)
# ARGS: $1 (optional): Set to zero to not attempt execution via sudo
#       $@ (required): Passed through for execution as root user
# OUTS: None
# = = = = = = = = = = = = = = = = = = = = = = 
function run_as_root() {
  if [[ $# -eq 0 ]]; then script_exit 'Missing required argument to run_as_root()!' 2; fi;

  if [[ ${1-} =~ ^0$ ]]; then local skip_sudo=true; shift; fi;

  if [[ $EUID -eq 0 ]]; then "$@";
    elif [[ -z ${skip_sudo-} ]]; then sudo -H -- "$@";
    else script_exit "Unable to run requested command as root: $*" 1;
  fi;
}

#run_as_root sudo

#script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# - - - - - - - - - - - - - - - - - - - - - -
function cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  echo "script cleanup here";
}; cleanup

function title() { clear; echo "${title} ${TKEY}"; }
function pause() { read -p "Press [Enter] key to continue..." fackEnterKey; }
function wait() { read -p "Press [ANY] key to continue..? " -s -n 1; }
function TIMER() {
  T="6";
  SE="\033[0K\r";
  E="$((1 * ${T}))";
  if [[ "$1" =~ ^[[:digit:]]+$ ]]; then T="$1"; fi;
  while [ $E -gt 0 ]; do
    echo -en " Please wait: ${RED}$E$SE${NC}";
    sleep 1;
    : $((E--));
  done;
}



        # # # # # # # # # # # # # # # # # # # # # # #
        #      function STARTScript() {
        # # # # # # # # # # # # # # # # # # # # # # #

# - - - - - - - - - - - - - - - - - - - - - -
#            UFW
# - - - - - - - - - - - - - - - - - - - - - -
function UFW() {
echo -e "\n${GREEN} = = = = = = = = = = \n   CONFIGURING UFW\n = = = = = = = = = = ${NC} \n"

if [ ! -d /etc/ufw ]; then apt-get install ufw -y; fi;

CURRENT_SSH_PORT=$(grep "Port" /etc/ssh/sshd_config | awk -F " " '{print $2}')

ufw logging low                 # define firewall rules
ufw default allow outgoing
ufw default deny incoming
ufw allow 22                    # default ssh port
if [ "$CURRENT_SSH_PORT" != "22" ]; then ufw allow "$CURRENT_SSH_PORT" && echo "UFW allow custom SSH port"; fi;
ufw allow 53                    # dns
ufw allow http                  # nginx
ufw allow https                 # 
ufw allow 123                   # ntp   
ufw allow 68                    # dhcp client
ufw allow 546                   # dhcp ipv6 client
ufw allow 873                   # rsync
ufw allow 22222                 # easyengine backend

## OPTIONAL FOR MONITORING
#ufw allow 161                  # SNMP UDP port
#ufw allow 1999                 # Netdata web interface
#ufw allow 6556                 # Librenms linux agent
#ufw allow 10050                # Zabbix-agent

};

# - - - - - - - - - - - - - - - - -
#figlet -f smslant SSH Toolkit;
function showBanner() {
clear && echo -e "
${BGRed}
${BLUE}_______________${GREEN}________________________________
${BLUE}   ________    ${GREEN}  ______          ____    _ __  
${BLUE}  / ___/ _ \   ${GREEN} /_  __/__  ___  / / /__ (_) /_ 
${BLUE} / /__/ ___/   ${GREEN}  / / / _ \/ _ \/ /  '_// / __/ 
${BLUE} \___/_/       ${GREEN} /_/  \___/\___/_/_/\_\/_/\__/  
${BLUE}_______________${GREEN}________________________________
${NC}";

}


function LoockUP() {
  sleep 3 && clear;
  echo -en "\n${GREEN}============    INFORMATION    ============${NC}\n";

if [[ -f "$HOME/.ssh/${kName}" ]]; then
  echo -en "\n${GREEN}NAME:     ${NC}${Yellow}${kName}";
  echo -en "\n${GREEN}PRIVAT:   ${NC}${YELLOW}" && cat "$HOME/.ssh/${kName}";
fi;
if [[ -f "$HOME/.ssh/${kName}.pub" ]]; then
  echo -en "\n${GREEN}PUBLIC:   ${NC}${Yellow}" && cat "$HOME/.ssh/${kName}.pub"
fi;
  echo -en "\n${GREEN}=======================${NC}\n";
  pause;
  break;
}

# - - - - - - - - - - - - - - - - -
function ConvertPPK() {
#OS="$( cat /etc/*release |grep '^ID=' | awk -F= '{print $2 }' )";
#OS=echo "$( cat /etc/*release |grep '^ID=' | awk -F= '{print $2 }' )";

 while true; do
 read -e -p "Do you want PuTTy file ${kName}.ppk [y/N] ..? " syn
 case $syn in
  [Yy]* ) 
echo -en "\n${YELLOW}Install PuTTy and Converted to *.PPK ${NC}";

if [[ "$OS" == 'arch' ]]; then pacman -S putty;
    elif [[ "$OS" == 'centos' ]] && [[ "$OS" == rhell ]]; then yum install putty -y;
    elif [[ "$OS" == 'fedora' ]]; then dnf install putty -y;
    elif [[ "$OS" == 'ubuntu' ]]; then apt-get install putty-tools -y;
    fi;
    if [[ -f "$HOME/.ssh/${kName}" ]]; then
          echo -en "\n${GREEN}SSH Key Exist\n ${NC}";
          echo -en "\n\t\t${GREEN}...OK${NC}"\n;
          puttygen ${kName} -o ${kName}.ppk;
        else
          echo "SSH key Not Exist";
        fi
  ;;
  [Nn]* ) break
  ;;
  esac;
 done
}


function AddON() {
  while true; do
  read -e -p "Do you want RUN Agent? [y/N] ?" ryn;
  case $ryn in
  [Yy]* ) clear; eval $(ssh-agent) && ssh-add -D; break ;;
  [Nn]* ) break;;
  esac;
  done

  while true; do
  read -e -p "Do you want add key to SSH Agent? [y/N]" ayn;
  case $ayn in
  [Yy]* ) local -r kName="$1"; ssh-add "$HOME/.ssh/$kName" ;;
  [Nn]* ) break;;
  esac;
  done

  while true; do
  read -e -p "Add to authorized_key? [y/N]" uyn;
  case $uyn in
  [Yy]* ) cat "$HOME/.ssh/${kName}.pub" >> "$HOME/.ssh/authorized_keys";;
  [Nn]* ) break;;
  esac;
  done;

}

function OnRUN() {
        title;
        read -e -p "Enter NAME ssh key: " IDK && ID="$( echo ${IDK} | sed 's/ /_/g' )";
        read -e -p "Add comment: " COMENT && COM="$( echo ${COMENT} | sed 's/ /./g' )";
        read -e -p "Enter password: " PASS;
        sleep 2;
        if [ -z "${ID}" ]; then ID="${hostname}_${USER}"; fi
        if [ -z "${COM}" ]; then COM="${USER}"@"$( echo ${IDK} | sed 's/ /./g' )"; fi;

        kName="$( echo ${ID} | sed 's/ /_/g' )_${TKEY}.key";

        if [ "$MKEY" == "PEM" ]; then
                BKEY="4096"
                if [ -z "${ID}" ]; then ID="azureuser"; fi
                if [ -z "${COM}" ]; then COM="azureuser"@"$( echo ${IDK} | sed 's/ /./g' )"; fi;
            ssh-keygen -m ${MKEY} -t ${TKEY} -b ${BKEY} -f $HOME/.ssh/${kName}.pem -C "${COM}" -N "$PASS";

        elif [ -z "${MKEY}" ]; then
            ssh-keygen -t ${TKEY} -f $HOME/.ssh/${kName} -C "${COM}" -N "$PASS";
        fi

        LoockUP ;
        ConvertPPK ;
}



#=============================================
#=============================================
function first(){
echo "
============================================
      Mysql Server Installation
============================================
"

if [ ! -x /usr/bin/mysql ] ; then
        apt install mysql-server -y && systemctl start mysql
fi

echo "
============================================================
Please Enter root  password for authorization to mysql db
------------------------------------------------------------"

read -r -p "Do you want to generated automatically ? [y/N] If not it will provide password." rootpass
if [[ "$rootpass" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
        db_pass=$(date +%s|sha256sum|base64|head -c 30)
else
        echo "Enter DB ROOT PASSWORD: "
        read -e db_pass

mysql_secure_installation <<EOF
y
y
${db_pass}
${db_pass}
y
y
y
y
EOF
fi;

echo "
============================================
      WordPress Install Script
============================================
      Please Enter Domain Name:
--------------------------------------------
";
read -e domain
authorization="mysql -uroot -p${db_pass}"
read -r -p "Do you want to generated automatically? [y/N] If not it will provide password.  " answer
if [[ "$answer" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
        dbPassword=$(date +%s|sha256sum|base64|head -c 25)
else
        echo "Enter DB USER PASSWORD:"
        read -e dbPassword
fi;

echo "Is everything ok, run install? [y/N]"
read -e run
if [ "$run" == n ] ; then exit;
else
        echo "
==============================================
  A robot is now installing WordPress for you.
==============================================
";

#set +e
mkdir -p /var/www/${domain}
cd /var/www/${domain}
#Connect to mysql docker container and create database
dbNameandUser=$(echo ${domain} | tr "." "_" | tr "-" "_")
Host=\'%\'

echo "--Reusing credentials----------------------"
$authorization -e "
CREATE USER 'root'@${Host} IDENTIFIED BY '${db_pass}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@${Host} WITH GRANT OPTION;
DROP USER 'root'@'localhost';"

$authorization -e "
DROP USER IF EXISTS ${dbNameandUser}@${Host};
DROP DATABASE IF EXISTS ${dbNameandUser};"

$authorization -e "
CREATE DATABASE ${dbNameandUser};
CREATE USER ${dbNameandUser}@${Host} IDENTIFIED BY '${dbPassword}';
GRANT ALL PRIVILEGES ON ${dbNameandUser}.* TO ${dbNameandUser}@${Host};
FLUSH PRIVILEGES;"
db_pass=${db_pass} >/dev/null 2>/dev/null
db_pass=${db_pass} > /tmp/${db_pass}
wp_admin=root
wp_pass=$(date +%s|sha256sum|base64|head -c 20)

apt-get install curl -y || apk add curl
curl -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /tmp/wp-cli.phar \
    && mv /tmp/wp-cli.phar /usr/local/bin/wp
wp core download \
    --path=/var/www/${domain} --locale=en_US --allow-root
wp config create \
    --path=/var/www/${domain} --dbname=${dbNameandUser} --dbuser=${dbNameandUser} --dbpass=${dbPassword} --dbhost=localhost --allow-root --skip-check
wp core install \
    --skip-email --url=${domain} --title=${domain} --admin_user=${wp_admin} --admin_password=${wp_pass} --admin_email=admin@${domain} --allow-root --path=/var/www/${domain}

# installing plugin:
wp plugin install \
    wp-sitemap-page
# activating plugin:
wp plugin activate \
    wp-sitemap-page

###mkdir -p /var/www/${domain}/wp-content/uploads
chmod 775 -R /var/www/${domain}/ ###wp-content/uploads
chown www-data:www-data -R /var/www/${domain}
echo -e "
Cleaning... \n

-----------------------------------------------
         Installation is complete!
-----------------------------------------------


=================================================
  Credentials for Database And for Wp-admin
=================================================
INFO
DataBase Root Password:     ${db_pass}
DataBase Name:              ${dbNameandUser}
DataBase User:              ${dbNameandUser}
DataBase Pass:              ${dbPassword}
-----------------------------------------------
Admin Panel Link:           http://${domain}/wp-admin/
Admin Panel Admin:          ${wp_admin}
Admin Panel Password:       ${wp_pass}

Try to connect mysql database:  mysql -h 127.0.0.1 -u root -p${db_pass}
=================================================
"

echo "
=================================================
  Credentials for Database And for Wp-admin
=================================================

DataBase Root Password:     ${db_pass}
DataBase Name:              ${dbNameandUser}
DataBase User:              ${dbNameandUser}
DataBase Pass:              ${dbPassword}
-----------------------------------------------

Admin Panel Link:           http://${domain}/wp-admin/
Admin Panel Admin:          ${wp_admin}
Admin Panel Password:       ${wp_pass}

-----------------------------------------------
" >> /tmp/credentials.txt
fi;

}





#=============================================
#=============================================
function second(){

echo "============================================
      WordPress Install Script
============================================
      Please Enter Domain Name:
--------------------------------------------"
read -e domain

read -r -p "Do you want Enter root DB pass automatically from cache ? [y/N] If not it will provide password." answer
if [[ "$answer" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
  db_pass=${db_pass} < /dev/null 2>/dev/null
  db_pass=${db_pass} >/dev/null 2>/dev/null
else
  echo "Enter DB ROOT PASSWORD: "
  read -e db_pass
fi

authorization="mysql -uroot -p${db_pass}"
read -r -p "Do you want to generated automatically ? [y/N] If not it will provide password.  " answer
if [[ "$answer" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
        dbPassword=$(date +%s|sha256sum|base64|head -c 25)
else
        echo "Enter DB_PASSWORD:"
        read -e dbPassword
fi

echo "Is everything ok, run install? [y/N]"

read -e run
if [ "$run" == n ] ; then
exit
else
echo "==============================================
  A robot is now installing WordPress for you.
=============================================="
#set +e
mkdir -p /var/www/${domain}
cd /var/www/${domain}
#Connect to mysql docker container and create database
dbNameandUser=$(echo ${domain} | tr "." "_" | tr "-" "_")
Host=\'%\'

echo "--Reusing credentials----------------------"

$authorization -e "
DROP USER IF EXISTS ${dbNameandUser}@${Host};
DROP DATABASE IF EXISTS ${dbNameandUser};"

$authorization -e "
CREATE DATABASE ${dbNameandUser};
CREATE USER ${dbNameandUser}@${Host} IDENTIFIED BY '${dbPassword}';
GRANT ALL PRIVILEGES ON ${dbNameandUser}.* TO ${dbNameandUser}@${Host};
FLUSH PRIVILEGES;"
wp_admin=root
wp_pass=$(date +%s|sha256sum|base64|head -c 20)

apt-get install curl -y || apk add curl \
&& curl -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod +x /tmp/wp-cli.phar \
&& mv /tmp/wp-cli.phar /usr/local/bin/wp \
&& wp core download --path=/var/www/${domain} --locale=en_US --allow-root \
&& wp config create --path=/var/www/${domain} --dbname=${dbNameandUser} --dbuser=${dbNameandUser} --dbpass=${dbPassword} --dbhost=localhost --allow-root --skip-check \
&& wp core install --skip-email --url=${domain} --title=${domain} --admin_user=${wp_admin} --admin_password=${wp_pass} --admin_email=admin@${domain} --allow-root --path=/var/www/${domain}

###mkdir -p /var/www/${domain}/wp-content/uploads
chmod 775 -R /var/www/${domain} ###/wp-content/uploads
chown www-data:www-data -R /var/www/${domain}
echo "Cleaning...
-----------------------------------------------
  Credentials for Database And for Wp-admin
-----------------------------------------------
INFO
DBRootPass: ${db_pass}
DBName: ${dbNameandUser}
DBUser: ${dbNameandUser}
DBPass: ${dbPassword}
Domainame:  http://${domain}/wp-admin/
WPAdmin: ${wp_admin}
WPPass: ${wp_pass}
=================================================
         Installation is complete!
=================================================
Try to connect mysql database:  mysql -h 127.0.0.1 -u root -p${db_pass}"

echo "Cleaning...
-----------------------------------------------
  Credentials for Database And for Wp-admin
-----------------------------------------------
INFO
DBRootPass: ${db_pass}
DBName: ${dbNameandUser}
DBUser: ${dbNameandUser}
DBPass: ${dbPassword}
Domainame:  http://${domain}/wp-admin/
WPAdmin: ${wp_admin}
WPPass: ${wp_pass}
=================================================
         Installation is complete!
=================================================
Try to connect mysql database:  mysql -h 127.0.0.1 -u root -p${db_pass}
-----------------------------------------------------------------------------" >> /tmp/credentials.txt
fi
}




#=============================================
#=============================================
function third(){

#set -x

echo "============================================
      Please Enter Domain Name:
============================================"
read -e domain

apt update && apt upgrade -y && apt install -y mc htop curl git wget gnupg gnupg2 nginx
apt-get -y install software-properties-common
apt-get update
add-apt-repository ppa:ondrej/php -y
apt-get update
apt-get -y install php7.4 php7.4-fpm php7.4-mysql php-common php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline  php7.4-imap php7.4-mbstring php7.4-xml php7.4-xmlrpc php7.4-imagick php7.4-dev php7.4-opcache php7.4-soap php7.4-gd php7.4-zip php7.4-intl php7.4-curl
sed -i 's/;cgi.fix_pathinfo=0/  cgi.fix_pathinfo=1/g' /etc/php/7.4/fpm/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 300M/g' /etc/php/7.4/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 300M/g' /etc/php/7.4/fpm/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/7.4/fpm/php.ini
sed -i 's/max_input_time = 60/max_input_time = 600/g' /etc/php/7.4/fpm/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.4/fpm/php.ini
cat << 'eof' >> /etc/php/7.4/fpm/php-fpm.conf

pm = dynamic
        pm.max_children = 97
        pm.start_servers = 20
        pm.min_spare_servers = 10
        pm.max_spare_servers = 20
        pm.max_requests = 200

eof
sudo apt-get -y install certbot
apt install -y python-certbot-nginx || apt-get -y install python3-certbot-nginx
cat << 'eof' >> /etc/nginx/sites-available/${domain}.conf
### Configuration ###
    server {
        listen 80;
        listen [::]:80;
        listen 443;
        listen [::]:443;
        server_name DMN www.DMN;
        root /var/www/DMN;
        index index.php index.html index.htm index.nginx-debian.html;

        proxy_connect_timeout 3600;
        proxy_send_timeout 3600;
        proxy_read_timeout 3600;
        send_timeout 3600;
        client_max_body_size 100M;

        location / {
            try_files $uri $uri/ /index.php$is_args$args;

                allow all;

            allow 000.000.000.000; #EXAMPLE NOT BLOCK
                #deny all;  #Example BLOCK ALL

        }

            location ^~ /(wp-admin|wp-login\.php) {
            allow 65.108.153.183; #office
                deny all;
            }

        location ~ "^\/([a-z0-9]{{28,32}})\.html" {
            add_header Content-Type text/plain;
            return 200 $1;
        }

        location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param REMOTE_ADDR $remote_addr;
            fastcgi_param HTTP_X_FORWARDED_FOR $http_x_forwarded_for;
            fastcgi_param HTTP_X_REAL_IP $http_x_real_ip;
            fastcgi_param HTTP_CF_CONNECTING_IP $http_cf_connecting_ip;
            fastcgi_intercept_errors off;
            fastcgi_buffer_size 16k;
            fastcgi_buffers 4 16k;
            fastcgi_read_timeout 3600;
        }

        location ~* \.(jpg|jpeg|png|gif|ico|css|js|mp4|svg|woff|woff2|ttf)$ {
            expires 365d;
        }

        location ~* /(?:uploads|files)/.*.php$ {
            deny all;
        }

        location ~* /*.sql {
            deny all;
        }

        location ~* /.git/* {
            deny all;
        }
        location  ^~ /wp-cron.php {
               allow 127.0.0.1;
        }

        location ~ /\.ht {
                deny all;
        }

        location = /xmlrpc.php {
            deny all;
        }

        location ~ /\. {
            deny all;
        }
    }
eof

cd /etc/nginx/sites-enabled/
ln -s ../sites-available/${domain}.conf

mkdir -p /var/www/${domain}/
chown -R www-data:www-data /var/www/${domain}/
cat << 'eof' >> /var/www/${domain}/index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to EXP!</title>
<style>body {width: 35em; margin: 0 auto; font-family: Tahoma, Verdana, Arial, sans-serif; }</style>
</head>
<body style="background-color:white;">
<h1 style="color:black;">Welcome to EXP!</h1>
</body>
</html>
eof

sed -i "s/DMN/${domain}/g" /etc/nginx/sites-available/${domain}.conf
sed -i "s/EXP/${domain}/g" /var/www/${domain}/index.html

sed -i "17a\\\treal_ip_header X-Forwarded-For;" /etc/nginx/nginx.conf
sed -i "18a\\\tset_real_ip_from 0.0.0.0/0;"  /etc/nginx/nginx.conf
nginx -s reload

# sed -i "4a\\\tserver_name ${domain} www.${domain};" /etc/nginx/sites-available/${domain}.conf
# sed -i "5a\\\treturn 301 https://\$host\$request_uri;" /etc/nginx/sites-available/${domain}.conf
# sed -i "6a\\\}" /etc/nginx/sites-available/${domain}.conf
# sed -i "7a\\\server {" /etc/nginx/sites-available/${domain}.conf
# sed -i "9c\\\tlisten 443 ssl;"  /etc/nginx/sites-available/${domain}.conf
# sed -i "10c\\\tlisten [::]:443 ssl;" /etc/nginx/sites-available/${domain}.conf
# sed -i "14i\\\tssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem;" /etc/nginx/sites-available/${domain}.conf
# sed -i "15i\\\tssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem;" /etc/nginx/sites-available/${domain}.conf
# sed -i "16i\\\tssl_protocols   TLSv1 TLSv1.1 TLSv1.2 SSLv3;" /etc/nginx/sites-available/${domain}.conf
#
# certbot --nginx -d ${domain} -d www.${domain} -m brain.devops@gmail.com --non-interactive ###--agree-tos
# sleep 5
# nginx -s reload
cd /root/
touch dm && wget https://scr.devkong.work/addomain_into_file.py && chmod +x addomain_into_file.py

}






#=============================================
#=============================================
function fourth(){
#set -x

echo "============================================
      Please Enter Domain Name:
============================================"
read -e domain

apt update && apt upgrade -y
apt install -y mc htop curl git wget gnupg gnupg2 nginx
apt-get -y install software-properties-common
apt-get update
add-apt-repository ppa:ondrej/php -y
apt-get update
apt-get -y install php7.4 php7.4-fpm php7.4-mysql php-common php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline  php7.4-imap php7.4-mbstring php7.4-xml php7.4-xmlrpc php7.4-imagick php7.4-dev php7.4-opcache php7.4-soap php7.4-gd php7.4-zip php7.4-intl php7.4-curl
sed -i 's/;cgi.fix_pathinfo=0/  cgi.fix_pathinfo=1/g' /etc/php/7.4/fpm/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 300M/g' /etc/php/7.4/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 300M/g' /etc/php/7.4/fpm/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/7.4/fpm/php.ini
sed -i 's/max_input_time = 60/max_input_time = 600/g' /etc/php/7.4/fpm/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.4/fpm/php.ini
cat << 'eof' >> /etc/php/7.4/fpm/php-fpm.conf

pm = dynamic
        pm.max_children = 97
        pm.start_servers = 20
        pm.min_spare_servers = 10
        pm.max_spare_servers = 20
        pm.max_requests = 200

eof
sudo apt-get -y install certbot
apt install -y python-certbot-nginx || apt-get -y install python3-certbot-nginx
cat << 'eof' >> /etc/nginx/sites-available/${domain}.conf
### Configuration ###
    server {
        listen 80;
        listen [::]:80;
        listen 443;
        listen [::]:443;
        server_name DMN www.DMN;
        root /var/www/DMN;
        index index.php index.html index.htm index.nginx-debian.html;

        proxy_connect_timeout 3600;
        proxy_send_timeout 3600;
        proxy_read_timeout 3600;
        send_timeout 3600;
        client_max_body_size 100M;

        error_page 403 404 /404.html;

        location = /404.html {
            internal; #return 404
        }

        location / {
            try_files $uri $uri/ /index.php$is_args$args;

                allow all;

            allow 000.000.000.000; #EXAMPLE NOT BLOCK
                #deny all;  #Example BLOCK ALL

        }

        location ^~ /(wp-admin|wp-login\.php) {
                allow all;

            allow 000.000.000.000; #EXAMPLE NOT BLOCK
                #deny all;  #Example BLOCK ALL

        }

        location ~ "^\/([a-z0-9]{{28,32}})\.html" {
            add_header Content-Type text/plain;
            return 200 $1;
        }

        location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param REMOTE_ADDR $remote_addr;
            fastcgi_param HTTP_X_FORWARDED_FOR $http_x_forwarded_for;
            fastcgi_param HTTP_X_REAL_IP $http_x_real_ip;
            fastcgi_param HTTP_CF_CONNECTING_IP $http_cf_connecting_ip;
            fastcgi_intercept_errors off;
            fastcgi_buffer_size 16k;
            fastcgi_buffers 4 16k;
            fastcgi_read_timeout 3600;
        }

        location ~* \.(jpg|jpeg|png|gif|ico|css|js|mp4|svg|woff|woff2|ttf)$ {
            expires 365d;
        }

        location ~* /(?:uploads|files)/.*.php$ {
            deny all;
        }

        location ~* /*.sql {
            deny all;
        }

        location ~* /.git/* {
            deny all;
        }
        location  ^~ /wp-cron.php {
               allow 127.0.0.1;
        }

        location ~ /\.ht {
                deny all;
        }

        location = /xmlrpc.php {
            deny all;
        }

        location ~ /\. {
            deny all;
        }
    }
eof

cd /etc/nginx/sites-enabled/
ln -s ../sites-available/${domain}.conf

mkdir -p /var/www/${domain}/
chown -R www-data:www-data /var/www/${domain}/
cat << 'eof' >> /var/www/${domain}/index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to EXP!</title>
<style>body {width: 35em; margin: 0 auto; font-family: Tahoma, Verdana, Arial, sans-serif; }</style>
</head>
<body style="background-color:white;">
<h1 style="color:black;">Welcome to EXP!</h1>
</body>
</html>
eof

sed -i "s/DMN/${domain}/g" /etc/nginx/sites-available/${domain}.conf
sed -i "s/EXP/${domain}/g" /var/www/${domain}/index.html

sed -i "17a\\\treal_ip_header X-Forwarded-For;" /etc/nginx/nginx.conf
sed -i "18a\\\tset_real_ip_from 0.0.0.0/0;"  /etc/nginx/nginx.conf
nginx -s reload

cd /root/
touch dm
wget -O ./addomain_into_file.py https://scr.it.cx.ua/addomain_into_file.py && chmod +x ./addomain_into_file.py

echo "
============================================
      Mysql Server Installation
============================================
"

if [ ! -x /usr/bin/mysql ] ; then
        apt install mysql-server -y && systemctl start mysql
fi

echo "============================================================
Please Enter root  password for authorization to mysql db
------------------------------------------------------------"

read -r -p "Do you want to generated automatically ? [y/N] If not it will provide password.  " rootpass
if [[ "$rootpass" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
        db_pass=$(date +%s|sha256sum|base64|head -c 30)
else
        echo "Enter DB ROOT PASSWORD: "
        read -e db_pass

mysql_secure_installation <<EOF
y
y
${db_pass}
${db_pass}
y
y
y
y
EOF
fi;


echo "============================================
      WordPress Install Script
============================================"

authorization="mysql -uroot -p${db_pass}"

dbPassword=$(date +%s|sha256sum|base64|head -c 25)

echo "==============================================
  A robot is now installing WordPress for you.
=============================================="

#Connect to mysql docker container and create database
dbNameandUser=$(echo ${domain} | tr "." "_" | tr "-" "_")
Host=\'%\'

echo "--Reusing credentials----------------------"
$authorization -e "
CREATE USER 'root'@${Host} IDENTIFIED BY '${db_pass}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@${Host} WITH GRANT OPTION;
DROP USER 'root'@'localhost';"

$authorization -e "
DROP USER IF EXISTS ${dbNameandUser}@${Host};
DROP DATABASE IF EXISTS ${dbNameandUser};"

$authorization -e "
CREATE DATABASE ${dbNameandUser};
CREATE USER ${dbNameandUser}@${Host} IDENTIFIED BY '${dbPassword}';
GRANT ALL PRIVILEGES ON ${dbNameandUser}.* TO ${dbNameandUser}@${Host};
FLUSH PRIVILEGES;"
db_pass=${db_pass} >/dev/null 2>/dev/null
db_pass=${db_pass} > /tmp/${db_pass}
wp_admin=root
wp_pass=$(date +%s|sha256sum|base64|head -c 20)

apt-get install curl -y || apk add curl \
&& curl -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod +x /tmp/wp-cli.phar \
&& mv /tmp/wp-cli.phar /usr/local/bin/wp \
&& wp core download --path=/var/www/${domain} --locale=en_US --allow-root \
&& wp config create --path=/var/www/${domain} --dbname=${dbNameandUser} --dbuser=${dbNameandUser} --dbpass=${dbPassword} --dbhost=localhost --allow-root --skip-check \
&& wp core install --skip-email --url=${domain} --title=${domain} --admin_user=${wp_admin} --admin_password=${wp_pass} --admin_email=admin@${domain} --allow-root --path=/var/www/${domain}


chmod 775 -R /var/www/${domain}/
chown www-data:www-data -R /var/www/${domain}
echo "Cleaning...
-----------------------------------------------
  Credentials for Database And for Wp-admin
-----------------------------------------------
INFO
DBRootPass ${db_pass}
DBName: ${dbNameandUser}
DBUser: ${dbNameandUser}
DBPass: ${dbPassword}
Domainame:  http://${domain}/wp-admin/
WPAdmin: ${wp_admin}
WPPass: ${wp_pass}
=================================================
         Installation is complete!
=================================================
Try to connect mysql database:  mysql -h 127.0.0.1 -u root -p${db_pass}"

echo "Cleaning...
-----------------------------------------------
  Credentials for Database And for Wp-admin
-----------------------------------------------
INFO
DBRootPass ${db_pass}
DBName: ${dbNameandUser}
DBUser: ${dbNameandUser}
DBPass: ${dbPassword}
Domainame:  http://${domain}/wp-admin/
WPAdmin: ${wp_admin}
WPPass: ${wp_pass}
=================================================
         Installation is complete!
=================================================
Try to connect mysql database:  mysql -h 127.0.0.1 -u root -p${db_pass}
-----------------------------------------------------------------------------" >> /tmp/credentials.txt

}





#=============================================
#=============================================
function fifth(){
#set -x

echo "============================================
      Please Enter Domain Name:
============================================"
read -e domain

apt update && apt upgrade -y;
apt install -y mc htop curl git wget gnupg gnupg2 nginx
apt-get -y install software-properties-common
apt-get update
add-apt-repository ppa:ondrej/php -y
apt-get update
apt-get -y install \
        php7.4 php7.4-fpm php7.4-mysql php-common php7.4-cli php7.4-common \
        php7.4-json php7.4-opcache php7.4-readline php7.4-imap php7.4-mbstring \
        php7.4-xml php7.4-xmlrpc php7.4-imagick php7.4-dev php7.4-opcache \
        php7.4-soap php7.4-gd php7.4-zip php7.4-intl php7.4-curl

sed -i 's/;cgi.fix_pathinfo=0/  cgi.fix_pathinfo=1/g' /etc/php/7.4/fpm/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 300M/g' /etc/php/7.4/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 300M/g' /etc/php/7.4/fpm/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/7.4/fpm/php.ini
sed -i 's/max_input_time = 60/max_input_time = 600/g' /etc/php/7.4/fpm/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.4/fpm/php.ini
cat << 'eof' >> /etc/php/7.4/fpm/php-fpm.conf

pm = dynamic
        pm.max_children = 97
        pm.start_servers = 20
        pm.min_spare_servers = 10
        pm.max_spare_servers = 20
        pm.max_requests = 200

eof
sudo apt-get -y install certbot
apt install -y python-certbot-nginx || apt-get -y install python3-certbot-nginx
cat << 'eof' >> /etc/nginx/sites-available/${domain}.conf
### Configuration ###
    server {
        listen 80;
        listen [::]:80;
        listen 443;
        listen [::]:443;
        server_name DMN www.DMN;
        root /var/www/DMN;
        index index.php index.html index.htm index.nginx-debian.html;

        proxy_connect_timeout 3600;
        proxy_send_timeout 3600;
        proxy_read_timeout 3600;
        send_timeout 3600;
        client_max_body_size 100M;

        error_page 403 404 /404.html;

        location = /404.html {
            internal; #return 404
        }

        location / {
            try_files $uri $uri/ /index.php$is_args$args;

                allow all;

            allow 000.000.000.000; #EXAMPLE NOT BLOCK
                #deny all;  #Example BLOCK ALL

        }

        location ^~ /(wp-admin|wp-login\.php) {
                allow all;

            allow 000.000.000.000; #EXAMPLE NOT BLOCK
                #deny all;  #Example BLOCK ALL

        }

        location ~ "^\/([a-z0-9]{{28,32}})\.html" {
            add_header Content-Type text/plain;
            return 200 $1;
        }

        location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param REMOTE_ADDR $remote_addr;
            fastcgi_param HTTP_X_FORWARDED_FOR $http_x_forwarded_for;
            fastcgi_param HTTP_X_REAL_IP $http_x_real_ip;
            fastcgi_param HTTP_CF_CONNECTING_IP $http_cf_connecting_ip;
            fastcgi_intercept_errors off;
            fastcgi_buffer_size 16k;
            fastcgi_buffers 4 16k;
            fastcgi_read_timeout 3600;
        }

        location ~* \.(jpg|jpeg|png|gif|ico|css|js|mp4|svg|woff|woff2|ttf)$ {
            expires 365d;
        }

        location ~* /(?:uploads|files)/.*.php$ {
            deny all;
        }

        location ~* /*.sql {
            deny all;
        }

        location ~* /.git/* {
            deny all;
        }
        location  ^~ /wp-cron.php {
               allow 127.0.0.1;
        }

        location ~ /\.ht {
                deny all;
        }

        location = /xmlrpc.php {
            deny all;
        }

        location ~ /\. {
            deny all;
        }
    }
eof

cd /etc/nginx/sites-enabled/
ln -s ../sites-available/${domain}.conf

mkdir -p /var/www/${domain}/
chown -R www-data:www-data /var/www/${domain}/
cat << 'eof' >> /var/www/${domain}/index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to ${domain} !</title>
<style>body {width: 35em; margin: 0 auto; font-family: Tahoma, Verdana, Arial, sans-serif; }</style>
</head>
<body style="background-color:white;">
<h1 style="color:black;">Welcome to ${domain} !</h1>
</body>
</html>
eof

sed -i "s/DMN/${domain}/g" /etc/nginx/sites-available/${domain}.conf
sed -i "s/EXP/${domain}/g" /var/www/${domain}/index.html

sed -i "17a\\\treal_ip_header X-Forwarded-For;" /etc/nginx/nginx.conf
sed -i "18a\\\tset_real_ip_from 0.0.0.0/0;"  /etc/nginx/nginx.conf
nginx -s reload

sed -i "4a\\\tserver_name ${domain} www.${domain};" /etc/nginx/sites-available/${domain}.conf
sed -i "5a\\\treturn 301 https://\$host\$request_uri;" /etc/nginx/sites-available/${domain}.conf
sed -i "6a\\\}" /etc/nginx/sites-available/${domain}.conf
sed -i "7a\\\server {" /etc/nginx/sites-available/${domain}.conf
sed -i "9c\\\tlisten 443 ssl;"  /etc/nginx/sites-available/${domain}.conf
sed -i "10c\\\tlisten [::]:443 ssl;" /etc/nginx/sites-available/${domain}.conf
sed -i "14i\\\tssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem;" /etc/nginx/sites-available/${domain}.conf
sed -i "15i\\\tssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem;" /etc/nginx/sites-available/${domain}.conf
sed -i "16i\\\tssl_protocols   TLSv1 TLSv1.1 TLSv1.2 SSLv3;" /etc/nginx/sites-available/${domain}.conf

certbot --nginx -d ${domain} -d www.${domain} -m brain.devops@gmail.com --non-interactive ###--agree-tos
#sleep 5
nginx -s reload
cd /root/
touch dm
wget -O ./addomain_into_file.py https://scr.it.cx.ua/addomain_into_file.py && chmod +x ./addomain_into_file.py

echo -e "\n ==========    Mysql Server Installation    ==========\n"

if [ ! -x /usr/bin/mysql ] ; then
        apt install mysql-server -y && systemctl start mysql
fi;

echo "============================================================
Please Enter root  password for authorization to mysql db
------------------------------------------------------------"

read -r -p "Do you want to generated automatically ? [y/N] If not it will provide password.  " rootpass
if [[ "$rootpass" =~ ^([yY][eE][sS]|[yY])$ ]] ; then
        db_pass=$(date +%s|sha256sum|base64|head -c 30)
else
        echo "Enter DB ROOT PASSWORD: "
        read -e db_pass

mysql_secure_installation <<EOF
y
y
${db_pass}
${db_pass}
y
y
y
y
EOF
fi

echo "============================================
      WordPress Install Script
============================================"

authorization="mysql -uroot -p${db_pass}"

dbPassword=$(date +%s|sha256sum|base64|head -c 25)

echo "==============================================
  A robot is now installing WordPress for you.
=============================================="

#Connect to mysql docker container and create database
dbNameandUser=$(echo ${domain} | tr "." "_" | tr "-" "_")
Host=\'%\'

echo "--Reusing credentials----------------------"
$authorization -e "
CREATE USER 'root'@${Host} IDENTIFIED BY '${db_pass}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@${Host} WITH GRANT OPTION;
DROP USER 'root'@'localhost';"

$authorization -e "
DROP USER IF EXISTS ${dbNameandUser}@${Host};
DROP DATABASE IF EXISTS ${dbNameandUser};"

$authorization -e "
CREATE DATABASE ${dbNameandUser};
CREATE USER ${dbNameandUser}@${Host} IDENTIFIED BY '${dbPassword}';
GRANT ALL PRIVILEGES ON ${dbNameandUser}.* TO ${dbNameandUser}@${Host};
FLUSH PRIVILEGES;"

db_pass=${db_pass} >/dev/null 2>/dev/null
db_pass=${db_pass} > /tmp/${db_pass}
wp_admin=root
wp_pass=$(date +%s|sha256sum|base64|head -c 20)

apt-get install curl -y || apk add curl \
&& curl -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod +x /tmp/wp-cli.phar \
&& mv /tmp/wp-cli.phar /usr/local/bin/wp \
&& wp core download --path=/var/www/${domain} --locale=en_US --allow-root \
&& wp config create --path=/var/www/${domain} --dbname=${dbNameandUser} --dbuser=${dbNameandUser} --dbpass=${dbPassword} --dbhost=localhost --allow-root --skip-check \
&& wp core install --skip-email --url=${domain} --title=${domain} --admin_user=${wp_admin} --admin_password=${wp_pass} --admin_email=admin@${domain} --allow-root --path=/var/www/${domain}


chmod 775 -R /var/www/${domain}/
chown www-data:www-data -R /var/www/${domain}
echo "Cleaning...
-----------------------------------------------
  Credentials for Database And for Wp-admin
-----------------------------------------------
INFO
DBRootPass ${db_pass}
DBName: ${dbNameandUser}
DBUser: ${dbNameandUser}
DBPass: ${dbPassword}
Domainame:  http://${domain}/wp-admin/
WPAdmin: ${wp_admin}
WPPass: ${wp_pass}
=================================================
         Installation is complete!
=================================================
Try to connect mysql database:  mysql -h 127.0.0.1 -u root -p${db_pass}"

echo "Cleaning...
-----------------------------------------------
  Credentials for Database And for Wp-admin
-----------------------------------------------
INFO
DBRootPass ${db_pass}
DBName: ${dbNameandUser}
DBUser: ${dbNameandUser}
DBPass: ${dbPassword}
Domainame:  http://${domain}/wp-admin/
WPAdmin: ${wp_admin}
WPPass: ${wp_pass}
=================================================
         Installation is complete!
=================================================
Try to connect mysql database:  mysql -h 127.0.0.1 -u root -p${db_pass}
-----------------------------------------------------------------------------" >> /tmp/credentials.txt
}




#=================================================

#-------------------------------------------------
function CheckPack() {

        #WELCOME MESSAGE

clear
echo -e "Welcome to WordPress & LAMP stack installation and configuration wizard!
First of all, we going to check all required packeges..."

        #CHECKING PACKAGES

echo -e "${YELLOW}Checking packages...${NC}"
echo -e "List of required packeges: nano, zip, unzip, mc, htop, fail2ban, apache2 & php, mysql, php curl, phpmyadmin, wget, curl"
read -r -p "Do you want to check packeges? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])

WGET=$(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed")
  if [ "$WGET" -eq 0 ]; then
    echo -e "${YELLOW}Installing wget${NC}" && apt-get install wget --yes;
  elif [ "$WGET" -eq 1 ]; then echo -e "${GREEN}wget is installed!${NC}";
  fi;

CURL=$(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed")
  if [ "$CURL" -eq 0 ]; then
    echo -e "${YELLOW}Installing curl${NC}" && apt-get install curl --yes;
  elif [ "$CURL" -eq 1 ]; then echo -e "${GREEN}curl is installed!${NC}";
  fi;

NANO=$(dpkg-query -W -f='${Status}' nano 2>/dev/null | grep -c "ok installed")
  if [ "$NANO" -eq 0 ]; then
    echo -e "${YELLOW}Installing nano${NC}" && apt-get install nano --yes;
  elif [ "$NANO" -eq 1 ]; then echo -e "${GREEN}nano is installed!${NC}";
  fi;

ZIP=$(dpkg-query -W -f='${Status}' zip 2>/dev/null | grep -c "ok installed")
  if [ "$ZIP" -eq 0 ]; then
    echo -e "${YELLOW}Installing zip${NC}" && apt-get install zip --yes;
  elif [ "$ZIP" -eq 1 ]; then echo -e "${GREEN}zip is installed!${NC}";
  fi;

MC=$(dpkg-query -W -f='${Status}' mc 2>/dev/null | grep -c "ok installed")
  if [ "$MC" -eq 0 ]; then
    echo -e "${YELLOW}Installing mc${NC}" && apt-get install mc --yes;
  elif [ "$MC" -eq 1 ]; then echo -e "${GREEN}mc is installed!${NC}";
  fi;

HTOP=$(dpkg-query -W -f='${Status}' htop 2>/dev/null | grep -c "ok installed")
  if [ "$HTOP" -eq 0 ]; then
    echo -e "${YELLOW}Installing htop${NC}" && apt-get install htop --yes;
  elif [ "$HTOP" -eq 1 ]; then echo -e "${GREEN}htop is installed!${NC}";
  fi;

FAIL2BAN=$(dpkg-query -W -f='${Status}' fail2ban 2>/dev/null | grep -c "ok installed")
  if [ "$FAIL2BAN" -eq 0 ]; then
    echo -e "${YELLOW}Installing fail2ban${NC}" && apt-get install fail2ban --yes;
  elif [ "$FAIL2BAN" -eq 1 ]; then echo -e "${GREEN}fail2ban is installed!${NC}";
  fi;

APACHE2=$(dpkg-query -W -f='${Status}' apache2 2>/dev/null | grep -c "ok installed")
  if [ "$APACHE2" -eq 0 ]; then
    echo -e "${YELLOW}Installing apache2${NC}" && apt-get install apache2 php5 --yes;
  elif [ "$APACHE2" -eq 1 ]; then echo -e "${GREEN}apache2 is installed!${NC}";
  fi;

MYSQLSERVER=$(dpkg-query -W -f='${Status}' mysql-server 2>/dev/null | grep -c "ok installed")
  if [ "$MYSQLSERVER" -eq 0 ]; then
    echo -e "${YELLOW}Installing mysql-server${NC}" && apt-get install mysql-server --yes;
  elif [ "$MYSQLSERVER" -eq 1 ]; then echo -e "${GREEN}mysql-server is installed!${NC}";
  fi;

PHP5CURL=$(dpkg-query -W -f='${Status}' php5-curl 2>/dev/null | grep -c "ok installed")
  if [ "$PHP5CURL" -eq 0 ]; then
    echo -e "${YELLOW}Installing php5-curl${NC}" && apt-get install php5-curl --yes;
  elif [ "$PHP5CURL" -eq 1 ]; then echo -e "${GREEN}php5-curl is installed!${NC}";
  fi;

PHPMYADMIN=$(dpkg-query -W -f='${Status}' phpmyadmin 2>/dev/null | grep -c "ok installed")
  if [ "$PHPMYADMIN" -eq 0 ]; then
    echo -e "${YELLOW}Installing phpmyadmin${NC}" && apt-get install phpmyadmin --yes;
  elif [ "$PHPMYADMIN" -eq 1 ]; then echo -e "${GREEN}phpmyadmin is installed!${NC}";
  fi ;;

    *) echo -e "\n\t ${RED}Packeges check is ignored! \n Please be aware, that apache2, mysql, phpmyadmin and other software may not be installed! ${NC}\n" ;;
        esac
};



#      PHPMYADMIN
#-------------------------------------------------
function ChangingPMA() {
    P_IP="`wget http://ipinfo.io/ip -qO -`"

        echo -e "${YELLOW}Changing phpMyAdmin default path from /phpMyAdmin to /phpmyadmin...${NC}"

sleep 5

# read -r -p "Do you want to change default phpMyAdmin path to /phpmyadmin? [y/N] " response
# case $response in
#     [yY][eE][sS]|[yY])

cat >/etc/phpmyadmin/apache.conf <<EOL
# phpMyAdmin default Apache configuration

Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options FollowSymLinks
    DirectoryIndex index.php

    <IfModule mod_php5.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        php_flag magic_quotes_gpc Off
        php_flag track_vars On
        php_flag register_globals Off
        php_admin_flag allow_url_fopen Off
        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/
    </IfModule>

</Directory>

# Authorize for setup
<Directory /usr/share/phpmyadmin/setup>
    <IfModule mod_authz_core.c>
        <IfModule mod_authn_file.c>
            AuthType Basic
            AuthName "phpMyAdmin Setup"
            AuthUserFile /etc/phpmyadmin/htpasswd.setup
        </IfModule>
        Require valid-user
    </IfModule>
</Directory>

# Disallow web access to directories that don't need it
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>
EOL


        echo -e "\n ${GREEN}Succesfully! phpMyAdmin path is: ${P_IP}/phpmyadmin (i.e.: yourwebsite.com/phpmyadmin)${NC} \n "
    #;;
    #*) echo -e "${RED}Path was not changed!${NC}"
    #;;
   #esac
};




function creatingUser() {

#creating user

echo -e "${YELLOW}Adding separate user & creating website home folder for secure running of your website...${NC}"

  # echo -e "${YELLOW}Please, enter new username: ${NC}"
  # read username
  username="www-data";
  echo -e "${YELLOW}Enter Domain: ${NC}"
  read websitename


  groupadd $username
  adduser --home /var/www/${domain} --ingroup $username $username
  mkdir -p /var/www/${domain}
  chown -R $username:$username /var/www/${domain}
  echo -e "${GREEN}
  #-------------------------------------------------
  User, group and home folder were succesfully created!

  USERNAME:        $username
  GROUP:           $username
  HOME FOLDER:     /var/www/${domain}
  WEBSITE FOLDER:  /var/www/${domain}

  ${NC}"
}





function ConfApache2() {
#configuring apache2
#-------------------------------------------------
echo -e "${YELLOW}Now we going to configure apache2 for your domain name & website root folder...${NC}"

read -r -p "Do you want to configure Apache2 automatically? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])

  echo -e "Please, provide us with your domain name: "
  read domain_name
  echo -e "Please, provide us with your email: "
  read domain_email
  cat >/etc/apache2/sites-available/${domain}.conf <<EOL
  <VirtualHost *:80>
        ServerAdmin $domain_email
        ServerName ${domain}
        ServerAlias www.${domain}
        DocumentRoot /var/www/${domain}/
        <Directory />
                Options +FollowSymLinks
                AllowOverride All
        </Directory>
        <Directory /var/www/${domain}>
                Options -Indexes +FollowSymLinks +MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>

        ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
        <Directory "/usr/lib/cgi-bin">
                AllowOverride None
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                Order allow,deny
                Allow from all
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL
        a2dissite 000-default
    a2ensite ${domain}
    service apache2 restart
    P_IP="`wget http://ipinfo.io/ip -qO -`"

    echo -e "${GREEN}Apache2 config was updated!
    NEW CONFIG FILE:            /etc/apache2/sites-available/${domain}.conf
    DOMAIN WAS SET TO:          ${domain}
    ADMIN EMAIL WAS SET TO:     ${domain_email}
    ROOT FOLDER WAS SET TO:     /var/www/${domain}
    OPTION INDEXES WAS SET TO:  -Indexes (to close directory listing)
    YOUR SERVER PUBLIC IP IS:   $P_IP (Please, set this IP into your domain name 'A' record)
    Website was activated & apache2 service reloaded! ${NC}" \n ;;

    *) echo -e "${RED}WARNING! Apache2 was not configured properly, you can do this manually or re run our script.${NC}" ;;

        esac
}


#-----------------------------------------------------------
#  Downloading WordPress, unPacking,ADDing basic pack of plugins,
# creating .htaccess with optimal & secure configuration
#-----------------------------------------------------------
function InstallWordPress() {

echo "Root password for authorization to mysql DataBase generated automatically"
db_pass=$(date +%s|sha256sum|base64|head -c 30);
mysql_secure_installation <<EOF
y
y
${db_pass}
${db_pass}
y
y
y
y
EOF

#---------------------------------
#   WordPress Install Script
#---------------------------------
echo "Please Enter Domain Name: ";
read -e domain
authorization="mysql -uroot -p${db_pass}"
dbPassword=$(date +%s|sha256sum|base64|head -c 25)
echo "A robot is now installing WordPress for you.";

#set +e
mkdir -p /var/www/${domain} && cd /var/www/${domain}
#Connect to mysql docker container and create database
dbNameandUser=$(echo ${domain} | tr "." "_" | tr "-" "_")
Host=\'%\'

echo "--Reusing credentials----------------------"
$authorization -e "
CREATE USER 'root'@${Host} IDENTIFIED BY '${db_pass}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@${Host} WITH GRANT OPTION;
DROP USER 'root'@'localhost';"

$authorization -e "
DROP USER IF EXISTS ${dbNameandUser}@${Host};
DROP DATABASE IF EXISTS ${dbNameandUser};"

$authorization -e "
CREATE DATABASE ${dbNameandUser};
CREATE USER ${dbNameandUser}@${Host} IDENTIFIED BY '${dbPassword}';
GRANT ALL PRIVILEGES ON ${dbNameandUser}.* TO ${dbNameandUser}@${Host};
FLUSH PRIVILEGES;"
db_pass=${db_pass} >/dev/null 2>/dev/null
db_pass=${db_pass} > /tmp/${db_pass}
wp_admin=root
wp_pass=$(date +%s|sha256sum|base64|head -c 20)

apt-get install curl -y || apk add curl
curl -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        && chmod +x /tmp/wp-cli.phar \
        && mv /tmp/wp-cli.phar /usr/local/bin/wp
wp core download \
   --path=/var/www/${domain} --locale=en_US --allow-root
wp config create \
    --path=/var/www/${domain} --dbname=${dbNameandUser} --dbuser=${dbNameandUser} --dbpass=${dbPassword} --dbhost=localhost --allow-root --skip-check
wp core install \
    --skip-email --url=${domain} --title=${domain} --admin_user=${wp_admin} --admin_password=${wp_pass} --admin_email=admin@${domain} --allow-root --path=/var/www/${domain}

echo -e "
Now we going to download some useful plugins:
1. Google XML Sitemap generator
2. Social Networks Auto Poster
3. Add to Any
4. Easy Watermark
";
sleep 7

# installing plugin:
wp plugin install \
    wp-sitemap-page add-to-any easy-watermark social-networks-auto-poster-facebook-twitter-g
# activating plugin:
wp plugin activate \
    wp-sitemap-page add-to-any easy-watermark social-networks-auto-poster-facebook-twitter-g


###mkdir -p /var/www/${domain}/wp-content/uploads
chmod 775 -R /var/www/${domain}/ ###wp-content/uploads
chown www-data:www-data -R /var/www/${domain}

# installing plugin:
wp plugin install woocommerce

# activating the plugin:
wp plugin activate woocommerce


echo -e "
Cleaning... \n

-----------------------------------------------
         Installation is complete!
-----------------------------------------------


=================================================
  Credentials for Database And for Wp-admin
=================================================
INFO
DataBase Root Password:     ${db_pass}
DataBase Name:              ${dbNameandUser}
DataBase User:              ${dbNameandUser}
DataBase Pass:              ${dbPassword}
-----------------------------------------------
Admin Panel Link:           http://${domain}/wp-admin/
Admin Panel Admin:          ${wp_admin}
Admin Panel Password:       ${wp_pass}

Try to connect mysql database:  mysql -h 127.0.0.1 -u root -p${db_pass}
=================================================
"

echo "
=================================================
  Credentials for Database And for Wp-admin
=================================================

DataBase Root Password:     ${db_pass}
DataBase Name:              ${dbNameandUser}
DataBase User:              ${dbNameandUser}
DataBase Pass:              ${dbPassword}
-----------------------------------------------

Admin Panel Link:           http://${domain}/wp-admin/
Admin Panel Admin:          ${wp_admin}
Admin Panel Password:       ${wp_pass}

-----------------------------------------------
" >> /tmp/credentials.txt


}



function downWP() {

echo -e "${YELLOW}Download LATEST VERSION of WordPress with EN or RUS language, set optimal & secure configuration and add basic set of plugins...${NC}"
read -r -p "Do you want to install WordPress & automatically set optimal and secure configuration with basic set of plugins? [y/N] " response

case $response in
    [yY][eE][sS]|[yY])
  echo -e "${GREEN}Please, choose WordPress language you need (set RUS or ENG): "
  read wordpress_lang

  if [ "$wordpress_lang" == 'RUS' ]; then
    wget https://ru.wordpress.org/latest-ru_RU.zip -O /tmp/$wordpress_lang.zip
  else
    wget https://wordpress.org/latest.zip -O /tmp/$wordpress_lang.zip
  fi;

  echo -e "Unpacking WordPress into website home directory..."
  sleep 5
  unzip /tmp/$wordpress_lang.zip -d /var/www/${domain}/
  mv /var/www/${domain}/wordpress/* /var/www/${domain}
  rm -rf /var/www/${domain}/wordpress
  rm /tmp/$wordpress_lang.zip
  mkdir -p /var/www/${domain}/wp-content/uploads && \
    chmod -R 777 /var/www/${domain}/wp-content/uploads



  echo -e "Now we going to download some useful plugins:
  1. Google XML Sitemap generator
  2. Social Networks Auto Poster
  3. Add to Any
  4. Easy Watermark"
  sleep 7

  #SITEMAP="`curl https://wordpress.org/plugins/google-sitemap-generator/ | grep https://downloads.wordpress.org/plugin/google-sitemap-generator.*.*.*.zip | awk '{print $2}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
  SITEMAP="`curl https://wordpress.org/plugins/wp-sitemap-page/ | grep https://downloads.wordpress.org/plugin/wp-sitemap-page.*.*.*.zip | awk '{print $2}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
  wget $SITEMAP -O /tmp/sitemap.zip
  unzip /tmp/sitemap.zip -d /tmp/sitemap
  mv /tmp/sitemap/* /var/www/${domain}/wp-content/plugins/

  SNAP="`curl https://wordpress.org/plugins/social-networks-auto-poster-facebook-twitter-g/ | grep https://downloads.wordpress.org/plugin/social-networks-auto-poster-facebook-twitter-g.*.*.*.zip | awk '{print $2}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
  wget $SNAP -O /tmp/snap.zip
  unzip /tmp/snap.zip -d /tmp/snap
  mv /tmp/snap/* /var/www/${domain}/wp-content/plugins/

  ADDTOANY="`curl https://wordpress.org/plugins/add-to-any/ | grep https://downloads.wordpress.org/plugin/add-to-any.*.*.zip | awk '{print $2}' | sed -ne 's/.*\(http[^"]*.zip\).*/\1/p'`"
  wget $ADDTOANY -O /tmp/addtoany.zip
  unzip /tmp/addtoany.zip -d /tmp/addtoany
  mv /tmp/addtoany/* /var/www/${domain}/wp-content/plugins/

        WATERMARK="`curl https://wordpress.org/plugins/easy-watermark/ | grep https://downloads.wordpress.org/plugin/easy-watermark.*.*.*.zip | awk '{print $2}' | sed -ne 's/.*\(http[^\"]*.zip\).*/\1/p'`"
        if [ -z "$WATERMARK" ]; then
                echo "is ERROR";
        else
                echo "$WATERMARK"
                wget $WATERMARK -O /tmp/watermark.zip
                unzip /tmp/watermark.zip -d /tmp/watermark
                mv /tmp/watermark/* /var/www/${domain}/wp-content/plugins/
        fi;

  rm /tmp/sitemap.zip /tmp/snap.zip /tmp/addtoany.zip /tmp/watermark.zip
  rm -rf /tmp/sitemap/ /tmp/snap/ /tmp/addtoany/ /tmp/watermark/

  echo -e "Downloading of plugins finished! All plugins were transfered into /wp-content/plugins directory.${NC}"

        ;;
    *)
  echo -e "${RED}WordPress and plugins were not downloaded & installed. You can do this manually or re run this script.${NC}"

        ;;
esac
}


#creating of swap
#-------------------------------------------------
function CreatSWAP() {

echo -e "On next step we going to create SWAP (it should be your RAM x2)..."
read -r -p "Do you need SWAP? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])
  RAM="`free -m | grep Mem | awk '{print $2}'`"
  swap_allowed=$(($RAM * 2))
  swap=$swap_allowed"M"
  fallocate -l $swap /var/swap.img
  chmod 600 /var/swap.img
  mkswap /var/swap.img
  swapon /var/swap.img

  echo -e "
  ${GREEN}RAM detected: $RAM
  Swap was created: $swap${NC}"
  sleep 5
        ;;
    *)
  echo -e "${RED}You didn't create any swap for faster system working. You can do this manually or re run this script.${NC}"
        ;;
esac
}





function creSECURE() {

#creation of secure .htaccess
echo -e "${YELLOW}Creation of secure .htaccess file...${NC}"
sleep 3
cat >/var/www/${domain}/.htaccess <<EOL
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]

RewriteCond %{query_string} concat.*\( [NC,OR]
RewriteCond %{query_string} union.*select.*\( [NC,OR]
RewriteCond %{query_string} union.*all.*select [NC]
RewriteRule ^(.*)$ index.php [F,L]

RewriteCond %{QUERY_STRING} base64_encode[^(]*\([^)]*\) [OR]
RewriteCond %{QUERY_STRING} (<|%3C)([^s]*s)+cript.*(>|%3E) [NC,OR]
</IfModule>

<Files .htaccess>
Order Allow,Deny
Deny from all
</Files>

<Files wp-config.php>
Order Allow,Deny
Deny from all
</Files>

<Files wp-config-sample.php>
Order Allow,Deny
Deny from all
</Files>

<Files readme.html>
Order Allow,Deny
Deny from all
</Files>

<Files xmlrpc.php>
Order allow,deny
Deny from all
</files>

# Gzip
<ifModule mod_deflate.c>
AddOutputFilterByType DEFLATE text/text text/html text/plain text/xml text/css application/x-javascript application/javascript text/javascript
</ifModule>

Options +FollowSymLinks -Indexes

EOL

chmod 644 /var/www/${domain}/.htaccess
echo -e "${GREEN}.htaccess file was succesfully created!${NC}"


#cration of robots.txt
echo -e "${YELLOW}Creation of robots.txt file...${NC}"
sleep 3
cat >/var/www/${domain}/robots.txt <<EOL
User-agent: *
Disallow: /cgi-bin
Disallow: /wp-admin/
Disallow: /wp-includes/
Disallow: /wp-content/
Disallow: /wp-content/plugins/
Disallow: /wp-content/themes/
Disallow: /trackback
Disallow: */trackback
Disallow: */*/trackback
Disallow: */*/feed/*/
Disallow: */feed
Disallow: /*?*
Disallow: /tag
Disallow: /?author=*
EOL

echo -e "${GREEN}File robots.txt was succesfully created!
Setting correct rights on user's home directory and 755 rights on robots.txt${NC}"
sleep 3
chmod 755 /var/www/${domain}/robots.txt
echo -e "${GREEN}Configuring fail2ban...${NC}"
sleep 3
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf-old
cat >/etc/fail2ban/jail.conf <<EOL
[DEFAULT]

ignoreip = 127.0.0.1/8
ignorecommand =
bantime  = 1200
findtime = 1200
maxretry = 3
backend = auto
usedns = warn
destemail = $domain_email
sendername = Fail2Ban
sender = fail2ban@localhost
banaction = iptables-multiport
mta = sendmail

# Default protocol
protocol = tcp
# Specify chain where jumps would need to be added in iptables-* actions
chain = INPUT
# ban & send an e-mail with whois report to the destemail.
action_mw = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
              %(mta)s-whois[name=%(__name__)s, dest="%(destemail)s", protocol="%(protocol)s", chain="%(chain)s", sendername="%(sendername)s"]
action = %(action_mw)s

[ssh]
enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 5

[ssh-ddos]
enabled  = true
port     = ssh
filter   = sshd-ddos
logpath  = /var/log/auth.log
maxretry = 5

[apache-overflows]
enabled  = true
port     = http,https
filter   = apache-overflows
logpath  = /var/log/apache*/*error.log
maxretry = 5
EOL

service fail2ban restart
echo -e "${GREEN}
fail2ban configuration finished!
fail2ban service was restarted, default confige backuped at /etc/fail2ban/jail.conf-old
Jails were set for: ssh bruteforce, ssh ddos, apache overflows${NC}"
sleep 5
echo -e "${GREEN} Configuring apache2 prefork & worker modules...${NC}"
sleep 3
cat >/etc/apache2/mods-available/mpm_prefork.conf <<EOL
<IfModule mpm_prefork_module>
        StartServers                     1
        MinSpareServers           1
        MaxSpareServers          3
        MaxRequestWorkers         10
        MaxConnectionsPerChild   3000
</IfModule>
EOL

cat > /etc/apache2/mods-available/mpm_worker.conf <<EOL
<IfModule mpm_worker_module>
        StartServers                     1
        MinSpareThreads          5
        MaxSpareThreads          15
        ThreadLimit                      25
        ThreadsPerChild          5
        MaxRequestWorkers         25
        MaxConnectionsPerChild   200
</IfModule>
EOL

a2dismod status
echo -e "${GREEN}Configuration of apache mods was succesfully finished!
Restarting Apache & MySQL services...${NC}"
service apache2 restart
service mysql restart
echo -e "${GREEN}Services succesfully restarted!${NC}"
sleep 3
}




function AddingDB() {
echo -e "${GREEN}Adding user & database for WordPress, setting wp-config.php...${NC}"
echo -e "Please, set username for database: "
read db_user
echo -e "Please, set password for database user: "
read db_pass

mysql -u root -p <<EOF
CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';
CREATE DATABASE IF NOT EXISTS $db_user;
GRANT ALL PRIVILEGES ON $db_user.* TO '$db_user'@'localhost';
ALTER DATABASE $db_user CHARACTER SET utf8 COLLATE utf8_general_ci;
EOF

cat >/var/www/${domain}/wp-config.php <<EOL
<?php

define('DB_NAME', '$db_user');

define('DB_USER', '$db_user');

define('DB_PASSWORD', '$db_pass');

define('DB_HOST', 'localhost');

define('DB_CHARSET', 'utf8');

define('DB_COLLATE', '');

define('AUTH_KEY',         '$db_user');
define('SECURE_AUTH_KEY',  '$db_user');
define('LOGGED_IN_KEY',    '$db_user');
define('NONCE_KEY',        '$db_user');
define('AUTH_SALT',        '$db_user');
define('SECURE_AUTH_SALT', '$db_user');
define('LOGGED_IN_SALT',   '$db_user');
define('NONCE_SALT',       '$db_user');

\$table_prefix  = 'wp_';

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
        define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOL
        chown -R $username:$username /var/www/$username
        echo -e "${GREEN}Database user, database and wp-config.php were succesfully created & configured!${NC}"
        sleep 3
}

function installLAMP() {
  CheckPack;
  ChangingPMA;
  creatingUser;
  ConfApache2;
  InstallWordPress
  #downWP;
  CreatSWAP;
  creSECURE;
  AddingDB;
  echo -e "Installation & configuration succesfully finished.";
  sleep 3
}


#=================================
#         OwnCloud
#=================================
function OWNCLOUD() {

# ------------------------------
#         VAR FUNCTION
# ------------------------------

function wait() { echo -e -n "${YELLOW}Press [ANY] key to continue...${NC}\n"; read -s -n 1; }
function pause() { read -p "Press [Enter] key to continue..." fackEnterKey; }
function myip() {
  ipH=$(hostname -I|cut -f1 -d ' ');
  ipW="$(echo $(curl -s -4 icanhazip.com))";
  ipE="$(ip addr show eth0 |grep inet |awk '{ print $2; }' |sed 's/\/.*$//' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' )";
  if [ "$ipE" == "$ipW" ]; then myip="$ipE"; elif [ "$ipH" == "$ipW" ]; then  myip="$ipH"; else myip="$ipW"; fi; echo "${myip}";
}

myip=$(hostname -I|cut -f1 -d ' ')

#--------------------------------------
#      OwnCloud Ubuntu 18
#--------------------------------------
function OwnCloud_V18() {

# Preparation
# ----------------------
FILE="/usr/local/bin/occ"
/bin/cat <<EOM >$FILE
#! /bin/bash

cd /var/www/owncloud
sudo -u www-data /usr/bin/php /var/www/owncloud/occ "\$@"
EOM


chmod +x /usr/local/bin/occ
Install the Required Packages
apt install -y \
    apache2 \
    libapache2-mod-php \
    mariadb-server \
    openssl \
    php-imagick php-common php-curl \
    php-gd php-imap php-intl \
    php-json php-mbstring php-mysql \
    php-ssh2 php-xml php-zip \
    php-apcu php-redis redis-server \
    wget

# ----------------------
apt install -y \
    ssh bzip2 sudo cron rsync curl jq \
    inetutils-ping smbclient php-libsmbclient \
    php-smbclient coreutils php-ldap

# Change the Document Root
sed -i "s#html#owncloud#" /etc/apache2/sites-available/000-default.conf

service apache2 restart

FILE="/etc/apache2/sites-available/owncloud.conf"
/bin/cat <<EOM >$FILE
Alias /owncloud "/var/www/owncloud/"

<Directory /var/www/owncloud/>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/owncloud
 SetEnv HTTP_HOME /var/www/owncloud
</Directory>
EOM

a2ensite owncloud.conf
service apache2 reload


#  Passwords
dbPASS="$(</dev/urandom tr -dc 'A-Za-z0-9%&?@' |head -c 22 )"
dbNAME="owncloud"
dbUSER="owncloud"
adminUSER="admin"
adminPASS="$(</dev/urandom tr -dc 'A-Za-z0-9%&?@' |head -c 12 )"
# ----------------------------
mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${dbNAME}; \
    GRANT ALL PRIVILEGES ON ${dbNAME}.* \
    TO ${dbUSER}@localhost \
    IDENTIFIED BY '${dbPASS}'";
# ----------------------
echo "Enabling Apache Modules"

a2enmod dir env headers mime rewrite setenvif
service apache2 reload
cd /var/www/
wget https://download.owncloud.org/community/owncloud-10.8.0.tar.bz2 && \
    tar -xjf owncloud-10.8.0.tar.bz2 && \
    chown -R www-data. owncloud
# ----------------------------
occ maintenance:install \
    --database "mysql" \
    --database-name "${dbNAME}" \
    --database-user "${dbUSER}" \
    --database-pass "${dbPASS}" \
    --admin-user "${adminUSER}" \
    --admin-pass "${adminPASS}"

#occ config:system:get trusted_domains
#occ config:system:set trusted_domains 1 --value="$myip"
occ config:system:set trusted_domains 2 --value="$mydomain"

# ----------------------
occ background:cron
echo "*/15  *  *  *  * /var/www/owncloud/occ system:cron" \
    > /var/spool/cron/crontabs/www-data
chown www-data.crontab /var/spool/cron/crontabs/www-data && chmod 0600 /var/spool/cron/crontabs/www-data

# ----------------------
echo "*/15 * * * * /var/www/owncloud/occ user:sync 'OCA\User_LDAP\User_Proxy' -m disable -vvv >> /var/log/ldap-sync/user-sync.log 2>&1" > /var/spool/cron/crontabs/www-data
chown www-data.crontab  /var/spool/cron/crontabs/www-data && chmod 0600  /var/spool/cron/crontabs/www-data
mkdir -p /var/log/ldap-sync && touch /var/log/ldap-sync/user-sync.log && chown www-data. /var/log/ldap-sync/user-sync.log

# ----------------------
occ config:system:set \
   memcache.local \
   --value '\OC\Memcache\APCu'

occ config:system:set \
   memcache.locking \
   --value '\OC\Memcache\Redis'

service redis-server start

occ config:system:set \
   redis \
   --value '{"host": "127.0.0.1", "port": "6379"}' \
   --type json

# ----------------------
FILE="/etc/logrotate.d/owncloud"
sudo /bin/cat <<EOM >$FILE
/var/www/owncloud/data/owncloud.log {
  size 10M
  rotate 12
  copytruncate
  missingok
  compress
  compresscmd /bin/gzip
}
EOM
# ----------------------------
cd /var/www/ 
chown -R www-data. owncloud

# ----------------------------
touch "$HOME/.owncloud-profile.txt"
echo -en "
========   DATABASE  ========
- OwnCloud site: ${mydomain}
- DATABASE PASS: ${dbPASS}
- DATABASE USER: ${dbUSER}
- DATABASE NAME: ${dbNAME}
========     USER    ========
- Admin USER: ${adminUSER}
- Admin PASS: ${adminPASS}
=============================
" >> "$HOME/.owncloud-profile.txt"
# ----------------------------

echo -en "ownCloud is now installed."
echo -en "Use web browser to your ownCloud installation."
# ----------------------------
cat "$HOME/.owncloud-profile.txt"
read -p "Press [Enter] key to continue..." fackEnterKey;

}; 




#--------------------------------------
#      Owncloud Ubuntu 20
#--------------------------------------
function OwnCloud_V20() {
# ----------------------------
FILE="/usr/local/bin/occ"
/bin/cat <<EOM >$FILE
#! /bin/bash
cd /var/www/owncloud
sudo -E -u www-data /usr/bin/php /var/www/owncloud/occ "\$@"
EOM
chmod +x /usr/local/bin/occ
# ----------------------------
apt install -y \
  apache2 wget openssl \
  libapache2-mod-php \
  mariadb-server \
  php-imagick php-common php-curl php-gd php-imap php-intl \
  php-json php-mbstring php-mysql php-ssh2 php-xml php-zip \
  php-apcu php-redis redis-server \
  
# ----------------------------
apt install -y ssh bzip2 rsync curl jq inetutils-ping coreutils


# ============================
#    Installation
echo "Installation"
sleep 3
# ----------------------------
sed -i "s#html#owncloud#" /etc/apache2/sites-available/000-default.conf
service apache2 restart
# ----------------------------
FILE="/etc/apache2/sites-available/owncloud.conf"
/bin/cat <<EOM >$FILE
Alias /owncloud "/var/www/owncloud/"

<Directory /var/www/owncloud/>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/owncloud
 SetEnv HTTP_HOME /var/www/owncloud
</Directory>
EOM
a2ensite owncloud.conf
service apache2 reload

# ============================
#  Passwords
# ============================
dbPASS="$(</dev/urandom tr -dc 'A-Za-z0-9%&?@' |head -c 22 )"
dbNAME="owncloud"
dbUSER="owncloud"
adminUSER="admin"
adminPASS="$(</dev/urandom tr -dc 'A-Za-z0-9%&?@' |head -c 12 )"
# ----------------------------
mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${dbNAME}; \
GRANT ALL PRIVILEGES ON ${dbNAME}.* \
  TO ${dbUSER}@localhost \
  IDENTIFIED BY '${dbPASS}'";
# ----------------------------
echo "Enabling Apache Modules"
a2enmod dir env headers mime rewrite setenvif
service apache2 reload
# ----------------------------
cd /var/www/
wget https://download.owncloud.org/community/owncloud-10.8.0.tar.bz2 && \
tar -xjf owncloud-10.8.0.tar.bz2 && \
chown -R www-data. owncloud

# ================================
#    Install ownCloud
# ================================
echo "Installation OwnCloud"
sleep 3
# ----------------------------
occ maintenance:install \
    --database "mysql" \
    --database-name "${dbNAME}" \
    --database-user "${dbUSER}" \
    --database-pass "${dbPASS}" \
    --admin-user "${adminUSER}" \
    --admin-pass "${adminPASS}"


occ config:system:get trusted_domains
occ config:system:set trusted_domains 1 --value="$myip"
occ config:system:set trusted_domains 2 --value="$mydomain"
occ config:system:get trusted_domains

# ================================
# sudo -u www-data php occ config:system:set trusted_domains 2 --value="$mydomain"
#sudo nano /etc/apache2/sites-available/000-default.conf

#ServerName cloud.example.com

#ServerAdmin webmaster@localhost
#DocumentRoot /var/www/owncloud/

#ErrorLog ${APACHE_LOG_DIR}/error.log
#CustomLog ${APACHE_LOG_DIR}/access.log combined
# ================================

# ----------------------------
occ background:cron
echo "*/15  *  *  *  * /var/www/owncloud/occ system:cron" \
  > /var/spool/cron/crontabs/www-data
chown www-data.crontab /var/spool/cron/crontabs/www-data
chmod 0600 /var/spool/cron/crontabs/www-data
# ----------------------------
echo "
# ==================   NOTE   ================== #
- Если нужно синхронизировать пользователей с LDAP или 
  Active Directory Server добавьте это дополнительное задание Cron.
- Каждые 15 минут это задание cron будет синхронизировать пользов. 
  LDAP в ownCloud и откл. тех, которые недоступны для ownCloud. 
- Кроме того, получаете файл журнала отладки /var/log/ldap-sync/user-sync.log
# ================================================ #
"
# ----------------------------
echo "*/15 * * * * /var/www/owncloud/occ user:sync 'OCA\User_LDAP\User_Proxy' -m disable -vvv >> /var/log/ldap-sync/user-sync.log 2>&1" >> /var/spool/cron/crontabs/www-data
chown www-data.crontab  /var/spool/cron/crontabs/www-data
chmod 0600  /var/spool/cron/crontabs/www-data
mkdir -p /var/log/ldap-sync
touch /var/log/ldap-sync/user-sync.log
chown www-data. /var/log/ldap-sync/user-sync.log
# ----------------------------
occ config:system:set \
   memcache.local \
   --value '\OC\Memcache\APCu'
occ config:system:set \
   memcache.locking \
   --value '\OC\Memcache\Redis'
occ config:system:set \
   redis \
   --value '{"host": "127.0.0.1", "port": "6379"}' \
   --type json
# ----------------------------
FILE="/etc/logrotate.d/owncloud"
sudo /bin/cat <<EOM >$FILE
/var/www/owncloud/data/owncloud.log {
  size 10M
  rotate 12
  copytruncate
  missingok
  compress
  compresscmd /bin/gzip
}
EOM
# ----------------------------
  cd /var/www/
  mkdir -p /var/www/owncloud && chown -R www-data. owncloud

# ----------------------------
  touch "$HOME/.owncloud-profile.txt"
  echo -en "
========   DATABASE  ========
- OwnCloud site: ${mydomain}
- DATABASE PASS: ${dbPASS}
- DATABASE USER: ${dbUSER}
- DATABASE NAME: ${dbNAME}
========     USER    ========
- Admin USER: ${adminUSER}
- Admin PASS: ${adminPASS}
=============================
" >> "$HOME/.owncloud-profile.txt"
# ----------------------------

    echo -en "ownCloud is now installed."
    echo -en "Use web browser to your ownCloud installation."
    # ----------------------------
    cat "$HOME/.owncloud-profile.txt"
    read -p "Press [Enter] key to continue..." fackEnterKey;

}


# OwnCloud START Installation
#----------------------------------------
echo "Start Install ownCloud "
read -p "Domain Name (eg. example.com): " mydomain
sleep 3
apt update && apt upgrade -y
sleep 3

  OS="$( cat /etc/*release |grep '^ID=' |sed 's/"//g' |awk -F= '{print $2 }' )";
  release="$( cat /etc/*release |grep '^VERSION_ID=' |sed  's/"//g' |awk -F= '{print $2 }' )";
  
  if [[ "${OS}" == 'ubuntu' ]] && [[ "${release:0:2}" == 20 ]]; then
    echo "Install OwnCloud for Ubuntu 20"
    OwnCloud_V${release:0:2}
  elif [[ "${OS}" == 'ubuntu' ]] && [[ "${release:0:2}" == 18 ]]; then
    echo "Install OwnCloud for Ubuntu 18"
    OwnCloud_V${release:0:2}
  else
    echo -en "\n ${RED} Not install OwnCloud.\n\n OS: ${OS}\n\n RELEASE: ${release} \n Run new installation script ${NC}\n"
  fi;

}



# =============================
#      Pure-FTP
#==============================
function PUREFTP_RUN() {
clear
echo -e "${GREEN}Welcome to Pure-FTP Auto Installer Script${NC}"
echo ""

if [ "$(whoami)" != "root" ]; then
  echo -e "${RED}This script must be run as root${NC}"
  sleep 5
  exit
fi

# =============================
#          Var & Func
# =============================

function PUREFTP_AddNewUser() {
          read -p "Enter a Username: " -e ADDUSERNAME
          read -p "Enter $ADDUSERNAME’s password: " -e ADDPASSWORD
          read -p "Enter $ADDUSERNAME’s directory: " -e -i /home/$ADDUSERNAME ADDUSERDIR
          read -p "Is this an http user? [y/n]: " -e HTTP
          echo ""
          echo "${GREEN}The User is creating now... Please wait."
          echo ""
          if [ "$HTTP" = "y" ]; then
            echo -e "$ADDPASSWORD\\n$ADDPASSWORD" | pure-pw useradd $ADDUSERNAME -u www-data -d $ADDUSERDIR
          else
            if [ "$HTTP" = "n" ]; then
              echo -e "$ADDPASSWORD\\n$ADDPASSWORD" | pure-pw useradd $ADDUSERNAME -u $ADDUSERNAME -d $ADDUSERDIR
            else
              echo "${YELOW}Please enter [y/n] ...${NC}"
              #exit
            fi
          fi
          pure-pw mkdb
          if [ -e /etc/init.d/pure-ftpd ]; then
            /etc/init.d/pure-ftpd restart
          else
            echo "${RED}Pure-FTP is not working properly. Please remove and Re-install it.${NC}"
            exit
          fi
};

function PUREFTP_ChangeUserPass() {
          read -p "Enter the username: " -e CHNUSERNAME
          read -p "Enter password: " -e CHNPASSWORD
          echo -e "$CHNPASSWORD\\n$CHNPASSWORD" | pure-pw passwd $CHNUSERNAME -m
          pure-pw mkdb
}

function PUREFTP_DelUser() {
    read -p "Enter the username: " -e DELUSERNAME
          read -p "Are you sure? [y/n]: " -e -i n TTT
          if [ "$TTT" = "y" ]; then
            pure-pw userdel $DELUSERNAME -m
            pure-pw mkdb
          else
            echo "Closing now.."
            exit
          fi
}

function PUREFTP_Remove() {
    read -p "Are you sure? [y/n]: " -e -i n TTTT
          if [ "$TTTT" = "y" ]; then
            apt-get remove —purge —yes pure-ftpd
            apt-get —yes autoremove
          if [ -e /etc/pure-ftpd ]; then
            rm -rf /etc/pure-ftpd
          fi
          else
            echo "Closing now.." && exit
          fi
}
function PUREFTP_Install() {
      apt-get update -y && apt-get upgrade -y
      apt-get install pure-ftpd -y
      IP=$(curl ip.mtak.nl -4)
      cd /etc/pure-ftpd/conf
      touch ForcePassiveIP
      touch PassivePortRange
      echo -e "$IP" | tee -a /etc/pure-ftpd/conf/ForcePassiveIP
      echo -e "10110 10210" | tee -a /etc/pure-ftpd/conf/PassivePortRange
      perl -pi -e "s/1000/1/g" /etc/pure-ftpd/conf/MinUID
      perl -pi -e "s/yes/no/g" /etc/pure-ftpd/conf/PAMAuthentication
      ln -s /etc/pure-ftpd/conf/PureDB /etc/pure-ftpd/auth/50pure
}

function PUREFTP_mainMENU() {

echo -en "${GREEN}\nPure-FTP IS already INSTALLED.\n${NC}"
echo ""
echo -en "\n1) ${YELOW}Add a new user${NC}"
echo -en "\n2) ${YELOW}Change a user password${NC}"
echo -en "\n3) ${RED}Delete a user${NC}"
echo -en "\n4) ${PURPLE}Remove Pure-FTP and configurations${NC}"
echo -en "\n5) ${RED}Exit... ${NC}"
echo -en "\n\n${BLUE} Select an Option: ${NC}"
};



function PUREFTP_Option() {
  if [ -e /etc/pure-ftpd ]; then
    while :
    do
      PUREFTP_mainMENU
      read option
      case $option in
      
        1) # ADD NEW USER
         PUREFTP_AddNewUser; exit ;;
        2) #Change a user password
         PUREFTP_ChangeUserPass; exit ;;
        3) #Delete a user
         PUREFTP_DelUser; exit ;;
        4) # Remove Pure-FTP
          PUREFTP_Remove; exit ;;
        0) exit ;;

      esac
    done;

  else
   echo -e "\n\t {RED}Pure-FTP is not installed.{NC}\n"
   read -p "Install now Pure-FTP..? [y/n]: " -e -i y TT

    if [ "$TT" = "y" ]; then
     PUREFTP_Install;
    else
      echo -e "${YELOW}Closing now..${NC}";
      sleep 5 && exit;
    fi;

    echo -e "\n${GREEN}Pure-FTP is installed. Please Re-open this script for create user.\n Closing now.. ${NC}\n"
    sleep 5 && exit;
  fi;
}

if [ -e /etc/debian_version ]; then
  PUREFTP_Option
else
  echo -e "${YELOW}This script must be run on Debian or Ubuntu.${NC}"
  exit
fi;

echo -e "${GREEN}End installation${NC}"

};



# =============================




# =============================
function MAIN() {

#==============================
#           MENU
#==============================
function MAINMENU() {
    clear;
    echo -e -n "\n\t${GREEN}${BGBlack}==== MAIN MENU ====${NC}\n"
    echo -e -n "${Yellow}
\t1. Create SSH key     ${NC} ${Purple}
\t2. Install LEMP       ${NC} ${BLUE}
\t3. Install LAMP       ${NC} ${Yellow}
\t4. Control Panel      ${NC} ${RED}
\n\tq. Quit...          ${NC}";

}

#   Menu SSH
function MenuSSH() {
title="Generate Key SSH";
echo -e -n "\n\t${GREEN}SSH KeyGen:${NC}\n"
echo -e -n "
\t1. $title ${GREEN} ED25519       ${NC}
\t2. $title ${Yellow} RSA          ${NC}
\t3. $title ${CYAN}2 RSA [PEM]     ${NC}
\t4. $title ${BLUE} DSA            ${NC}
\t5. $title ${Purple} ECDSA        ${NC}
\t6. $title ${RED} EdDSA - [OFF]   ${NC}${RED}
\n\t0. Back ${NC}\n";

}

##   LEMP MENU 
function MenuLEMP() {
echo -e -n "\n\t ${GREEN}LEMP installation & Settings:${NC} \n"
echo -e -n "\t1. Install Mysql-Server ${CYAN}With WordPress LAND ${NC}"
echo -e -n "\t2. Add one more WordPress LAND ${CYAN}With New user ${NC}"
echo -e -n "\t3. PreInstall ${CYAN} Ngx Php7.4 Certbot ${NC}"
echo -e -n "\t4. Install WordPress ${CYAN} With All Services Cloudflare ${NC}"
echo -e -n "\t5. Instal WordPress ${CYAN} With All Services Certbot ${NC} ${RED}"
echo -e -n "\n\tq/0. Back ${NC}\n";
}

##   MENU 3: LAMP
function MenuLAMP() {
    echo -e "\n\t ${GREEN}LAMP installation & Settings:${NC} \n"
    echo -e -n "${Yellow}";
    echo -e -n "\t1. Install LAMP & WordPress";
    echo -e -n "\t${BLUE}(Apache, php7.4, phpMyAdmin) ${RED} \n";
    echo -e -n "\n\t0. Back ${NC}\n";
    echo -e -n "";
}; 
#MenuLAMP

##   MENU 4: Web Control Panel
function MenuCPanel() {
    echo -e "\n\t ${GREEN}Menu 4: CONTROL PANEL ${Yellow} \n";
    echo -e "\t1. Install OwnCloud       ${PURPLE} ";
    echo -e "\t2. FREE                            ${PURPLE} ";
    echo -e "\t3. FREE                            ${PURPLE} ";
    echo -e "\t4. FREE                            ${RED} ";

PUREFTP_RUN
    echo -e "\n\t0. Back                          ${NC}\n ";
};

##   MENU 8: Modules & Components
function MenuMODandCOMPON() {
    echo -e "\n\t ${GREEN}Menu 8: Modules & Components ${Yellow} \n";
    echo -e "\t1. Install Pure-FTP       ${PURPLE} ";
    echo -e "\t2. FREE                            ${PURPLE} ";
    echo -e "\t3. FREE                            ${PURPLE} ";
    echo -e "\t4. FREE                            ${RED} ";
    echo -e "\n\t0. Back                          ${NC}\n ";
};
# MenuCPanel

#--------------------------
while :
do
        showBanner
        MAINMENU
        echo -n -e "\n\tSelection: "
        read -n1 opt
        a=true;
        case $opt in

# 1 SubMenu ----------------------------
                1) echo -e "==== Create SSH key ===="
                while :
                do
                        showBanner
                        MenuSSH
                        echo -n -e "\n\tSelection: "
                        read -n1 opt;
                        case $opt in
                                1) TKEY="ed25519" && MKEY="" && OnRUN ;;
                                2) TKEY="rsa" && MKEY="" && OnRUN ;;
                                3) TKEY="rsa" && MKEY="PEM" && OnRUN ;;
                                4) TKEY="dsa" && MKEY="" && OnRUN ;;
                                5) TKEY="ecdsa" && MKEY="" && OnRUN ;;
                                6) TKEY="eddsa" && MKEY="" && OffRUN ;;
                                /q | q | 0) break ;;
                                *) ;;
                        esac
                done
                ;;

# 2 ----------------------------
                2) echo -e "Install LEMP: "
                while :
                do
                        showBanner
                        MenuLEMP
                        echo -n -e "\n\tSelection: "
                        read -n1 opt;
                        case $opt in
                                1) first ;;
                                2) second ;;
                                3) third ;;
                                4) fourth ;;
                                5) fifth ;;
                                /q | q | 0) break ;;
                                *) ;;
                        esac
                done
                ;;

# 3 ----------------------------
                3) echo -e "# submenu: MEMU 3"
                while :
                do
                        showBanner
                        MenuLAMP
                        echo -n -e "\n\tSelection: "
                        read -n1 opt;
                        case $opt in
                                1) installLAMP ;;
                                2) echo -e "MENU 3 - SUBmenu 2" ;;
                                3) echo -e "MENU 3 - SUBmenu 3" ;;
                                /q | q | 0) break ;;
                                *) ;;
                        esac
                done
                ;;

# 4 ----------------------------
                4) echo -e "Control Panell: "
                while :
                do
                        showBanner
                        MenuCPanel
                        echo -n -e "\n\tSelection: "
                        read -n1 opt;
                        case $opt in
                                1) OWNCLOUD ;;
                                2) echo -e "FREE $opt" ;;
                                3) echo -e "FREE $opt"  ;;
                                4) echo -e "FREE $opt"  ;;
                                5) echo -e "FREE $opt"  ;;
                                /q | q | 0) break ;;
                                *) ;;
                        esac
                done
                ;;

# 8 ----------------------------
                8) echo -e "Modules & Components: "
                while :
                do
                        showBanner
                        MenuMODandCOMPON
                        echo -n -e "\n\tSelection: "
                        read -n1 opt;
                        case $opt in
                                1) PUREFTP_RUN ;;
                                2) echo -e "FREE $opt" ;;
                                3) echo -e "FREE $opt"  ;;
                                4) echo -e "FREE $opt"  ;;
                                5) echo -e "FREE $opt"  ;;
                                /q | q | 0) break ;;
                                *) ;;
                        esac
                done
                ;;

# END ----------------------------

                /q | q | 0) echo; break ;;
                *) ;;
        esac
        done
        echo "Quit...";
        clear;
        cleanup;
}; 

THIS
MAIN


        # # # # # # # # # # # # # # # # # # # # # # #
        # }; 
        # STARTScript
        # # # # # # # # # # # # # # # # # # # # # # #



# exit 1

