#!/bin/bash

echo "Для корректной работы скрипта сервера MySQL должны называться: Master и Slave."
echo "Используейте команду hostnamectl set-hostname ИМЯ, а так же рестаните сервер."
# Скрипт как бы сразу становиться не универсальным, но думаю новичку можно простить:) Потом можно и поправить.
# Но если управлять несколькими базами данных, то лучше конфигурировать Ансиблом
BINLOG=(mysql -u root -p"$1" -e "SHOW VARIABLES LIKE '%binlog%';" | grep binlog_format | awk '{print $2}')

if [ -n "$1" ]
then
    echo "Пароль принят"
else
    echo "Вы не ввели переменную '$1'"
    exit
fi
NAME=$(hostname)
TEMPPASS=$(sudo cat /var/log/mysqld.log | grep "A temporary password" | cut -d ':' -f 4)
#Testpass1$ 9j2oTlic;aJr
#отключение файрвола
systemctl stop firewalld
systemctl disable firewalld

#yum update && yum upgrade
# Установка репозитория
rpm -Uvh https://repo.mysql.com/mysql80-community-release-el7-7.noarch.rpm
# Включение репозитория
sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo
# Установка  MySQL
yum --enablerepo=mysql80-community install mysql-community-server -y
# Включение и автозагрузка
systemctl start mysqld && systemctl enable mysqld

#echo "Придумайте пароль для MySQL"
#read PASSW
#$PASSW > passw
#MYPASSW=$(cat passw)
#mysql_secure_installation
#mysql -uroot -p$TEMPPASS < createdatabase.sql

if [ "$NAME" == "master" ]
then
    mysql -u root -p"$TEMPPASS" -e "use mysql; ALTER USER 'root'@'localhost' IDENTIFIED WITH 'caching_sha2_password' BY 'Testpass1$';"
fi
#mysql -uroot -p -e "DROP USER ''@'localhost';"


if [ "$NAME" == "master" ]
then
    if [ "$BINLOG" == "ROW" ]
    then
        echo "Все хорошо."
    else
        echo "Проблемы с binlog"
        #exit
    fi
else
    echo "Ваш сервер '$NAME'"
fi
DB_PASSWORD="Testpass1$"
#DB_PASSWORD=$1
DB_USER="root"
# Создаем пользователя, Даем ему права и закрывает все таблицы
if [ "$NAME" == "master" ]
then
    mysql -u$DB_USER -p$DB_PASSWORD -e "CREATE USER 'repl'@'%' IDENTIFIED WITH 'caching_sha2_password' BY 'oTUSlave#2020';
                                    GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
    FLUSH TABLES WITH READ LOCK;"
fi
#  Проверяем статус binlog
binfile=$(mysql -u$DB_USER -p$DB_PASSWORD -e "SHOW MASTER STATUS;" | awk ' NR == 2 {print $1}')
position=$(mysql -u$DB_USER -p$DB_PASSWORD -e "SHOW MASTER STATUS;" | awk ' NR == 2 {print $2}')
if [ "$NAME" == "master" ]
then
    echo "Сохраним результат в файл для применения на slave"
    echo $binfile > binlog
    echo $position > position
fi
#
if [ "$NAME" == "slave"]
then
    mysql -u$DB_USER -p$DB_PASSWORD -e "SHOW GLOBAL VARIABLES LIKE 'caching_sha2_password_public_key_path';
    SHOW STATUS LIKE 'Caching_sha2_password_rsa_public_key'\G"
fi
# Смена ID
if [ "$NAME" != "master" ]
then
    echo 'server_id=2' >> /etc/my.cnf;
    sleep 1;
    systemctl restart mysql
else
    echo "Cервер '$NAME'"
fi

if [ "$NAME" == "slave"]
then
    mysql -u$DB_USER -p$DB_PASSWORD -e "STOP SLAVE;
                                    CHANGE MASTER TO MASTER_HOST='192.168.88.121', MASTER_USER='repl', MASTER_PASSWORD='oTUSlave#2020', MASTER_LOG_FILE='binlog.000001', MASTER_LOG_POS=5876, GET_MASTER_PUBLIC_KEY = 1;
                                    START SLAVE;
    SHOW SLAVE STATUS\G"
