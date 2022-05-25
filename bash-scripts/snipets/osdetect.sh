function os_detect() {
	if [[ ( -z "${os}" ) && ( -z "${dist}" ) ]]; then
		# some systems dont have lsb-release yet have the lsb_release binary and vice-versa
		if [ -e /etc/lsb-release ]; then
			. /etc/lsb-release

			if [ "${ID}" = "raspbian" ]; then
				os=${ID}; dist=`cut --delimiter='.' -f1 /etc/debian_version`;
        
			else
				os=${DISTRIB_ID}
				dist=${DISTRIB_CODENAME}

				if [ -z "$dist" ]; then
					dist=${DISTRIB_RELEASE}
				fi
			fi

		elif [ `which lsb_release 2>/dev/null` ]; then
			dist=`lsb_release -c | cut -f2`
			os=`lsb_release -i | cut -f2 | awk '{ print tolower($1) }'`

		elif [ -e /etc/debian_version ]; then
			# some Debians have jessie/sid in their /etc/debian_version
			# while others have '6.0.7'
			os=`cat /etc/issue | head -1 | awk '{ print tolower($1) }'`
			if grep -q '/' /etc/debian_version; then
				dist=`cut --delimiter='/' -f1 /etc/debian_version`
			else
				dist=`cut --delimiter='.' -f1 /etc/debian_version`
			fi

		else
			unknown_os
		fi
	fi

	if [ -z "$dist" ]; then
		unknown_os
	fi

	# remove whitespace from OS and dist name
	os="${os// /}"
	dist="${dist// /}"

	echo "OPERATING SYSTEM: $os/$dist."
}; os_detect
