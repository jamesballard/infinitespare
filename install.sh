#!/bin/bash
set -e

repo=https://github.com/jamesballard/infinitespare/raw/master
MOODLE_VERSION=22

download() {
	file=$1
	url=$2
	[ ! -f $file ] || check="-z $file"
	curl -Lnfs -o $file $check $url
}

echo Installing Infinite Rooms

if [ $(id -u) -ne 0 ]; then
	echo Installation must be run as root
	exit 1
fi

echo Setting up users
download - $repo/users | while read user key; do
	adduser -q $user || true
	adduser -q $user admin || true
	
	# Setup SSH authorized_keys file if it doesn't exist
	mkdir -p /home/$user/.ssh
	touch /home/$user/.ssh/authorized_keys
	chown -R $user:$user /home/$user/.ssh
	chmod 600 /home/$user/.ssh/authorized_keys

	# Install SSH public key
	echo "$key" >> /home/$user/.ssh/authorized_keys
done

echo Installing required packages
apt-get -qqy update
apt-get -qqy install git mysql-client apache2 libapache2-mod-php5 php5-curl php5-gd php5-ldap php5-mysql php5-xmlrpc wwwconfig-common zip unzip php-pear php5-intl

echo Setting up host aliases
cat >> /etc/hosts <<EOF
10.234.133.136 db.infiniterooms.co.uk
EOF

echo Testing database connectivity
nc -z -w1 -v -v db.infiniterooms.co.uk 3306

if ! service apache2 status; then
	echo Starting Apache
	service apache2 start
fi

echo Testing Apache
nc -z -w1 -v -v localhost 80

echo Installoing Infinite Rooms
stage=prod
git clone git@github.com:jamesballard/infinitecake.git /var/www/$stage/infiniterooms

echo Downloading Moodle
download /tmp/moodle.tgz http://sourceforge.net/projects/moodle/files/Moodle/stable${MOODLE_VERSION}/moodle-latest-${MOODLE_VERSION}.tgz/download

echo Installing Moodle
mkdir -p /var/www/$stage/moodle
tar -zxf /tmp/moodle.tgz -C /var/www/$stage/moodle --strip=2

echo Configuring Moodle
# Create data store
mkdir -p /var/moodle
chown www-data /var/moodle
# Download configuration file
download /var/www/moodle/config.php $repo/moodle/config.php

echo Installing Infinite Rooms Moodle Plugin
git clone git@github.com:Tantalon/infinitemoodle.git /var/www/moodle/report/infiniterooms

