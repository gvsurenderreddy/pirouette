#!/bin/bash -ex

    PROVIDER="ipvanish/"
    OVPN_PATH="/etc/openvpn/"
    CONF_PATH="${OVPN_PATH}providers/"
    CONF_LOGBASE="/var/log/openvpn/"
    CONF_TEMP_PATH="${CONF_PATH}tmp/"
    CONF_PREPS="${CONF_PATH}${PROVIDER}preps/"
    CONF_FILES="${CONF_PATH}${PROVIDER}configs/"
    CONF_HOSTS="${CONF_PATH}vpnhosts"
    CONF_ADDS="${CONF_PATH}${PROVIDER}additional.txt"
    CONF_CURR="${OVPN_PATH}current.conf"
    PERFLOG="${CONF_LOGBASE}iperf.log"
    LOGFILE="${CONF_LOGBASE}client.log"
    FASTLOG="${CONF_LOGBASE}fastvpn.log"
	IPERFSRV="iperf.volia.net"

    # add ip / hostname separated by white space
    fastestBw=-1
    fastestConf=""
    currBw=""
	srcConf=""
	perfLog="${PERFLOG}"

	# Define a timestamp function
	function timestamp() {
		date +"%Y-%m-%d_%H-%M-%S"
	}

	function firstWord() {
		echo $1 | awk '{split($0,a,/ /); print a[1]}'
	}

    function prepareConfig() {
		sWord="$(firstWord $1)"
		echo "${1} - ${2}"
		if [ ${#sWord} -gt 0 ]; then
			clear="sed -i '/$sWord/d' $2"
			test="$( eval $clear )"
		fi
    }

    if [ -f $perfLog ]; then
    	rm $perfLog
    fi
    if ! [[ -d "${CONF_PREPS}" ]]; then
    	mkdir ${CONF_PREPS}
    fi
    mapfile -t addLines < "$CONF_ADDS"
    fastestConf="$( realpath ${CONF_CURR} )"

    echo "$( timestamp )"" - Service stopped ... " | tee -a ${FASTLOG}

    checkHosts() {
    	local   lineLen=${#2}
		if [[ ${2:0:1} != '#' ]] && [[ $lineLen -gt 0 ]]; then
			currConf="${2}"
			# set the source for the preparation
			srcConf="${CONF_PREPS}${currConf}"
			if ! [[ -f "${srcConf}" ]]; then
				# copy the ovpn file to the preps folder
				test="$( cp -a ${CONF_FILES}${currConf} ${srcConf} )"
				for line in "${addLines[@]}"; do
						cmd="prepareConfig '${line}' '${srcConf}'"
						test="$( eval ${cmd} )"
				done
				test="$( cat ${CONF_ADDS} >> ${srcConf} )"
			fi

			if [ -f "${srcConf}" ]; then
				stop="$( service openvpn stop > /dev/null )"
				link="$( ln -sf ${srcConf} ${CONF_PATH}current.conf )"
				start="$( service openvpn start )
			   tail -f "${LOGFILE}" | while read LOGLINE; do
				   [[ "${LOGLINE}" == *"Initialization Sequence Completed"* ]] && pkill -P $$ tail
				done
				iperf -f m -n 1M -p 5001 -c "${IPERFSRV}" >> $perfLog
				bandWidth="$( echo -e $(awk '/Bandwidth/ {getline}; END{print $8}' $perfLog) )"
				echo "$( timestamp )"" - Bandwidth: ${bandWidth} Mbits/sec" >> ${FASTLOG}
			fi

			currBw=$bandWidth
			if (( $(bc <<< "$currBw > $fastestBw") == 1 )); then
				shortConf=$currConf
				fastestConf=$srcConf
				fastestBw=$currBw
			fi
		fi
    };

    if [[ -f "${CONF_HOSTS}" ]]; then
        mapfile -t -c 1 -C 'checkHosts' < "${CONF_HOSTS}"
    fi

    if [[ -f "${fastestConf}" ]]; then
    	link="$( ln -sf ${fastestConf} ${CONF_PATH}current.conf )"
        echo "$( timestamp )"" - New conf: ${shortConf} - ${fastestBw} Mbit/sec" | tee -a ${FASTLOG}
    fi

    dL="$( service openvpn restart )"
    echo "$( timestamp )"" - Service restarted ... " | tee -a ${FASTLOG}
    
    if [ -f $perfLog ]; then
    	rm $perfLog
    fi

                                                                                   