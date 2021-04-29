#!/bin/bash
# script0.sh

#On verifie que notre fichier de destination temporaire exist
DOSSIER=/home/save_BD
if [ -d ${DOSSIER} ]; then
sudo rm -rf ${DOSSIER}
echo "Le dossier existe deja, nous l'effacons"
fi
sudo mkdir ${DOSSIER}
echo "Le dossier ${DOSSIER} est crée"
# On liste nos bases de donnees

LISTEBDD=$( echo "show databases" | mysql -uroot -p'codingfactory' )
for BDD in $LISTEBDD; do
# Exclusion des BDD information_schema , mysql et Database
if [[ $BDD != "information_schema" ]] && [[ $BDD != "mysql" ]] && [[ $BDD != "Database" ]] && [[ $BDD != "sys" ]] && [[ $BDD != "performance_schema" ]];  then
# Emplacement du dossier ou nous allons stocker les bases de données, un dossier par base de données
CHEMIN=/home/save_BD
sudo mkdir $CHEMIN
# On backup notre base de donnees
sudo mysqldump -u root $BDD -p'codingfactory' > $CHEMIN/$BDD.sql
echo "|Sauvegarde de la base de donnees $BDD.sql ";
fi
done
cd ../../save_BD/
sudo tar czvf `date -I`_codingfactory.tgz /var/www/codingfactory/wp-content/uploads/ *.sql
bool='false'
while [ $bool = false ]; do
read -p "Saisir le nom_utilisateur@ip_machine : " server
sudo scp -r ./`date -I`_codingfactory.tgz $server:~
if [ $? -ne 0 ]
then
bool='false'
else
bool='true'
fi
ssh $server sudo -S mv `date -I`_codingfactory.tgz /var/backups/
if [ $? -ne 0 ]
then
bool='false'
elif [ $bool = 'true' ]
then
bool='true'
else
bool='false'
fi
done
