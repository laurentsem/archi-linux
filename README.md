# archi-linux

## Exécuter un script
:warning: avant d'exécuter un script, il faut le rendre exécutable :
```
chmod +x nom_du_script
```

Pour exécuter un script : 
```
./nom_du_script
```
### deploy_website.sh $nom_domaine
Permet de déployer Wordpress dans un nom de domaine et lancer le site web.
Les packages suivants seront nécessaires au bon fonctionnement du script. Veuillez à faire manuellement vos configurations :
```
    apache2
    php
    mysql-server
```

Ajouter le nom de domaine dans /etc/hosts :
```
adresse_ip www.$nom_domaine $nom_domaine
```
### monitor_website.sh -d nom_domaine
Permet de bannir les adresses IP dont les connexions au site web sont faux. 

### backup.sh
Permet de sauvegarder la base de données du site ainsi que le dossier 'uploads' de Wordpress dans une archive sur un serveur backup. 