#!/bin/bash
# set -euo pipefail
#  bash <(wget -O - raw.githubusercontent.com/numbnet/WebPanel/master/bash-scripts/timer/AskTimerRUN.sh)

function READyn() {
  clear;
  READTIMEOUT=10;
  MESSAGE=$1;
  #MESSAGE="Press [Enter] key to continue..."
  TIMEOUTREPLY=$2;
  NORMALREPLY="";
  if [ -z "${TIMEOUTREPLY}" ]; then TIMEOUTREPLY="Y"; fi;
   TIMEOUTREPLY_UC=$( echo $TIMEOUTREPLY | awk '{print toupper($0)}' )
   TIMEOUTREPLY_LC=$( echo $TIMEOUTREPLY | awk '{print tolower($0)}' )
  if [ "${TIMEOUTREPLY_UC}" == "Y" ]; then NORMALREPLY="N"; fi;
   NORMALREPLY_UC=$( echo $NORMALREPLY | awk '{print toupper($0)}' )
   NORMALREPLY_LC=$( echo $NORMALREPLY | awk '{print tolower($0)}' )
  for (( i=$READTIMEOUT; i>=0; i--)); do
    printf "\r${MESSAGE} [ ${NORMALREPLY_UC}${NORMALREPLY_LC} or ${TIMEOUTREPLY_UC}${TIMEOUTREPLY_LC} ] ('${TIMEOUTREPLY_UC}' in ${i}s) ";
    read -s -n 1 -t 1 waitreadyn;
    if [ $? -eq 0 ]; then break; fi;
  done;
  YoN="";
  if [ -z $waitreadyn ]; then
    echo -e "\nNo input entered: Defaulting to '${TIMEOUTREPLY_UC}'"; YoN="${TIMEOUTREPLY_UC}"
   elif [ "${waitreadyn}" == "y" ]; then
    echo -e "\n input entered: -YES- Defaulting to '${TIMEOUTREPLY_UC}'"; YoN="${TIMEOUTREPLY_UC}"
   elif [ "${waitreadyn}" == "n" ]; then
    echo -e "\n input entered: -NO- Defaulting to '${TIMEOUTREPLY_UC}'"; YoN="${TIMEOUTREPLY_UC}"
   elif [[ "${waitreadyn}" -eq "" ]]; then
    echo -e "\n input entered: -ATHER- Defaulting to '${TIMEOUTREPLY_UC}'"; YoN="${TIMEOUTREPLY_UC}";
    sleep 2;
    #READyn "TESTING for ";
  fi;
};
READyn;


#echo -e "${waitreadyn}"

#exit
