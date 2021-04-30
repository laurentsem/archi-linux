#!/bin/bash
# deploy_website.sh

while getopts 'd:b:u:p:' c
do
  case $c in
    d) domain_name=$OPTARG ;;
    b) name_db=$OPTARG ;;
    u) user_db=$OPTARG ;;
    p) pw_db=$OPTARG ;;
  esac
done

if [ -z $domain_name ]||[ -z $name_db ]||[ -z $user_db ]||[ -z $pw_db ]; then
	echo "don't forget it's: ./deploy_website.sh -d <domain_name> -b <name_db> -u <user_db> -p <pw_db>"
	exit
fi

group="www-data"
user="${domain_name%%.*}"
virtual_host="${domain_name}.conf"
tmp_virtualhost="`pwd`/tmp_virtualhost.sh"

set_group () {
	group=$1

	if grep "^$group" /etc/group > /dev/null; then
		echo "group: '$group' exist, add permissions "
		sudo chown -R $group:$group /var/www
	else
		echo "creating group: '$group'"
		groupadd $group
    		sudo chown -R $group:$group /var/www
	fi
}

set_user () {
	group=$1
	user=$2

	if grep "^$user" /etc/passwd > /dev/null; then
		echo "user: '$user' exist, add $user in $group "
		gpasswd -a $user $group
	else
		echo "creating user: '$user'"
		useradd $user && gpasswd -a $user $group
	fi
}

set_directory_domain () {
	domain_name=$1

	if [ -e /var/www/$domain_name ]; then
		echo "directory domain: '$domain_name' exist, recreate $domain_name "
		rm -r /var/www/$domain_name
		cd /var/www/ && wget https://fr.wordpress.org/latest-fr_FR.tar.gz && tar -zxf latest-fr_FR.tar.gz && mv wordpress/ $domain_name && rm -r latest-fr_FR.tar.gz 
	else
		echo "creating directory domain: '$domain_name'"
		cd /var/www/ && wget https://fr.wordpress.org/latest-fr_FR.tar.gz && tar -zxf latest-fr_FR.tar.gz && mv wordpress/ $domain_name && rm -r latest-fr_FR.tar.gz 
	fi
}

set_wpconfig () {
	name_db=$1
	user_db=$2
	pw_db=$3
	wp_config_sample="/var/www/$domain_name/wp-config-sample.php"
	wp_config="/var/www/$domain_name/wp-config.php"

	if [ -e $wp_config_sample ]; then
		echo "create file wp-config.php"
		sed -e "s/votre_nom_de_bdd/$name_db/g" -e "s/votre_utilisateur_de_bdd/$user_db/g" -e "s/votre_mdp_de_bdd/$pw_db/g" $wp_config_sample > $wp_config
	else
		echo "$wp_config_sample not exist"
		exit
	fi
}

set_virtual_host () {
	domain_name=$1
	virtual_host=$2
	tmp_virtualhost=$3

	if [ -e /etc/apache2/sites-available/$virtual_host ]; then
		echo "file virtualhost: '$virtual_host' exist, recreate $virtual_host "
		rm -r /etc/apache2/sites-available/$virtual_host
		sed -e "s/DOMAIN_NAME/$domain_name/g" $tmp_virtualhost > /etc/apache2/sites-available/$virtual_host && a2ensite $virtual_host && apache2ctl -t && service apache2 restart
	else
		echo "creating file virtualhost: '$virtual_host'"
		sed -e "s/DOMAIN_NAME/$domain_name/g" $tmp_virtualhost > /etc/apache2/sites-available/$virtual_host && a2ensite $virtual_host && apache2ctl -t && service apache2 restart
	fi
}

create_website () {
	group=$1
	user=$2
	domain_name=$3
	virtual_host=$4
	tmp_virtualhost=$5
	name_db=$6
        user_db=$7
        pw_db=$8

	set_group $group
	set_user $group $user
	set_directory_domain $domain_name
	set_wpconfig $name_db $user_db $pw_db
	set_virtual_host $domain_name $virtual_host $tmp_virtualhost
}

create_website $group $user $domain_name $virtual_host $tmp_virtualhost $name_db $user_db $pw_db
