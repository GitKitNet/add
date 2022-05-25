#!/bin/bash

function COL() {

 for (( i = 30; i < 38; i++ )); do 
  echo -e "\033[0;"$i"m Normal: (0;$i); \033[1;"$i"m Light: (1;$i)";
 done

for (( i = 90; i < 96; i++ )); do 
  echo -e "\033[0;"$i"m Normal: (0;$i); \033[1;"$i"m Light: (1;$i)";
 done
}
function BCOL() {
for (( i = 7; i < 7; i++ )); do 
  for (( j = 0; j < 9; i++ )); do 
  echo -e "\033[$j;"$i"m Normal: ($j;$i); \033[$j;"$i"m Light: ($j;$i)";
  done;
done;

 for (( i = 41; i < 47; i++ )); do 
  echo -e "\033[0;"$i"m Normal: (0;$i); \033[1;"$i"m Light: (1;$i)";
 done;

for (( i = 100; i < 107; i++ )); do 
  echo -e "\033[0;"$i"m Normal: (0;$i); \033[1;"$i"m Light: (1;$i)";
 done;

}


function C2() {
	for (( i = 0; i < 256; i++ )); do  
		echo -e "`tput setaf $i`(\`tput setaf$i\`) tput sgr0; `tput setab $i`(\`tput setab $i\`);`tput sgr0`"; 
	done;
};C2


