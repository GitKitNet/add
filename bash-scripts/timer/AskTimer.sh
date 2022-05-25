#!/bin/bash

abend() {
# Resets stty and then exits script
  stty sane
  exit
}

DoAction() {
  stty -echo 
        # Turn off echo
  tput sc
        #Save cursor position
  echo -ne "\033[0K\r"
        # Remove previous line
  tput cuu1
        #Go to previous line
  tput el
        #clear to end of line
  echo "You have $(($time-$count)) seconds"
        #Echo timer
  echo -n "$Keys"
        #Echo currently typed text

#turn echo on
  stty echo
#return cursor
  tput rc
}

main() {
  time=5
  clear && trap abend SIGINT
# Trap ctrl-c to return terminal to normal
  stty -icanon time 0 min 0 -echo
# turn of echo and set read time to nothing
  keypress=''
  echo "You have $time seconds"
  while Keys=$Keys$keypress; do
    sleep 0.05
    read keypress && break
    ((clock  = clock + 1 ))
    if [[ clock -eq 20 ]];then
      ((count++)); clock=0; DoAction $Keys
    fi
    [[ $count -eq $time ]] && clear && \
      echo -e "\tTime OUT..." && abend
  done
  stty sane && clear;
  echo -e "Entered: $Keys\nQuit..."
  sleep 2 && exit 0
}

main
