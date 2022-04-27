#!/bin/bash

############################
#
#
############################

# color
GREEN='\033[0;32m'           # Green
RED='\033[0;31m'             # Red
BLUE='\033[0;34m'            # Blue
YELLOW='\033[0;33m'          # YELLOW
PURPLE='\033[0;35m'          # PURPLE
CYAN='\033[0;36m'            # CYAN
BLACK='\033[0;40m';          # 
NC='\033[0m'                 # No Color


function THIS() {
 while true; do
  echo -e "\n\t${Yellow}Do you want Run This script [y/N] .? ${RC}"
  read -e syn
  case $syn in
    [Yy]* ) clear && break ;;
    [Nn]* ) exit 0 ;;
  esac
 done
}; THIS


#============================

if [ $# -lt 1 ];
then
  echo "Time needed in seconds"
  echo "Useage: $0 <seconds>"
  echo "Example: $0 10"
  exit 1
fi

alarm="$HOME/alarm.wav"
wget -O ${alarm} github.com/GitKitNet/add/releases/download/timer/alarm.wav
time="$1"
start="$SECONDS"
s=1

function main()
{
echo "Welcome..."
while [ $s -qt 0 ]
do
  s="$((time - (SECONDS - start)))"
  echo -ne "\r             \r"
  echo -ne "\r$s second s left"
  sleep 1
done

echo -en "Times up"

if [ -f $alarm ];
then
  play "$alarm" 2>/dev/null
else
  for i in ｀seq 1 3｀
  do
    play -l -c1 synth sin %-12 sin %-9 sin %-5 sin %-2 fade h 0.1 1 0.1 2>/dev/null
  done
fi

exit 0
}

main
