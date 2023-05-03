#!/bin/bash

vboxmanage clonevm Ubuntu22 --name Ubuntu22-ELK --mode machine --options KeepNATMACs --options link --register --snapshot Snapshot
vboxmanage modifyvm Ubuntu22-ELK --memory 4096 --acpi on --cpus 1 --mac-address1 auto
vboxmanage modifyvm Ubuntu22-ELK --nic1 bridged

vboxmanage clonevm Ubuntu22 --name Ubuntu22-NGINX-MYSQLmaster --mode machine --options KeepNATMACs --options link --register --snapshot Snapshot
vboxmanage modifyvm Ubuntu22-ELK --memory 2048 --acpi on --cpus 1 --mac-address1 auto
vboxmanage modifyvm Ubuntu22-ELK --nic1 bridged

vboxmanage clonevm Ubuntu22 --name Ubuntu22-NAS --mode machine --options KeepNATMACs --options link --register --snapshot Snapshot
vboxmanage modifyvm Ubuntu22-ELK --memory 2048 --acpi on --cpus 1 --mac-address1 auto
vboxmanage modifyvm Ubuntu22-ELK --nic1 bridged

vboxmanage clonevm Ubuntu22 --name Ubuntu22-APACHE-MYSQLslave --mode machine --options KeepNATMACs --options link --register --snapshot Snapshot
vboxmanage modifyvm Ubuntu22-ELK --memory 2048 --acpi on --cpus 1 --mac-address1 auto
vboxmanage modifyvm Ubuntu22-ELK --nic1 bridged


VirtualBoxVM --startvm Ubuntu22-NGINX-MYSQLmaster
VirtualBoxVM --startvm Ubuntu22-APACHE-MYSQLslave
VirtualBoxVM --startvm Ubuntu22-NAS
VirtualBoxVM --startvm Ubuntu22-ELK


ssh osboxes@

cp ./00-installer-config.yaml /etc/netplan/00-installer-config.yaml
ssh-copy-id osboxes@192.168.88.120