else
    echo "Cервер '$NAME'"
fi

# У меня проблема в передаче пароля. Как можно безопасно передать пароль? Использовать OpenSSL и sshpass?
# Пришлось убрать везде переменную $1 и вводить\вставлять пароль руками :(
# mysql_secure_installation - делал вручную
# "$TEMPPASS" -- как-то странно отрабатывает, то берет пароль из лога, то не берет.
# Скрипт пускаю на каждом сервере

# BACKUP SCRIPT
#mysql -u root --password="Testpass1$" -e "STOP SLAVE;"
backup_dir="backup/mysql"
mysql_user="root"
mysql_password="Testpass1$"
databases=$(mysql -u"$mysql_user" -p"$mysql_password" --skip-column-names -e "SHOW DATABASES;" | awk '{print $1}')

if [ ! -d "$backup_dir" ]; then
    mkdir -p "$backup_dir"
fi

for s in $databases;
do
    if [ ! -d "$backup_dir/$s" ]; then
        mkdir -p "$backup_dir/$s"
    fi
    
    tables=$(mysql -u"$mysql_user" -p"$mysql_password" --skip-column-names -e "USE $s; SHOW TABLES;" | awk '{print $1}')
    
    for i in $tables;
    do
        if [ ! -d "$backup_dir/$s/$i" ]; then
            mkdir -p "$backup_dir/$s/$i"
        fi
        mysqldump --add-drop-table --add-locks `
        `--create-options --disable-keys --extended-insert `
        `--single-transaction --set-charset --events --routines `
        `--triggers --quick --all-databases --master-data=2 `
        `-u"$mysql_user" -p"$mysql_password" $s $i | gzip > "$backup_dir/$s/$i/${i}_$(date +%Y%m%d).sql.gz"
    done
done
#mysql -u root --password="Testpass1$" -e "START SLAVE;"

#!/bin/bash

# Variables
backup_dir="backup/mysql"
mysql_user="root"
mysql_password="password"

# Create the backup directory if it doesn't exist
if [ ! -d "$backup_dir" ]; then
    mkdir -p "$backup_dir"
fi

# Get a list of all databases
databases=$(mysql -u"$mysql_user" -p"$mysql_password" -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)")

# Backup each database
for db in $databases; do
    # Create a subfolder for the database
    if [ ! -d "$backup_dir/$db" ]; then
        mkdir -p "$backup_dir/$db"
    fi
    
    # Get a list of all tables in the database
    tables=$(mysql --user="$mysql_user" --password="$mysql_password" -e "USE $db; SHOW TABLES;" | awk '{print $1}' | grep -v '^Tables')
    
    # Backup each table in the database
    for table in $tables; do
        # Create a subfolder for the table
        if [ ! -d "$backup_dir/$db/$table" ]; then
            mkdir -p "$backup_dir/$db/$table"
        fi
        
        # Backup the table
        mysqldump --user="$mysql_user" --password="$mysql_password" $db $table | gzip > "$backup_dir/$db/$table/${table}_$(date +%Y%m%d).sql.gz"
    done
done



#!/bin/bash

DB_USER="root"
DB_PASSWORD="Testpass1$"
DB_NAMES=(mysql -N -e "SHOW DATABASES;")
BACKUP_DIR="backups"

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir $BACKUP_DIR
fi

for DB_NAME in "${DB_NAMES[@]}";
do
    TABLES=$(mysql -u $DB_USER -p$DB_PASSWORD -Bse "SHOW TABLES IN $DB_NAME")
    for TABLE in $TABLES;
    do
        BACKUP_FILE="$BACKUP_DIR/$DB_NAME-$TABLE-$(date +%Y%m%d-%H%M%S).sql"
        mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME $TABLE > $BACKUP_FILE
        echo "Backup of $DB_NAME-$TABLE completed, file: $BACKUP_FILE"
    done
done

