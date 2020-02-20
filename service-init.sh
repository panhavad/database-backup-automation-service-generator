#!/bin/bash

# Author : Duk Panhavad
# Copyright (c) VAD

echo '-----------------------------------'
echo '- Setting up Auto Database Backup -'
echo '-----------------------------------'
echo '                                   '

echo '--> Database connection information'

echo 'Enter database host:'
read DB_HOST
echo 'Enter database port:'
read DB_PORT
echo 'Enter database username:'
read DB_USER
echo 'Enter database password:'
read DB_PASS

echo '--> Database backup selection'

echo 'Enter number of database want to backup:'
clt='y'
interval=0
while [ $clt == 'y' ]
do
	echo $interval
	echo 'Enter database name:'
	read DB_NAMES[$interval]
	echo 'Do you want to add more database?
	([y]Yes, [n]No)'
	read clt
	if [ $clt == 'n' ]
	then
		clt='y' #reset state
		break
	else
		interval=`expr $interval + 1`
	fi
done
echo '#This was automatically created' > backup.sh
echo 'd=`TZ=UTC-7 date +%d%b%y%H%M`' >> backup.sh
for DB_NAME in "${DB_NAMES[@]}"
	do
		echo 'pg_dump --file ''"/etc/dbbackup/'$DB_NAME'_BAKUP/$d-'$DB_NAME'.sql" --compress=9 --blobs --dbname=postgresql://'$DB_USER':'$DB_PASS'@'$DB_HOST':'$DB_PORT'/'$DB_NAME >> backup.sh
done