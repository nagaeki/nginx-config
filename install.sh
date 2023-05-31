#!/bin/bash

Nginx_Dir="/etc/nginx"

result=$(id | awk '{print $1}')
if [[ $result != "uid=0(root)" ]]; then
	echo "Use Root User, Please."
	exit 1
fi

if [[ $(uname -s) != Linux ]]; then
	echo "Use Linux System, Please."
	exit 1
fi

res=`which apt-get 2>/dev/null`
if [[ "$?" != "0" ]]; then
	apt update
	apt upgrade -y
	apt autoremove -y
	apt-get install -y apt-transport-https lsb-release ca-certificates socat
fi

# Install Nginx
curl -sSLo /usr/share/keyrings/deb.sury.org-nginx-mainline.gpg https://packages.sury.org/nginx-mainline/apt.gpg
curl -sSLo /usr/share/keyrings/deb.sury.org-nginx.gpg https://packages.sury.org/nginx/apt.gpg

sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-nginx-mainline.gpg] https://packages.sury.org/nginx-mainline/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/nginx-mainline.list'
sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-nginx.gpg] https://packages.sury.org/nginx/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/nginx.list'

apt-get update
apt-get install nginx-core nginx-common nginx nginx-full -y

if [ ! -d "/etc/nginx/" ]; then
echo "Error: Nginx Install failed."
exit 1
else
	# Create Nginx Cache Dir
	mkdir -p /cache/
	# Create Nginx Logs Dir
	mkdir -p /etc/nginx/logs/error/
	mkdir -p /etc/nginx/logs/access/
	# Creat Nginx Basic Dir
	mkdir -p /etc/nginx/include/
	mkdir -p /etc/nginx/access/
	# Create ACME Cert Dir
	mkdir -p /var/cert/
    
	chmod -R 775 /cache/
	chmod -R 775 /var/cert/

fi

# Install ACME.SH
if [ ! -d "~/.acme.sh/" ]; then
curl https://get.acme.sh | sh
fi

# Install dhparam 
curl -sS https://github.com/internetstandards/dhe_groups/raw/main/ffdhe4096.pem > /etc/nginx/ffdhe4096.pem