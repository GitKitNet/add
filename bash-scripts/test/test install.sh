

function APTINSTALL() {
  read -p "Press [Enter]" fackEnterKey;
  if [ ! -z "$1" ]; then PKG=$@; else read -p "Enter PKG to install" line; fi;
  if [ -n "$1" ]; then line=$1; else read -p "Enter PKG to install" line; fi

  for letter in $PKG; do
    PKG=$(dpkg-query -W -f='${Status}' $letter 2>/dev/null | grep -c 'ok installed'); 
    if [ "$PKG" -eq 0 ]; then
      echo -e "${YELLOW}Installing\t- ${letter} ${NC}" && sleep 2;
      apt-get install ${letter} --yes;
    elif [ "$PKG" -eq 1 ]; then
      echo -en "${GREEN}${letter}\t - IS installed${NC}\n" && sleep 2;
    fi;
  done;
}

APTINSTALL nano wget curl php
