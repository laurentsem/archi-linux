<VirtualHost *:80>
	DocumentRoot "/var/www/DOMAIN_NAME"
	ServerName www.DOMAIN_NAME
	ServerAlias DOMAIN_NAME
	CustomLog "/var/log/apache2/access.DOMAIN_NAME.log" common
</VirtualHost>
