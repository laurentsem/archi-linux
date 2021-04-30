#!/bin/bash
# deploy_website.sh

GROUP="www-data"

if [ -z $1 ]; then
    echo "need one param"
    exit
fi

domain_name=$1
USER="${1%%.*}"

if grep "^$GROUP" /etc/group > /dev/null; then
    echo "group: '$GROUP' exist, add permissions "
    sudo chown -R $GROUP:$GROUP /var/www
else
    echo "creating group: '$GROUP'"
    groupadd $GROUP
    sudo chown -R $GROUP:$GROUP /var/www
fi

if grep "^$USER" /etc/passwd > /dev/null; then
    echo "user: '$USER' exist, add $USER in $GROUP "
    gpasswd -a $USER $GROUP
else
    echo "creating user: '$USER'"
    useradd $USER && gpasswd -a $USER $GROUP
fi

if [ -e /var/www/$domain_name ]; then
    echo "directory domain: '$domain_name' exist, recreate $domain_name "
    rm -r /var/www/$domain_name
    cd /var/www/ && wget https://fr.wordpress.org/latest-fr_FR.tar.gz && tar -zxf latest-fr_FR.tar.gz && mv wordpress/ $domain_name && rm -r latest-fr_FR.tar.gz 
else
    echo "creating directory domain: '$domain_name'"
    cd /var/www/ && wget https://fr.wordpress.org/latest-fr_FR.tar.gz && tar -zxf latest-fr_FR.tar.gz && mv wordpress/ $domain_name && rm -r latest-fr_FR.tar.gz 
fi

virtual_host="${domain_name}.conf"

if [ -e /etc/apache2/sites-available/$virtual_host ]; then
    echo "file virtualhost: '$virtual_host' exist, recreate $virtual_host "
    rm -r /etc/apache2/sites-available/$virtual_host
    cd /etc/apache2/sites-available/ && echo "<VirtualHost *:80>
    DocumentRoot "/var/www/${domain_name}"
    ServerName www.${domain_name}
    ServerAlias ${domain_name}
    CustomLog "/var/log/apache2/access.${domain_name}.log" common
</VirtualHost>" > $virtual_host && a2ensite $virtual_host && apache2ctl -t && service apache2 restart
else
    echo "creating file virtualhost: '$virtual_host'"
    cd /etc/apache2/sites-available/ && echo "<VirtualHost *:80>
    DocumentRoot "/var/www/${domain_name}"
    ServerName www.${domain_name}
    ServerAlias ${domain_name}
    CustomLog "/var/log/apache2/access.${domain_name}.log" common
</VirtualHost>" > $virtual_host && a2ensite $virtual_host && apache2ctl -t && service apache2 restart
fi
