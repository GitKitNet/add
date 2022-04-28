#!/bin/bash
# set -euo pipefail

#READTIMEOUT=5

function read_yn() {
  clear
  READTIMEOUT=10

  MESSAGE=$1
  TIMEOUTREPLY=$2
  NORMALREPLY="Y"
  if [ -z "${TIMEOUTREPLY}" ]; then TIMEOUTREPLY="Y"; fi
	TIMEOUTREPLY_UC=$( echo $TIMEOUTREPLY | awk '{print toupper($0)}' )
	TIMEOUTREPLY_LC=$( echo $TIMEOUTREPLY | awk '{print tolower($0)}' )


if [ "${TIMEOUTREPLY_UC}" == "Y" ]; then NORMALREPLY="N"; fi
NORMALREPLY_UC=$( echo $NORMALREPLY | awk '{print toupper($0)}' )
NORMALREPLY_LC=$( echo $NORMALREPLY | awk '{print tolower($0)}' )

for (( i=$READTIMEOUT; i>=0; i--)); do
    printf "\r${MESSAGE} [${NORMALREPLY_UC}${NORMALREPLY_LC}/${TIMEOUTREPLY_UC}${TIMEOUTREPLY_LC}] ('${TIMEOUTREPLY_UC}' in ${i}s) "
    read -s -n 1 -t 1 waitreadyn
    if [ $? -eq 0 ]; then break; fi
  done

  yn=""
  if [ -z $waitreadyn ]; then
    echo -e "\t\nNo input entered: Defaulting to '${TIMEOUTREPLY_UC}'"
    yn="${TIMEOUTREPLY_UC}"
elif [[ "${waitreadyn}" == "y" ]]; then
    echo -en "\nStarted now...\n My commend is next!! ";
elif [[ "${waitreadyn}" == "n" ]]; then
    echo -en "\nIf NO, \n\t...script Exit now...\n";
    exit 0;
elif [[ "${waitreadyn}" -eq "" ]]; then
  echo -en "\nError select. Return answer.." && sleep 3;
  read_yn
fi
}

read_yn "Test answer: " "y"

echo -e "Start New function if ANSWER Y";
