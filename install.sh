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
	apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring -y
fi

# Install Nginx
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" \
    | tee /etc/apt/sources.list.d/nginx.list

echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | tee /etc/apt/preferences.d/99nginx

apt-get update
apt-get install nginx -y

if [ ! -d "/etc/nginx/" ]; then
echo "Error: Nginx Install failed."
exit 1
else
	wget https://github.com/nagaeki/nginx-conf/raw/main/nginx.conf -O /etc/nginx/nginx.conf
	wget https://github.com/nagaeki/nginx-conf/raw/main/default.conf -O /etc/nginx/conf.d/default.conf
fi

# Install ACME.SH
if [ ! -d "~/.acme.sh/" ]; then
curl https://get.acme.sh | sh
fi

# Install dhparam
wget https://github.com/internetstandards/dhe_groups/raw/main/ffdhe4096.pem -O /etc/nginx/ffdhe4096.pem

wget https://github.com/nagaeki/nginx-conf/raw/main/template.conf -O /etc/nginx/conf.d/template.conf.tmp

systemctl enable nginx --now