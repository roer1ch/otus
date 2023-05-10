#!/bin/bash
echo Name ROLES
read Name
cd ./
mkdir -p roles/$Name/vars
mkdir -p  roles/$Name/tasks
mkdir -p roles/$Name/files
touch roles/$Name/vars/main.yaml
touch roles/$Name/tasks/main.yaml
