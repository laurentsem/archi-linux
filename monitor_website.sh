#!/bin/bash
# monitor_website.sh

while getopts 'd:' c
do
  case $c in
    d) SERVERWEB=$OPTARG ;;
  esac
done

if [ -e /var/log/apache2/access.$SERVERWEB.log ]; then
	> /var/log/apache2/access.$SERVERWEB.log
	trap "iptables -F && rm /var/log/apache2/test.local.ipserroraccess.log && echo ' reset firewall'" 2 15

	tail -fn 10 /var/log/apache2/access.$SERVERWEB.log | while read line ; do
		echo "${line}"
		error='"POST /wp-login.php HTTP/1.1" 200'

		IPSERRORACCESS=`grep "$error" /var/log/apache2/access.$SERVERWEB.log | cut -d' ' -f1`

       		echo "$IPSERRORACCESS" > /var/log/apache2/$SERVERWEB.ipserroraccess.log
	
		echo `sort /var/log/apache2/$SERVERWEB.ipserroraccess.log | uniq -c` > /var/log/apache2/$SERVERWEB.ipserroraccess.log

		NUMERRORACCESSBYIP=`cut -d' ' -f1 /var/log/apache2/$SERVERWEB.ipserroraccess.log`
		if [ $NUMERRORACCESSBYIP -ge 3 ]; then
			IPBAN=`cut -d' ' -f2 /var/log/apache2/$SERVERWEB.ipserroraccess.log`
			echo "try number = $NUMERRORACCESSBYIP / ip ban = $IPBAN"
			iptables -A INPUT -s $IPBAN -j DROP
		fi
	done
else
	if [ -z $SERVERWEB ]; then
		echo "don't forget it's: ./monitor_website -d <domain_name.local>"
	else
		echo "file access.$SERVERWEB.log not exist"
	fi
fi

