#!/bin/bash

function TimeDateCTL() {
clear
while true; do
  COMMAND=$(timedatectl)                    # Save command result in a var.
  echo "$COMMAND"                           # Print command result, including new lines.
  
  sleep 3                                   # Keep above's output on screen during 3 seconds before clearing it
              # Following code clears previously printed lines
  LINES=$(echo "$COMMAND" | wc -l)          # Calculate number of lines for the output previously printed
  for (( i=1; i <= $(($LINES)); i++ ));do   # For each line printed as a result of "timedatectl"
    tput cuu1                               # Move cursor up by one line
    tput el                                 # Clear the line
  done
done
};TimeDateCTL

sleep 3

watch -n 3 timedatectl

# ===========================================================
#                Local time: Tue 2021-12-21 22:44:58 CET
#            Universal time: Tue 2021-12-21 21:44:58 UTC
#                  RTC time: Tue 2021-12-21 21:44:59
#                 Time zone: Europe/Berlin (CET, +0100)
# System clock synchronized: yes
#              NTP service: active
#          RTC in local TZ: no
# ===========================================================

# exit
