#!/bin/bash
# monitor_website.sh

while getopts 'd:' c
do
  case $c in
    d) domain_name=$OPTARG ;;
  esac
done

log_server_web="/var/log/apache2/access.$domain_name.log"
log_ips_error_access="/var/log/apache2/$domain_name.ipserroraccess.log"
error_str='"POST /wp-login.php HTTP/1.1" 200'

reset () {
	log_ips_error_access=$1
	iptables -F && rm $log_ips_error_access && echo ' reset firewall'
}

banip () {
	IPBAN=$1
	num_error_access_by_ip=$2
	echo "ip ban: $IPBAN / try fail: $num_error_access_by_ip"
	iptables -A INPUT -s $IPBAN -j DROP
}

startfirewall () {
	> $log_server_web
	trap "reset $log_ips_error_access" 2 15

	tail -fn 10 $log_server_web | while read line ; do
		echo "${line}"

		ip_error_access=`grep "$error_str" $log_server_web | cut -d' ' -f1`

       		echo "$ip_error_access" > $log_ips_error_access
	
		echo `sort $log_ips_error_access | uniq -c` > $log_ips_error_access

		num_error_access_by_ip=`cut -d' ' -f1 $log_ips_error_access`
		if [ $num_error_access_by_ip -ge 3 ]; then
			IPBAN=`cut -d' ' -f2 $log_ips_error_access`
			banip $IPBAN $num_error_access_by_ip
		fi
	done
}

if [ -e $log_server_web ]; then
	startfirewall
else
	if [ -z $domain_name ]; then
		echo "don't forget it's: ./monitor_website -d <domain_name.local>"
	else
		echo "file access.$domain_name.log not exist"
	fi
fi

