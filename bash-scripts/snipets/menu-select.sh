function MENU() {
  clear
echo -e -n "
${BLUE}= = = = = = =  = = = = = = =${NC}
${BLUE}= =         MENU         = =${NC}
${BLUE}= = = = = = =  = = = = = = =${NC}
1. $title  ED25519
2. $title  RSA
3. $title  DSA
4. $title  ECDSA
5. $title  EdDSA  ${RED}[OFF]${NC}
${BLUE}= =${NC}
${RED}0. Cancel & Quite... ${NC}
${BLUE}= = = = = = = = = = = = = =${NC}\n"
}

# * * * * * * * * * *
#    START
while true; do
  MENU
  read -p "Enter: " rsn
  case $rsn in
    [0]* ) echo -en "${RED}Quit...${NC}" && TIMER;break ;;
    [1]* ) TKEY="ed25519" && OnRUN;;
    [2]* ) TKEY="rsa" && OnRUN;;
    [3]* ) TKEY="dsa" && OnRUN;;
    [4]* ) TKEY="ecdsa" && OnRUN;;
    [5]* ) TKEY="eddsa" && OffRUN;;
  esac
done
clear
