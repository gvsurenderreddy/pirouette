#! /bin/bash

scriptPath=${0%/*}
source "${scriptPath}/config_parser.sh"

function performDhcpConfig() {
	local map=("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P")
	eval ${1}
	# at first, we initialize the global DHCPD settings
	setUpStandardValues ${1}
}
	
function performSubnetConfig() {
	eval ${1}
	# give some information
	echo "[autoconf] configuring: $comment"
	# now write the corresponding lines in the config file
	echo "$name $open" >> $fileConf
	for ((e=0; e<$entries; e++)); do
		curr="\${entry"${e}"[0]}"
		eval name=${curr}
		curr="\${entry"${e}"[1]}"
		eval value=${curr}
		line="\t$name$set$value$lineEnd"
		echo -e ${line} >> $fileConf
	done
	echo "$close" >> $fileConf
	echo "" >> ${fileConf}
}
