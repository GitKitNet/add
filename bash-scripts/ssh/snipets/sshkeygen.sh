#!/bin/bash


# SSHSC=$HOME/sshkeygen.sh && wget -O $SSHSC https://raw.githubusercontent.com/numbnet/WebPanel/master/ssh/snipets/sshkeygen.sh && chmod +x $SSHSC && $SSHSC;

## =======================
function keygenSSH () {
#  - - - - - - - - - - - - - - - - - - - - 
#   VARIABLE & function
#  - - - - - - - - - - - - - - - - - - - - 

#  * * * * * * * * * *
#   Colors

title="Add SSH Key";
function pause() { read -p "Press [Enter] key to continue..." fackEnterKey; }
function TIMER() { T="$1"; if [ -z "${T}" ]; then T="5"; fi; secs="$((1 * ${T}))"; while [ $secs -gt 0 ]; do echo -ne "\t $secs\033[0K\r"; sleep 1 && : $((secs--)); done; }
function title() { clear; echo "${title} ${TKEY}"; }
function wait() { echo -en "\n Next...? \n"; read -s -n 1; }
function AGENTrun() {
clear
read -r -p "Do you want RUN SSH Agent? [y/N] " response; 
case $response in 
 [yY][eE][sS]|[yY]) eval $(ssh-agent) && ssh-add -D ;; 
*) echo -e "${RED}Cancel..${NC}" ;; 
esac; 
}
function AGENTadd() {
clear
read -r -p "Do you want ${title} to Agent? [y/N] " response;
case $response in 
[yY][eE][sS]|[yY])
local -r key_name="$1"; ssh-add "$HOME/.ssh/$key_name" ;; 
*)
echo -e "${RED}Cancel..${NC}" ;; 
esac;
 }
function authFILE() { 
clear
read -r -p "Add Public Key to authorized_key? [y/N] " response; 
case $response in
[yY][eE][sS]|[yY])  cat "$HOME/.ssh/${key_name}.pub" >> "$HOME/.ssh/authorized_keys" ;;
*) echo -e "${RED}Cancel..${NC}" ;; 
esac; 
}
function seeKEY() {
clear
read -r -p "Do you want see SSH keys? [y/N] " response; 
case $response in 
[yY][eE][sS]|[yY]) clear; 
echo -en "\n===================\n"; 
echo -en "\tPRIVAT KEY: ${key_name}\n" && cat "$HOME/.ssh/${key_name}"; 
echo -en "\tPUBLIC KEY: ${key_name}.pub\n" && cat "$HOME/.ssh/${key_name}.pub"; 
echo -en "\n===================\n"
pause ;; 
*) echo -e "${RED}Cancel${NC}" && clear;;
esac;
}

## ================
## SCRIPT DATA
function VARDATA()
{
  title
  read -e -p "Enter NAME ssh key: " IDK && ID="$( echo ${IDK} | sed 's/ /_/g' )"
  read -e -p "Add comment: " COMENT && COM="$( echo ${COMENT} | sed 's/ //g' )"
  read -e -p "Enter password: " PASS
  # ------
  if [ -z "${ID}" ]; then ID="${hostname}_${USER}" && echo "${ID}"; else echo "${ID}"; fi
  if [ -z "${COM}" ]; then COM="${USER}@localhost"; else echo "${COM}"; fi
  key_name="id_${TKEY}_$( echo ${ID} | sed 's/ /_/g' ).key"
  #-------
  ssh-keygen -t ${TKEY} -f $HOME/.ssh/${key_name} -C "${COM}" -N "$PASS"
wait
AGENTrun
AGENTadd
authFILE
seeKEY
}

##   MENU
function MENU() {
  clear
echo -e -n "
====    MENU    ====
1. $title  ED25519
2. $title  RSA
3. $title  DSA
4. $title  ECDSA
5. $title  EdDSA     [OFF] 
- -
0. Cancel & Quite ... 
- - - - - - - - - - - - - - \n"
}

## ================
## START
while true; do
  MENU
  read -p "Enter: " rsn
  case $rsn in
    [1]* ) TKEY="ed25519" && VARDATA ;;
    [2]* ) TKEY="rsa" && VARDATA ;;
    [3]* ) TKEY="dsa" && VARDATA ;;
    [4]* ) TKEY="ecdsa" && VARDATA ;;
#  [5]* ) TKEY="eddsa" && VARDATA ;;
    [0]* ) echo -en "Quit .." && break ;;
  esac
done
clear
};
keygenSSH
exit 1

## =======================
