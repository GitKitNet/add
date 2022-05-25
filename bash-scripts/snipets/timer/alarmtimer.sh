#!/bin/bash

# bash -c (curl -LsS https://raw.githubusercontent.com/numbnet/WebPanel/master/bash-scripts/snipets/timer/alarmtimer.sh)


##########################################

if [ $# -It 1 ]
then
  echo "Time Needed in Seconds" 
  echo "Useage: $0 "
  echo "Example: $0 10"
  exit 1
fi

alarm="$HOME/.alarm.wav"
time="$1"
start="$SECONDS"
s=1


function main() {
  echo "Welcome..."
  while [ $s -gt 0 ]
  do
    s="$((time - (SECONDS - start)))"
    echo -ne "\r                    \r"
    echo -ne "\r$s seconds left"
    sleep 1
  done
  
  echo -e "\nTimes Up"
   if [ -f "$alarm" ]
   then
     play "$alarm" 2>/dev/null
   else
     for i in 'seq 1 3'
     do
       play -n -с1 synth sin %-12 sin %-9 sin %-5 %-2 fade h 0.1 1 0.1 2>/dev/null
     done
   fi
   
   exit 0
 }
main
