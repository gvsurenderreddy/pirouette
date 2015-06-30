#! /bin/bash

function setUpIptableRules() {
	# eval the ini file
	eval ${1}
	# give some information
	echo "[autoconf] configuring: $comment"
	if ! [ -f "${fileConf}" ]; then
		mkFileAndDir "${fileConf}"
	else
		# backup configuration
		if ! [ -f "${fileConf}.dietpi" ]; then
			cp "${fileConf}" "${fileConf}.dietpi" 
		fi
	fi
	# now iterate all items and handle the configuration file
	for ((i=0; i<$items; i++)); do
		curr="\${item"${i}"[0]}"
		eval rule=${curr}
		iptables $rule
		echo "iptables $rule"
	done
	iptables-save > ${fileConf}
}