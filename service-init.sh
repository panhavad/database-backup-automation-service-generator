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

clt='y'
interval=0
while [ $clt == 'y' ]
do
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
mkdir /etc/dbbackup/
#create autobackup file
echo '#This was automatically created' > /usr/local/bin/backup-database.sh
echo 'd=`TZ=UTC-7 date +%d%b%y%H%M`' >> /usr/local/bin/backup-database.sh
for DB_NAME in "${DB_NAMES[@]}"
	do
		mkdir '/etc/dbbackup/'$DB_NAME'_BAKUP'
		echo 'pg_dump --file ''"/etc/dbbackup/'$DB_NAME'_BAKUP/$d-'$DB_NAME'.sql" --compress=9 --blobs --dbname=postgresql://'$DB_USER':'$DB_PASS'@'$DB_HOST':'$DB_PORT'/'$DB_NAME >> /usr/local/bin/backup-database.sh
done

#create service file
echo -e "[Unit]\nDescription= Automatic database backup\n[Service]\nType=simple\nRestart=on-failure\nUser=root\nGroup=root\nExecStart=/usr/local/bin/backup-database.sh\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/auto-database-backup.service

#create timer file
echo -e "[Unit]\nDescription= Automation backup database\n[Timer]\n#Everyday at 00:00 Cambodia time\nOnCalendar=*-*-* 23:00:00\nOnActiveSec=1 hour\nPersistent=true\n[Install]\nWantedBy=timers.target" > /etc/systemd/system/auto-database-backup.timer

#activate all created file
chmod 755 /usr/local/bin/backup-database.sh
systemctl daemon-reload
systemctl enable auto-database-backup.service
systemctl restart auto-database-backup.service
systemctl enable auto-database-backup.timer
systemctl restart auto-database-backup.timer

echo "All file have been created. Enjoy your backup."
