# Test installed package

# bash <(curl -L -Ss raw.githubusercontent.com/numbnet/WebPanel/master/bash-scripts/snipets/install/instpack.sh)

function INSTALL() {
	LIST="$@"
	for pkg in `echo ${LIST}`; do
		PACK=$(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed")
		if [ "${PACK}" -eq 0 ]; then 
			echo -e "$pkg - NOT Installed"
			sleep 1
		elif [ "${PACK}" -eq 1 ]; then
			echo -e "$pkg - is installed!"
			sleep 1
		fi
	done
}
INSTALL nano curl splash srg tntnet


####################}
#function INSTALL() {
# INST="$@"; 
# for pkg in `echo ${INST}`; do    
#  apt-get install -y $pkg;
#  done;
#}
