#!/bin/bash

repo=https://github.com/jamesballard/infinitespare/raw/master

echo Installing Infinite Rooms

if [ $(id -u) -ne 0 ]; then
	echo
	echo Installation must be run as root
	exit 1
fi

echo
echo Setting up users
curl -Lnfs $repo/users | while read user key; do
	adduser -q $user
	adduser -q $user admin
	
	# Setup SSH authorized_keys file if it doesn't exist
	mkdir -p /home/$user/.ssh
	touch /home/$user/.ssh/authorized_keys
	chown -R $user:$user /home/$user/.ssh
	chmod 600 /home/$user/.ssh/authorized_keys

	# Install SSH public key
	echo "$key" >> /home/$user/.ssh/authorized_keys
done
