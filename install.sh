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
	echo + $user
	adduser $user admin

	mkdir -p /home/$user/.ssh
	touch /home/$user/.ssh/authorized_keys
	chown -R $user:$user /home/$user/.ssh
	chmod 600 /home/$user/.ssh/authorized_keys

	echo "$key" | tee -a /home/$user/.ssh/authorized_keys > /dev/null
done
