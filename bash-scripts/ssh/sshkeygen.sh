#!/bin/bash

# LINK='raw.githubusercontent.com/numbnet/WebPanel/master/bash-scripts/ssh/sshkeygen.sh';bash -c "$(curl -fLsS ${LINK} || wget -O - ${LINK})"

function sshkeygen() {
title="Generate SSH Key";

#     Colors
NC="\033[0m"
GREEN="\033[32m";
RED="\033[1;31m";
BLUE="\033[1;34m";
YELOW="\033[1;33m";
BLACK="\033[40m";
TEXTCOLOR=$green;
BGCOLOR=$black;

#  - - - - - - - - - - - - - - - - -
#      VARIABLE & function
#  - - - - - - - - - - - - - - - - -

function pause() { read -p "Press [Enter] key to continue..." fackEnterKey; }
function wait() { read -p "Press [ANY] key to continue..? \n"; read -s -n 1; }
function TIMER() { if [[ "$1" =~ ^[[:digit:]]+$ ]]; then T="$1"; else if [ -z "$1" ]; then T="3"; else T="5"; fi; fi; secs="$((1 * ${T}))"; while [ $secs -gt 0 ]; do echo -ne "\t $secs\033[0K\r"; sleep 1 && : $((secs--)); done; }
function title() { clear; echo "${title} ${TKEY}"; }
#function OffRUN() { OFF="is disabled";echo -e "${RED} ${title} ${TKEY}${OFF}${NC}"; TIMER; break; }

# SSH Agent
# -------------
function AddON()
{
  while true; do
  read -e -p "Do you want RUN Agent? [y/N] ?" ryn
    case $ryn in
      [Yy]* ) clear; eval $(ssh-agent) && ssh-add -D; break ;;
      [Nn]* ) echo -e "${RED}Cancel..${NC}"; break ;;
    esac
  done

## Add to SSH Agent
# ---------------
  while true; do
  read -e -p "Do you want add key to SSH Agent? [y/N]" ayn
    case $ayn in
      [Yy]* ) local -r key_name="$1"; ssh-add "$HOME/.ssh/$key_name" ;;
      [Nn]* ) echo -e "${RED}Cancel..${NC}";break ;;
    esac
  done

  ##    Add to authorized_keys
  # -------------------
  while true; do
  read -e -p "Wright to authorized_key? [y/N]" uyn
    case $uyn in
      [Yy]* ) cat "$HOME/.ssh/${key_name}.pub" >> "$HOME/.ssh/authorized_keys" ;;
      [Nn]* ) echo -e "${RED}Cancel..${NC}"; break ;;
    esac
  done
}

# Key Generate
# -------------------
function OnRUN() {
  title
  read -e -p "Enter NAME ssh key: " IDK && \
    ID="$( echo ${IDK} | sed 's/ /_/g' )";
  read -e -p "Add comment: " COMENT && \
    COM="$( echo ${COMENT} | sed 's/ /./g' )";
  read -e -p "Enter password: " PASS;

  if [ -z "${ID}" ]; then ID="${hostname}_${USER}" && echo "${ID}"; else echo "${ID}"; fi
  if [ -z "${COM}" ]; then 
COM="${USER}"@"$( echo ${IDK} | sed 's/ /./g' )"; else echo "${COM}"; fi;
  key_name="id_${TKEY}_$( echo ${ID} | sed 's/ /_/g' ).key";

  ssh-keygen -t ${TKEY} -f $HOME/.ssh/${key_name} -C "${COM}" -N "$PASS";

  # LOOK UP
  # ------------
  while true; do
  read -e -p "Do you want Look UP SSH keys? [y/N] " syn
  case $syn in
  [Yy]* ) clear && echo -en "\n\nNAME: ${key_name}\n\n"
      cat "$HOME/.ssh/${key_name}.pub" && echo -en "\n"
      cat "$HOME/.ssh/${key_name}" && echo -en "\n";
      #cat "$HOME/.ssh/${key_name}.pub" | pbcopy;
      pause && break ;;

  [Nn]* ) echo -e "${RED}Cancel..${NC}";break ;;
    esac
  done
}


##   MENU
function MENU() {
  M="= = = = = = ";
  clear;
  echo -e -n "
${BLUE}$M\tMENU \t$M\n$M$M$M${NC}
1. $title  ED25519
2. $title  RSA
3. $title  DSA
4. $title  ECDSA
5. $title  EdDSA  ${RED}[OFF]${NC}
${BLUE}$M${NC}
${RED}0. Cancel & Quite... ${NC}
${BLUE}$M$M$M${NC}\n";
}

  #    RUN
  # ----------------
  while true; do
  MENU
  read -p "Enter: " rsn
  case $rsn in
    [0]* ) echo -en "${RED}Quit..${NC}";TIMER;break ;;
    [1]* ) TKEY="ed25519" && OnRUN;;
    [2]* ) TKEY="rsa" && OnRUN;;
    [3]* ) TKEY="dsa" && OnRUN;;
    [4]* ) TKEY="ecdsa" && OnRUN;;
    [5]* ) TKEY="eddsa" && OffRUN;;
  esac
  done
  clear
}

sshkeygen

# exit
