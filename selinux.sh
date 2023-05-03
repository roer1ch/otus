#!/bin/bash

STATUS=$(sestatus | grep 'SELinux status' | cut -d':' -f 2 | awk '{print $1}')
ACT=$(getenforce)
MYID=$(id -u)


if [ $STATUS == "enabled" ]
        then
                echo "SELinux работает"
        else
                echo "SELinux не работает"
fi

case "$ACT" in

        Enforcing )
                echo "SELinux активирована и находится в режиме Enforcing, режим по умолчанию.";;

        Permissive )
                echo "SELinux активен и находиться в режиме Permissive, нарушения безопасности не блокируются, журнал пишится.";;

        Disable )
                echo "SELinux отключен.";;
esac

echo "Активировать или деактивировать SELinux? Введите 0 или 1, где 0 - это деактивировать."
read STS

if [ $MYID -eq 0  ]
        then
                if [ $STS -eq 0  ]
                        then
                                sudo setenforce 0
                                sudo sed -i 's/^SELINUX=enforcing/SELINUX=disable/g' /etc/selinux/config
                        else
                                sudo setenforce 1
                                sudo sed -i 's/^SELINUX=disable/SELINUX=enforcing/g' /etc/selinux/config
                fi
        else
                echo "У вас недостаточно прав. Запустите скрипт от пользователя с привелегированными правами."
fi