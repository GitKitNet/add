#!/bin/bash

while true
do
      MIN=20
      BREAK=10
      while [[ 0 -ne $MIN ]]; do
          echo "$MIN"
          sleep 1
          MIN=$[$MIN-1]
      done
      WHILE [[ 0 -ne $BREAK ]]; do
          echo "$BREAK"
          sleep 1
          BREAK=$[$BREAK-1]
      done

    :
done
