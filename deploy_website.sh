#!/bin/bash
# deploy_website.sh

GROUP="www-data"

if [ -z $1 ]; then
    echo "need one param"
else
    echo "there is param"
fi

DOMAINNAME=$1
USER="${1%%.*}"

if grep "^$GROUP" /etc/group > /dev/null; then
    echo "group: '$GROUP' exist"
else
    echo "creating group: '$GROUP'"
    groupadd $GROUP
fi

if grep "^$USER" /etc/passwd > /dev/null; then
    echo "user: '$USER' exist"
else
    echo "creating user: '$USER'"
    useradd $USER && gpasswd -a $USER $GROUP
fi

if [ -e /var/www/$DOMAINNAME ]; then
    echo "directory domain: '$DOMAINNAME' exist"
else
    echo "creating directory domain: '$DOMAINNAME'"
    cd /var/www/ && wget https://fr.wordpress.org/latest-fr_FR.tar.gz && tar -zxf latest-fr_FR.tar.gz && mv wordpress/ $DOMAINNAME && rm -r latest-fr_FR.tar.gz
fi

VIRTUALHOST="${DOMAINNAME}.conf"

if [ -e /etc/apache2/sites-available/$VIRTUALHOST ]; then
    echo "file virtualhost: '$VIRTUALHOST' exist"
else
    echo "creating file virtualhost: '$VIRTUALHOST'"
    cd /etc/apache2/sites-available/ && echo "<VirtualHost *:80>
    DocumentRoot "/var/www/${DOMAINNAME}"
    ServerName www.${DOMAINNAME}
</VirtualHost>" > $VIRTUALHOST && a2ensite $VIRTUALHOST && apache2ctl restart
fi
