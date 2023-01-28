#!/bin/bash

STATUS=$(sestatus | grep 'SELinux status' | cut -d':' -f 2 | awk '{print $ 1}')
ACT=$(getenforce)
EPEL=$(rpm -qa | grep epel-release)
NGX=$(rpm -qa | grep nginx)
APCH=$(rpm -qa | grep httpd)
UTIL=$(rpm -qa | grep yum-utils*)
#HTCTL=$(systemctl status httpd | grep Active | cut -d ':' -f 2 | cut -d ' ' -f 2)

if [ $STATUS == "enabled" ]
        then
                echo "Отключаю SELinux"
                sudo setenforce 0
        else
                echo "SELinux не работает"
fi

case "$ACT" in

        Enforcing )
                echo "SELinux активирована и находится в режиме Enforcing, режим по умолчанию."
                sudo sed -i 's/^SELINUX=enforcing/SELINUX=disable/g' /etc/selinux/config
                echo "SELinux отключен"
                ;;

        Permissive )
                echo "SELinux активен и находиться в режиме Permissive, нарушения безопасности не блокируются, журнал пишится.";;

        Disable )
                echo "SELinux отключен.";;
esac

echo "Приступим к установки NGINX и APACHE."

if [ "X$EPEL" == "X" ]
        then
                sudo yum install epel-release -y
        else 
                echo "epel-release уже установлен."            
fi

if [ "X$NGX" == "X" ]
        then
                sudo yum install nginx -y
        else 
                echo "NGINX уже установлен."              
fi

if [ "X$APCH" == "X" ]
        then
                sudo yum install httpd -y
        else 
                echo "httpd уже установлен."              
fi

if [ "X$UTIL" == "X" ]
    then
        sudo yum install yum-utils -y
    else
        echo "yum-utils уже установлен."
fi

# echo "На какой порт поменяем порт 80 в httpd?"
# read PRT

sudo sed -i 's/^Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf
httpdctl -t

if [ $? -eq 0 ]
        then
                echo "Запустим NGINX и APACHE"

                for i in nginx httpd
                    do
                        sudo systemctl enable -- now i
                    done
        else
                echo "Остановка скрипта."
                exit

# systemctl status nginx
# systemctl status httpd

sudo tee <<EOF /usr/share/nginx/modules/myweb.conf > /dev/null
upstream backend {
    server 127.0.0.1:8080 weigth=2;
    server 127.0.0.1:8081;
    server 127.0.0.1:8082;

}

    location / {
      proxy_pass http://backend;
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_next_upstream error timeout http_404;
    }
EOF

nginx -t 
httpdctl -t

