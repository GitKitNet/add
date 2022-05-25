
function DETECT_OS() {
	function UNKNOWN_OS() { echo -e "OS:   [Unfortunately/Not Supported]\nLIST: https://packages.gitlab.com/docs#os_distro_version"; sleep 5 && exit 1; };

	if [[ ( -z "${os}" ) && ( -z "${dist}" ) ]]; then
		if [ -e /etc/lsb-release ]; then
			. /etc/lsb-release;

			if [ "${ID}" = "raspbian" ]; then
				os=${ID};
				dist=cut --delimiter='.' -f1 /etc/debian_version;
			else
				os=${DISTRIB_ID};
				dist=${DISTRIB_CODENAME};
				if [ -z "$dist" ]; then
					dist=${DISTRIB_RELEASE};
				fi;
			fi;
		elif [ which lsb_release 2>/dev/null ]; then
			dist=lsb_release -c | cut -f2;
			os=lsb_release -i | cut -f2 | awk '{ print tolower($1) }';
		elif [ -e /etc/debian_version ]; then
			os=cat /etc/issue | head -1 | awk '{ print tolower($1) }';
			if grep -q '/' /etc/debian_version; then
				dist=cut --delimiter='/' -f1 /etc/debian_version;
			else
				dist=cut --delimiter='.' -f1 /etc/debian_version;
			fi;
		else
			UNKNOWN_OS;
		fi;
	fi;

	if [ -z "$dist" ]; then
		UNKNOWN_OS;
	fi;

	os="${os// /}";
	dist="${dist// /}";
	VER="$(cat /etc/*release |grep '^VERSION_ID=' |sed  's/"//g' |awk -F= '{print $2 }' )"; 

	echo "OPERATING SYSTEM: $os$VER/$dist.";

}; DETECT_OS


function OSInfo() {
	OS="$(cat /etc/*release |grep '^ID=' |sed 's/"//g' |awk -F= '{print $2 }' )"; 
	VER="$(cat /etc/*release |grep '^VERSION_ID=' |sed  's/"//g' |awk -F= '{print $2 }' )";

	if [[ "$1" == "OS" ]]; then 
		echo "${OS}";
	elif [[ "$1" == "REL" ]] && [[ "$2" == "REL" ]]; then
		echo "${REL}";
	elif [[ -z "$1" ]]; then
		echo "${OS} ${REL}";
	fi;

}; OSInfo OS

