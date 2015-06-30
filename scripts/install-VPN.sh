#! /bin/bash

# DietPI install:
#
#	at first, prepare DietPi as follows:
#		- goto "Optimized Software"
#		- select "Samba Server"
#
#- additional Software:
#	select "Vim"
#	select "Build"
#	select "Git"
#	
#- SSH Server:
#	select "OpenSSH"
#	
#- File Server:
#	select "Samba"
#	
# --> "Go install!"
#____________________________________
#

clear

#scriptPath=${0%/*}
currPath=echo "$( pwd )"
scriptPath="$( realpath ${0%} )"
scriptPath=${scriptPath%/*}
#cd ${scriptPath}

source "${scriptPath}/config_parser.sh"
source "${scriptPath}/handle_dhcpd.sh"
source "${scriptPath}/handle_env.sh"
source "${scriptPath}/handle_configurations.sh"
source "${scriptPath}/handle_system.sh"
source "${scriptPath}/handle_networking.sh"
source "${scriptPath}/handle_iptables.sh"
source "${scriptPath}/tools.sh"

config_parser "${scriptPath}/vpn-configuration.ini";
#____________________________________
#
setUpConfiguration "config.section.system"
#____________________________________
#
setUpConfiguration "config.section.net_default"
#____________________________________
#
setUpConfiguration "config.section.net_interfaces"
#____________________________________
#
setUpConfiguration "config.section.dhcpd_default"
#____________________________________
#
setUpConfiguration "config.section.dhcpd_settings"
#____________________________________
#
setUpConfiguration "config.section.dhcpd_subnet_A"
#____________________________________
#
setUpConfiguration "config.section.openvpn_default"
#____________________________________
#
setUpConfiguration "config.section.openvpn_additional"
#____________________________________
#
setUpConfiguration "config.section.hostapd_default"
#____________________________________
#
setUpConfiguration "config.section.hostapd_settings"
#____________________________________
#
setUpConfiguration "config.section.sysctl_default"
#____________________________________
#
setUpConfiguration "config.section.sshd_settings"
#____________________________________
#
setUpConfiguration "config.section.iptables_rules"
#____________________________________
#
