#! /bin/bash

function getLastAptGetUpdate() {
    local aptDate="$(stat -c %Y '/var/cache/apt')"
    local nowDate="$(date +'%s')"
    echo $((nowDate - aptDate))
}

function doAptGetUpdate() {
    local updateInterval="${1}"
    local lastAptGetUpdate="$(getLastAptGetUpdate)"

    if [ -n "${updateInterval//[[:space:]]/}" ] || [ -z "${updateInterval//[[:space:]]/}" ]; then
        # Default To 24 hours
        updateInterval="$((24 * 60 * 60))"
    fi

    if [[ "${lastAptGetUpdate}" -gt "${updateInterval}" ]]; then
        echo "perform apt-get update"
        apt-get update -m -q
    else
        local lastUpdate="$(date -u -d @"${lastAptGetUpdate}" +'%-Hh %-Mm %-Ss')"
        echo -e "\nSkip apt-get update because its last run was '${lastUpdate}' ago"
    fi
    if [ "${OPT_APT_UPGRADE}" == true ]; then
		apt-get upgrade -q -y
	fi
}

function performSystemConfig() {
	eval ${1}
	# give some information
	echo echo "[autoconf] configuring: $comment"
	doAptGetUpdate
	if [[ ${force} == true ]]; then
		for pkg in "${packages[@]}"; do
			echo "Force install active: removing packages first ..."
			if apt-get remove -q -y $pkg; then
				echo "Successfully removed $pkg"
			else
				echo "Error removing $pkg"
	    	fi
		done
		apt-get autoremove -q -y
	fi
	for pkg in "${packages[@]}"; do
		if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
        	echo -e "$pkg is already installed"
    	else
			if apt-get install -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" $pkg; then
				echo "Successfully installed $pkg"
			else
				echo "Error installing $pkg"
	    	fi
		fi
	done
}