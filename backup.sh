#!/bin/bash
# script0.sh

#On verifie que notre fichier de destination temporaire exist
GetDB() {
	MDP="$1"
	DOSSIER="$2"
		if [ -d ${DOSSIER} ]
		then
			sudo rm -rf ${DOSSIER}
			echo "Le dossier existe deja, nous l'effacons"
		fi
		sudo mkdir $DOSSIER
		echo "Le dossier save_BD est crée"
		# On liste nos bases de donnees
		LISTEBDD=$( echo "show databases" | mysql -uroot -p$MDP )
		for BDD in $LISTEBDD; do
		# Exclusion des BDD information_schema , mysql et Database
			if [[ $BDD != "information_schema" ]] && [[ $BDD != "mysql" ]] && [[ $BDD != "Database" ]] && [[ $BDD != "sys" ]] && [[ $BDD != "performance_schema" ]];  then 
				# On backup notre base de donnees
				sudo mysqldump -u root $BDD -p$MDP > $DOSSIER$BDD.sql
				echo "Sauvegarde de la base de donnees $BDD.sql ";
			fi
			done
}

SendBackUpToVm(){
	DOSSIER="$1"
	cd $DOSSIER
	sudo tar czvf `date -I`_codingfactory.tgz --absolute-names /var/www/codingfactory/wp-content/uploads/ *.sql
	commandDone='false'
	while [ $commandDone = false ]; do
		read -p "Saisir le nom_utilisateur@ip_machine : " server
		sudo scp -r ./`date -I`_codingfactory.tgz $server:~
		if [ $? -ne 0 ]
		then
			commandDone='false'
		else
			commandDone='true'
		fi
		ssh $server sudo -S mv `date -I`_codingfactory.tgz /var/backups/
		if [ $? -ne 0 ]
		then
			commandDone='false'
		elif [ $commandDone = 'true' ]
		then
			commandDone='true'
		else
			commandDone='false'
		fi
		done
}

DOSSIER='../../../var/tmp/save_BD/'
read -p "Saisir le mot de passe de la base de données: " MDP

GetDB $MDP $DOSSIER
SendBackUpToVm $DOSSIER
