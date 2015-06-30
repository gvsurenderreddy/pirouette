#! /bin/bash

function setUpInterfaces() {
	eval ${1}
	# give some information
	echo "[autoconf] configuring: $comment"
	iFile=$fileConf
	# backup configuration
	if ! [ -f "${iFile}.dietpi" ]; then
		cp "${iFile}" "${iFile}.dietpi" 
	fi
	# empty configuration file
	cat /dev/null > ${iFile}
	for ((i=0; i<$items; i++)); do
		curr="\${item"${i}"[0]}"
		eval intf0=${curr}
		curr="\${item"${i}"[1]}"
		eval intf1=${curr}
		curr="\${item"${i}"[2]}"
		eval intf2=${curr}
		curr="\${item"${i}"[3]}"
		eval intf3=${curr}
		curr="\${item"${i}"[4]}"
		eval intf4=${curr}
		curr="\${item"${i}"[5]}"
		eval intf5=${curr}
#		echo ${item}
		echo -e "# ${intf0}" >> ${iFile}
		case ${intf2} in
			"static"*)
				echo -e "auto ${intf1}" >> ${iFile}
				echo -e "iface ${intf1} inet ${intf2}" >> ${iFile}
				if [[ -n "${intf5}" ]]; then
						echo -e "\taddress ${intf3}\n\tnetmask ${intf4}\n\tgateway ${intf5}" >> ${iFile}
				else
						echo -e "\taddress ${intf3}\n\tnetmask ${intf4}\n" >> ${iFile}
				fi
			;;
			"loopback"*)
				echo -e "auto ${intf1}" >> ${iFile}
				echo -e "iface ${intf1} inet ${intf2}" >> ${iFile}
			;;
			"entry"*)
				echo -e "${intf1} ${intf3//${sep}/ }\n" >> ${iFile}
			;;
			*)
				# unknown: do nothing
			;;
		esac
		# add an empty line
		echo -e "" >> ${iFile}
	done
}

