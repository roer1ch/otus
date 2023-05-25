ssh osboxes@

cp ./00-installer-config.yaml /etc/netplan/00-installer-config.yaml
ssh-copy-id osboxes@192.168.88.120

Создать пользователя на хостах
useradd -u 20000 -s /bin/bash -m -d /home/agp agp
mkdir /home/agp/.ssh
touch /home/agp/.ssh/authorized_keys
chown -R agp:agp /home/agp
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/+lfzRr5Zk3YzG8szEf8Coxi0TiClXfNOuzR8Knw461K0xVZEZwSivi+5zusmavFEcm5gClWbXVoX+CeOjjCRVWRvZVYD38ohi/0bkQD4SX+hk3DSwpUfCoeUaoArPPG87zDGh3TXgOG+/lIUJRJzblmThX8BouogmiUDvAkehTXCEL4deap15ocLiCmdsPnJzW932npU5A34v+yWgDrG7ANe8Gwa28pg3Vo6omgoqGvIOxZECWNPgg6+NTp/LwoIn/9jKh7SqFtPlUZZNYulRtPGcF8YML6B/7Y2HyHxMQqzVOwua7Lu53kHyhBN8VF6A797vVhHr4uz0fQsBaR8JZXPFnVssLfuV9e4E7mr2x9y1HFDu5KIRj+d/VW8eg5cWMUdPiLF6eEboWisMnUXTHUKyTw3AnqxALaeN7MLTtgPEy3TDZ45zpcJKcSQxHFCVMofqgA7AAMDRLIzjj3stbwwmWbUPMyZfCvJjR+1BWJcj0xarrTjIdh0JFGHlis= mak@iMac.local" > /home/agp/.ssh/authorized_keys
touch /etc/sudoers.d/agp
echo "agp ALL=(root) NOPASSWD: ALL" > /etc/sudoers.d/agp



1. Обновляет кэш пакетов командой apt update.
2. Устанавливает список пакетов: apt-transport-https, ca-certificates, curl, gnupg-agent, software-properties-common.
3. Добавляет GPG-ключ для репозитория Docker.
4. Добавляет репозиторий Docker в список источников пакетов APT.
5. Устанавливает пакеты Docker: docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin.
6. Проверяет, что служба Docker запущена и включена.
7. Создает группу "docker", если её ещё нет.
8. Добавляет пользователя "agp" в группу "docker".

