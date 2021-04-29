#!/bin/bash
# script0.sh

#On verifie que notre fichier de destination temporaire exist
DOSSIER=/home/save_BD
if [ -d ${DOSSIER} ]; then
	sudo rm -rf ${DOSSIER}
	echo "Le dossier existe déja, nous l'effacons"
fi
sudo mkdir ${DOSSIER}
echo "Le dossier ${DOSSIER} est crée"
# On liste nos bases de données

LISTEBDD=$( echo "show databases" | mysql -uroot -p'codingfactory' )
for BDD in $LISTEBDD; do
	# Exclusion des BDD information_schema , mysql et Database
	if [[ $BDD != "information_schema" ]] && [[ $BDD != "mysql" ]] && [[ $BDD != "Database" ]] && [[ $BDD != "sys" ]] && [[ $BDD != "performance_schema" ]];  then
		# Emplacement du dossier ou nous allons stocker les bases de données, un dossier par base de données
		  CHEMIN=/home/save_BD/$BDD
		  sudo mkdir $CHEMIN
		  # On backup notre base de donnees
		    sudo mysqldump -u root $BDD -p'codingfactory' > $CHEMIN/$BDD.sql
		    echo "|Sauvegarde de la base de donnees $BDD.sql ";
	fi
done
