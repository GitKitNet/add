

#---------------------------------------
echo "======  NEXT  ======" && sleep 5
#---------------------------------------

echo "Press q to quit"
while true
do
    read -rs -n1 -t 0.1 < /dev/tty
    [ "$REPLY" = "q" ] && break
    
    # ... your stuff here

done

#---------------------------------------
echo "======  NEXT  ======" && sleep 5
#---------------------------------------

read -rs -n1 -p "Press [any] key! " < /dev/tty

#---------------------------------------
echo "======  NEXT  ======" && sleep 5
#---------------------------------------

pause(){
  52 #"OUTPUT" redirected  
  53 read -p "Press [Enter] key to continue..." </dev/tty
  55 #fackEnterKey
  56 }

#---------------------------------------
echo "======  NEXT  ======" && sleep 5
#---------------------------------------





function os_detect() {

	if [[ ( -z "${os}" ) && ( -z "${dist}" ) ]]; then
		# some systems dont have lsb-release yet have the lsb_release binary and vice-versa
		if [ -e /etc/lsb-release ]; then
			. /etc/lsb-release

			if [ "${ID}" = "raspbian" ]; then
				os=${ID}; dist=`cut --delimiter='.' -f1 /etc/debian_version`;
        
			else
				os=${DISTRIB_ID}; dist=${DISTRIB_CODENAME}
				if [ -z "$dist" ]; then dist=${DISTRIB_RELEASE}; fi
			fi

		elif [ `which lsb_release 2>/dev/null` ]; then
			dist=`lsb_release -c | cut -f2`;
			os=`lsb_release -i | cut -f2 | awk '{ print tolower($1) }'`;

		elif [ -e /etc/debian_version ]; then
			# some Debians have jessie/sid in their /etc/debian_version while others have '6.0.7'
			os=`cat /etc/issue | head -1 | awk '{ print tolower($1) }'`
			if grep -q '/' /etc/debian_version; then
				dist=`cut --delimiter='/' -f1 /etc/debian_version`
			else
				dist=`cut --delimiter='.' -f1 /etc/debian_version`
			fi

		else
			echo -en "\n Unfortunately, your operating system distribution and version are not supported by this script.\n You can override the OS detection by setting os= and dist= prior to running this script.\n You can find a list of supported OSes and distributions on our website: https://packages.gitlab.com/docs#os_distro_version\n For example, to force Ubuntu Trusty:\n\n\tos=ubuntu dist=trusty ./script.sh";
		fi
	fi

	if [ -z "$dist" ]; then 
		echo -en "\n Unfortunately, your operating system distribution and version are not supported by this script.\n You can override the OS detection by setting os= and dist= prior to running this script.\n You can find a list of supported OSes and distributions on our website: https://packages.gitlab.com/docs#os_distro_version\n For example, to force Ubuntu Trusty:\n\n\tos=ubuntu dist=trusty ./script.sh";
	fi

	# remove whitespace from OS and dist name
	os="${os// /}"
	dist="${dist// /}"

	echo "OPERATING SYSTEM: $os/$dist."
};

os_detect


#---------------------------------------
echo "======  NEXT  ======" && sleep 5
#---------------------------------------

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




#---------------------------------------
echo "======  NEXT  ======" && sleep 5
#---------------------------------------


function TTT() { 
read -p "Press [Enter]" fackEnterKey; 
PKG=$1 
for letter in $PKG; 
do 

apt install -y $letter;
done;
};
TTT nano curl wget

#---------------------------------------
echo "======  NEXT  ======" && sleep 5
#---------------------------------------

main_menu_new(){


apt install dialog -y

#---------------------------
exec 3>&1
RESULT=$(dialog --menu "Main Menu" 10 80 8 1 "Option 1" 2 "Option 2" 3 "Option 3" 4 "Option 4" 2>&1 >&3)
exec 3>&-

case "$RESULT" in 
	1) echo "option 1";sleep 10;;
	2) echo "option 2";sleep 10;;
	3) echo "option 3";sleep 10;;
	4) echo "option 4";sleep 10;;
	5) exit 0;sleep 10;;
	*) echo "\nOpps!!! Please Select Correct Choice";
	   echo "Press ENTER To Continue..." ; read ;;
esac

};
main_menu_new

#---------------------------------------
echo "======  NEXT  ======" && sleep 5
#---------------------------------------
