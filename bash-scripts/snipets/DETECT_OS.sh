#!/bin/bash

function GPG_CHECK () { echo "Checking for gpg..."; if command -v gpg > /dev/null; then echo "Detected gpg..."; else echo "Installing gnupg for GPG verification..."; apt-get install -y gnupg; if [ "$?" -ne "0" ]; then echo "Unable to install GPG! Your base system has a problem; please check your default OS's package repositories because GPG should work."; echo "Repository installation aborted."; exit 1; fi; fi; }
function CURL_CHECK () { echo "Checking for curl..."; if command -v curl > /dev/null; then echo "Detected curl..."; else echo "Installing curl..."; apt-get install -q -y curl; if [ "$?" -ne "0" ]; then echo "Unable to install curl! Your base system has a problem; please check your default OS's package repositories because curl should work."; echo "Repository installation aborted."; exit 1; fi; fi; }
function INSTALL_DEBIAN_KEYRING () { if [ "${os}" = "debian" ]; then echo "Installing debian-archive-keyring which is needed for installing "; echo "apt-transport-https on many Debian systems."; apt-get install -y debian-archive-keyring &> /dev/null; fi; }

UNKNOWN_OS() { echo -en "\nOS:  \tUNFORTUNATELY/not supported\nLIST:\t https://packages.gitlab.com/docs#os_distro_version \n" && sleep 5; }
function DETECT_OS() {
	if [[ ( -z "${os}" ) && ( -z "${dist}" ) ]]; then 
		if [ -e /etc/lsb-release ]; then 
			. /etc/lsb-release; 
			if [ "${ID}" = "raspbian" ]; then 
				os=${ID} && dist=`cut --delimiter='.' -f1 /etc/debian_version`;
			else 
				os=${DISTRIB_ID} && dist=${DISTRIB_CODENAME};
				if [ -z "$dist" ]; then
					dist=${DISTRIB_RELEASE};
				fi; 
			fi 
		elif [ `which lsb_release 2>/dev/null` ]; then 
			dist=`lsb_release -c | cut -f2`;
			os=`lsb_release -i | cut -f2 | awk '{ print tolower($1) }'`;
		elif [ -e /etc/debian_version ]; then 
			os=`cat /etc/issue | head -1 | awk '{ print tolower($1) }'`; 
			if grep -q '/' /etc/debian_version; then 
				dist=`cut --delimiter='/' -f1 /etc/debian_version`; 
			else
				dist=`cut --delimiter='.' -f1 /etc/debian_version`;
			fi; 
		else
			UNKNOWN_OS;
		fi;
	fi;

	if [ -z "$dist" ]; then UNKNOWN_OS; fi; 

	os="${os// /}"; dist="${dist// /}";
	echo "OPERATING SYSTEM: $os/$dist.";
}; DETECT_OS


main () {
	detect_os; curl_check;gpg_check

	# Need to first run apt-get update so that apt-transport-https can be installed
	echo -n "Running apt-get update... "; apt-get update &> /dev/null; echo "done."

	# Install the debian-archive-keyring package on debian systems so that apt-transport-https can be installed next
	install_debian_keyring;

	echo -n "Installing apt-transport-https... "; apt-get install -y apt-transport-https &> /dev/null; echo "done.";

	gpg_key_url="https://packages.gitlab.com/gitlab/gitlab-ce/gpgkey"
	apt_config_url="https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/config_file.list?os=${os}&dist=${dist}&source=script"
	apt_source_path="/etc/apt/sources.list.d/gitlab_gitlab-ce.list"
	echo -n "Installing $apt_source_path..."

	# create an apt config file for this repository
	curl -sSf "${apt_config_url}" > $apt_source_path
	curl_exit_code=$?

	if [ "$curl_exit_code" = "22" ]; then
		echo -n "Unable to download repo config from: ${apt_config_url} This usually happens if your operating system is not supported by packagecloud.io, or this script's OS detection failed. You can override the OS detection by setting os= and dist= prior to running this script. You can find a list of supported OSes and distributions on our website: https://packages.gitlab.com/docs#os_distro_version. For example, to force Ubuntu Trusty: os=ubuntu dist=trusty ./script.sh If you are running a supported OS, please email support@packagecloud.io and report this."
		[ -e $apt_source_path ] && rm $apt_source_path
		exit 1
	elif [ "$curl_exit_code" = "35" -o "$curl_exit_code" = "60" ]; then
		echo "curl is unable to connect to packagecloud.io over TLS when running: 
			curl ${apt_config_url}
			This is usually due to one of two things:
			1.) Missing CA root certificates (make sure the ca-certificates package is installed)
			2.) An old version of libssl. Try upgrading libssl on your system to a more recent version. Contact support@packagecloud.io with information about your system for help.";
		[ -e $apt_source_path ] && rm $apt_source_path;
		exit 1;
	elif [ "$curl_exit_code" -gt "0" ]; then
		echo -e "Unable to run:	curl ${apt_config_url} \n Double check your curl installation and try again.";
		[ -e $apt_source_path ] && rm $apt_source_path;
		exit 1;
	else 
		echo "done."
	fi;

	echo -n "Importing packagecloud gpg key... "

	# import the gpg key
		curl -L "${gpg_key_url}" 2> /dev/null | apt-key add - &>/dev/null; echo -n "done. \n Running apt-get update... "

	# update apt on this system
		apt-get update &> /dev/null; echo -e "done. \n The repository is setup! You can now install packages."
};

main
