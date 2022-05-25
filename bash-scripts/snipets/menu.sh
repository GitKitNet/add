#!/bin/bash
# 

#--------------------------
#     Colors settings
#--------------------------
BLUE='\033[0;34m'       # Blue
GREEN='\033[0;32m'      # Green
RED='\033[0;31m'        # Red
YELLOW='\033[0;33m'     # Yellow
NC='\033[0m'            # No Color


title="Add new SSH Key"

#============================
#    Variable & Variable
#============================
function title() {
  clear;
  echo "${title}";
}

function wait() { read -p "Нажмите любую клавишу для продолжения" -s -n 1; }

function TIMER() {
T="$1"; if [ -z "${T}" ]; then T="5"; fi; secs="$((1 * ${T}))"; while [ $secs -gt 0 ]; do echo -ne "\t $secs\033[0K\r"; sleep 1 && : $((secs--)); done; }

function ssh_agent_run(){ eval $(ssh-agent); ssh-add -D; }
function ssh_agent_add_key(){ local -r key_name="$1"; ssh-add "$HOME/.ssh/$key_name"; }
## START DATA
function VARDATA()
{
  title
  read -e -p "Enter ID ssh key: " IDK && ID="$( echo ${IDK} | sed 's/ /./g' )"
  read -e -p "Add comment: " COMENT && COM="$( echo ${COMENT} | sed 's/ //g' )"
  read -e -p "Enter password: " PASS
  
  if [ -z "${ID}" ]; then ID="${USER}" && echo "${ID}"; else echo "${ID}"; fi
  if [ -z "${COM}" ]; then COM="${USER}@localhost"; else echo "${COM}"; fi
  
  key_name="id_${TKEY}_$( echo ${ID} | sed 's/ //g' ).key"
  ssh-keygen -t ${TKEY} -f ~/.ssh/${key_name} -C "${COM}" -N "$PASS"
  wait
}


## MENU
function MENU() {
if [ -z "${title}" ]
clear
ASK="\n===========\t MENU \t===========
\t 1. $title 
\t 2. $title 
\t 3. $title 
\t 4. $title 
\t 5. $title 
\n\t 0. Cancel & Quite
\nEnter: "
echo -e -n "${ASK}"
}

## 
while true; do
  MENU
  read rsn
  case $rsn in
    [1]* ) TKEY="ed25519" && VARDATA ;;
    [2]* ) TKEY="rsa" && VARDATA ;;
    [3]* ) TKEY="dsa" && VARDATA ;;
    [4]* ) TKEY="ecdsa" && VARDATA ;;
# [5]* ) TKEY="eddsa" && VARDATA ;;
    [0]* ) echo -e " ${YELLOW} Cancel and Quit.. ${NC}";clear; break ;;
  esac
done
}
KeyGenSSH

####  END  ####
