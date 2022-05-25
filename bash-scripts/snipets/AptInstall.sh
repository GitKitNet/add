

#set +e
function APTINSTALL() {
  read -p "Press [Enter]" fackEnterKey; 
  if [ ! -z "$1" ]; then PKG=$@;
  else
    read -p "Add list apt: " line;
  fi;

  for letter in $PKG; do
    PKG=$(dpkg-query -W -f='${Status}' $letter 2>/dev/null | grep -c 'ok installed'); 
    if [ "$PKG" -eq 0 ]; then
      echo -e "${YELLOW}Installing\t- ${letter} ${NC}"
      apt-get install ${letter} --yes;
      sleep 2;
    elif [ "$PKG" -eq 1 ]; then
      echo -en "${GREEN}${letter}\t - IS installed${NC}\n" && sleep 2;
    fi;
  done;
}

APTINSTALL nano curl wget
