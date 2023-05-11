#!/bin/bash
SERVER=(Ubuntu22-ELK Ubuntu22-NGINX-MYSQLmaster Ubuntu22-NAS Ubuntu22-APACHE-MYSQLslave)

for i in "${SERVER[@]}"
do
    vboxmanage clonevm Ubuntu22 --name $SERVER --mode machine --options KeepNATMACs --options link --register --snapshot Snapshot
    vboxmanage modifyvm $SERVER --memory 4096 --acpi on --cpus 1 --mac-address1 auto
    vboxmanage modifyvm $SERVER --nic1 bridged
    VirtualBoxVM --startvm $SERVER
done


# vboxmanage clonevm Ubuntu22 --name Ubuntu22-NGINX-MYSQLmaster --mode machine --options KeepNATMACs --options link --register --snapshot Snapshot
# vboxmanage modifyvm Ubuntu22-NGINX-MYSQLmaster --memory 2048 --acpi on --cpus 1 --mac-address1 auto
# vboxmanage modifyvm Ubuntu22-NGINX-MYSQLmaster --nic1 bridged

# vboxmanage clonevm Ubuntu22 --name Ubuntu22-NAS --mode machine --options KeepNATMACs --options link --register --snapshot Snapshot
# vboxmanage modifyvm Ubuntu22-NAS --memory 2048 --acpi on --cpus 1 --mac-address1 auto
# vboxmanage modifyvm Ubuntu22-NAS --nic1 bridged

# vboxmanage clonevm Ubuntu22 --name Ubuntu22-APACHE-MYSQLslave --mode machine --options KeepNATMACs --options link --register --snapshot Snapshot
# vboxmanage modifyvm Ubuntu22-APACHE-MYSQLslave --memory 2048 --acpi on --cpus 1 --mac-address1 auto
# vboxmanage modifyvm Ubuntu22-APACHE-MYSQLslave --nic1 bridged


# VirtualBoxVM --startvm Ubuntu22-NGINX-MYSQLmaster
# VirtualBoxVM --startvm Ubuntu22-APACHE-MYSQLslave
# VirtualBoxVM --startvm Ubuntu22-NAS
# VirtualBoxVM --startvm Ubuntu22-ELK