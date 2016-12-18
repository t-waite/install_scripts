#!/bin/bash

# variables
CURRENT_IP=$(curl -4 icanhazip.com)
USER="monkey"

# add user
adduser $USER

# add user to sudoers
usermod -aG sudo $USER

# update / upgrade packages
apt-get update &&  apt-get upgrade -y

# install nginx
apt-get install nginx -y

# open ports for nginx
ufw allow 'Nginx HTTP'
ufw allow 'Nginx HTTPS'
ufw status

# check nginx status
systemctl status nginx

# output current ip address
echo "Current ip address: $CURRENT_IP"

# install docker
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
apt-get update
apt-cache policy docker-engine
apt-get install -y docker-engine

# check docker status
systemctl status docker

# add current user to docker group
usermod -aG docker $USER

# install mongodb
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" |  tee /etc/apt/sources.list.d/mongodb-org-3.2.list
apt-get update
apt-get install -y mongodb-org

# update mongodb conf files
text="[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target

[Service]
User=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongod.conf

[Install]
WantedBy=multi-user.target"

echo "$text" >> /etc/systemd/system/mongodb.service

# start mongodb
systemctl start mongodb
systemctl status mongodb

# enable mongodb at system start
systemctl enable mongodb

# open port for mongodb
ufw allow 27017

# open port for ssh
ufw allow 22

# enable ufw
ufw default deny incoming
ufw default allow outgoing
ufw enable
ufw status

# Next steps
text="Next Steps:
- copy ssh key to new user
- edit ssh conf file: /etc/ssh/sshd_config
    - disallow: PasswordAuthentication,
    - disallow: PermitRootLogin
- check nginx install: $CURRENT_IP
- check user creaton: $USER
- check mongodb installed correctly
- remove this script"

echo "$text"
