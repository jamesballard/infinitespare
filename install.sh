#!/bin/bash
set -e

export repo=https://github.com/jamesballard/infinitespare/raw/master

main() {
	require_root
	echo Installing Infinite Rooms
	install_system
	install_infiniterooms master prod
	install_infiniterooms master demo
	install_infiniterooms develop dev
	install_moodle 22 demo
	install_moodle 22 dev
}

require_root() {
        if [ $(id -u) -ne 0 ]; then
                echo Installation must be run as root
                exit 1
        fi
}

download() {
	file=$1
	url=$2
	[ -f $file ] || curl -Lnfs -o $file $url
}

# git export
# ideally we'd clone here, but memory requirements are too high
github_export() {
	repo=$1
	branch=$2
	dir=$3
	tmp=/tmp/${repo//\//_}.${branch}.tar.gz

	mkdir -p $dir
	download $tmp https://github.com/$repo/archive/$branch.tar.gz
	tar -zxf $tmp -C $dir --strip=2
}

install_system() {
	echo Setting up users
	download - $repo/users | while read user key; do
		adduser -q $user 2>/dev/null || true
		adduser -q $user admin || true
		
		# Setup SSH authorized_keys file if it doesn't exist
		mkdir -p /home/$user/.ssh
		touch /home/$user/.ssh/authorized_keys
		chown -R $user:$user /home/$user/.ssh
		chmod 600 /home/$user/.ssh/authorized_keys

		# Install SSH public key
		echo "$key" >> /home/$user/.ssh/authorized_keys
	done

	echo Installing dependencies
	apt-get -qqy update
	apt-get -qqy install git mysql-client apache2 libapache2-mod-php5 php5-curl php5-gd php5-ldap php5-mysql php5-xmlrpc wwwconfig-common zip unzip php-pear php5-intl

	echo Setting up host aliases
	download - $repo/hosts >> /etc/hosts

	echo Testing database connectivity
	nc -z -w1 -v -v db.infiniterooms.co.uk 3306

	if ! service apache2 status >/dev/null; then
		echo Starting Apache
		service apache2 start
	fi

	echo Testing Apache
	nc -z -w1 -v -v localhost 80
}

install_infiniterooms() {
	branch=$1
	stage=$2
	echo Installing Infinite Rooms $branch to $stage
	github_export jamesballard/infinitecake $branch /var/www/$stage/infiniterooms
}

install_moodle() {
	version=$1
	stage=$2

	installer=/tmp/moodle-latest-${version}.tgz
	moodle_home=/var/www/$stage/moodle
	moodle_data=/var/moodle/$stage

	echo Installing Moodle $version to $stage
	mkdir -p $moodle_home
	download $installer http://sourceforge.net/projects/moodle/files/Moodle/stable${version}/moodle-latest-${version}.tgz/download
	tar -zxf $installer -C $moodle_home --strip=2

	# Create data store
	mkdir -p $moodle_data
	chown www-data $moodle_data

	# Download configuration file
	download - $repo/moodle/config.php | sed -e "s/\\\$stage = '.*';/\\\$stage = '$stage';/" > $moodle_home/config.php

	# Installing Infinite Rooms Moodle Plugin
	github_export Tantalon/infinitemoodle master $moodle_home/report/infiniterooms
}

main
