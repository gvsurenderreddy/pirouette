#! /bin/bash

function setUpStandardValues() {
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
		# empty configuration file?
		if [ ${doClear} == true ]; then
			echo "### "$comment > ${fileConf}
			echo "" >> ${fileConf}
		fi
	fi
	 # delete BOTH leading and trailing whitespace from each line
	sed -i 's/^[ \t]*//;s/[ \t]*$//' ${fileConf}
	# set the last character of a line
	if ! [ "${#lineEnd}" > 0 ]; then
		lineEnd=""
	fi
	#shopt -s extglob
	# now iterate all items and handle the configuration file
	for ((i=0; i<$items; i++)); do
		curr="\${item"${i}"[0]}"
		eval search=${curr}
		curr="\${item"${i}"[1]}"
		eval replace=${curr}
		set="${set}" || " "
		search=$( echo "${search}"| sed -e 's/^ *//' -e 's/ *$//' );
		pattern="^[#\s\t]*${search}${set}"
		if [ ${doEscape} == true ]; then
			pattern="${pattern//\//\\\/}"
			pattern="${pattern//./\.}"
			pattern="^[#\s\t]*${pattern// /\ }"
		fi
		replace=$( echo "${replace}" | sed -e 's/^ *//' -e 's/ *$//' )
		# perhaps the new value should be quoted
		if [ ${doQuote} == true ]; then
			replace="\"${replace}\""
		fi
		if [[ $lineEnd =~ ^\ +$ ]] ;then 
			lineEnd=""
		fi
		replace="${search}${set}${replace}${lineEnd}"

#		echo "###${replace}###"
#		echo "###${pattern}###"

		found=$( grep -c "$pattern" "${fileConf}" )
		if ! [ $found -eq 0 ]; then
			cmd="sed -i 's|$pattern.*|$replace|' ${fileConf}"
			# re-escape double quotes, if used
			cmd="${cmd//\"/\\\"}"
			eval $cmd
		else
			#echo "insert new: ${replace} (file: ${fileConf})"
			echo "${replace}" >> ${fileConf}
		fi
	done
	#shopt -u extglob
	echo "" >> ${fileConf}
}

function setUpConfiguration() {

	# set default options
	doEscape=false
	doClear=false
	doQuote=false
	type="configuration" # default value
	
	# eval the ini file
	eval ${1}

	case "${type}" in
		# special setups
		"net_interfaces")
			setUpInterfaces ${1}
			;;
		"system")
			performSystemConfig ${1}
			;;
		"dhcpd_settings")
			performDhcpConfig ${1}
			;;
		"subnet")
			performSubnetConfig ${1}
			;;
		"iptables_rules")
			setUpIptableRules ${1}
			;;
		"configuration")
			setUpStandardValues ${1}
			;;
		*)
			echo $"No or wrong configuration type declared!"
            exit 1
			;;
	esac
}