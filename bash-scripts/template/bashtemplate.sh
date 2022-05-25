#!/bin/bash

#=====================================
    title=''
#=====================================

# -------------------------------------
#      Colors settings
# -------------------------------------
BLUE='\033[0;34m'               # BLUE    (BLUE='\033[1;34m')
GREEN='\033[0;32m'              # GREEN   (GREEN='\033[1;32m')
RED='\033[0;31m'                # RED     (RED='\033[1;31m')
YELLOW='\033[0;33m'             # YELLOW  (YELLOW='\033[1;33m')
PURPLE='\033[0;4;35m'           # PURPLE  (PURPLE='\033[1;4;35m')
CYAN='\033[4;36m'               # CYAN
BLACK='\033[40m'                # BLACK
TEXTCOLOR=$GREEN                # TEXT COLOR
BGCOLOR=$BLACK                  # Backgraund color
NC='\033[0m'                    # No Color

# -------------------------------------
#      VARIABLE & Function
# -------------------------------------
function wait() { echo -en "\n\tress [ANY] key to continue..." && read -s -n 1; }
function pause() { echo -en "\n\tPress [ENTER] key to continue..." && read fackEnterKey; }
function title() { clear && echo "${title}" && wait; }
function OSInfo() { OS="$(cat /etc/*release |grep '^ID=' |sed 's/"//g' |awk -F= '{print $2 }' )"; REL="$(cat /etc/*release |grep '^VERSION_ID=' |sed  's/"//g' |awk -F= '{print $2 }' )"; if [ "$1" -eq "OS"]; then echo "${OS}"; elif [ "$1" -eq "REL"] && [ "$2" -eq "REL"]; then echo "${REL}"; elif [ -z "$1"]; then echo "${OS} ${REL}"; fi; };
OSInfo OS REL
function myip() { IPE="$(ip addr show eth0 |grep inet |awk '{ print $2; }' |sed 's/\/.*$//' |grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' )"; IPW="$(echo $(curl -4 icanhazip.com))"; IPH="$(hostname -I|cut -f1 -d ' ')"; if [ "$IPE" == "$IPW" ]; then myip="$IPE"; elif [ "$IPH" == "$IPW" ]; then myip="$IPH"; elif [ "$IPE" == "$IPW" ]; then myip="$IPW"; fi; echo "${myip}"; }
function TIMER() { T="5"; if [[ "$1" =~ ^[[:digit:]]+$ ]]; then T="$1"; fi; SE="$((1 * ${T}))" && SC='\033[0K\r'; while [ $SE -gt 0 ]; do echo -ne "\t $SE$SC"; sleep 1 && : $((SE--)); done; }
function DATA() { DATA=$(date +%Y%m%d-%H%M%S) && echo "$DATA"; }

# -------------------------------------
#           START COMMAND
# -------------------------------------



# -------------------------------------
#           END COMMAND
# -------------------------------------
# exit
