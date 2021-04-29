#!/bin/bash
# monitor_website.sh

while getopts 's:' c
do
  case $c in
    s) SERVERWEB=$OPTARG ;;
  esac
done

if [ -e /var/log/apache2/access.$SERVERWEB.log ]; then
	> /var/log/apache2/access.$SERVERWEB.log
	trap "iptables -F && rm /var/log/apache2/test.local.ipserroraccess.log && echo ' reset firewall' && exit" 2 15
	
	error='"POST /wp-login.php HTTP/1.1" 200'

	#IPSERRORACCESS=`grep "$error" /var/log/apache2/access.$SERVERWEB.log | cut -d' ' -f1`

       	#echo "$IPSERRORACCESS" > /var/log/apache2/$SERVERWEB.ipserroraccess.log
	
	#echo `sort /var/log/apache2/$SERVERWEB.ipserroraccess.log | uniq -c` > /var/log/apache2/$SERVERWEB.ipserroraccess.log

	#NUMERRORACCESSBYIP=`cut -d' ' -f1 /var/log/apache2/$SERVERWEB.ipserroraccess.log`
	#if [ $NUMERRORACCESSBYIP -ge 3 ]; then
	#	IPBAN=`cut -d' ' -f2 /var/log/apache2/$SERVERWEB.ipserroraccess.log`
	#	echo "try number = $NUMERRORACCESSBYIP / ip ban = $IPBAN"
	#	iptables -A INPUT -s $IPBAN -j DROP
	#fi

	tail -fn 10 /var/log/apache2/access.$SERVERWEB.log | grep "$error" /var/log/apache2/access.$SERVERWEB.log | cut -d' ' -f1 /var/log/apache2/access.$SERVERWEB.log | echo `sort /var/log/apache2/$SERVERWEB.ipserroraccess.log | uniq -c` > /var/log/apache2/$SERVERWEB.ipserroraccess.log | if [ `cut -d' ' -f1 /var/log/apache2/$SERVERWEB.ipserroraccess.log` -ge 3 ]; then
		IPBAN=`cut -d' ' -f2 /var/log/apache2/$SERVERWEB.ipserroraccess.log`
		echo "try number = `cut -d' ' -f1 /var/log/apache2/$SERVERWEB.ipserroraccess.log` / ip ban = $IPBAN"
		iptables -A INPUT -s $IPBAN -j DROP
	fi
else
	echo "file access.$SERVERWEB.log not exist"
fi

