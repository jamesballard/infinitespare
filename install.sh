#!/bin/bash

repo=https://github.com/jamesballard/infinitespare/raw/master

echo Installing Infinite Rooms

echo
echo Setting up users
curl -Ln $repo/users.csv | while read user key; do
	echo + $user
	sudo adduser $user admin

	sudo mkdir -p /home/$user/.ssh
	sudo touch /home/$user/.ssh/authorized_keys
	sudo chown -R $user:$user /home/$user/.ssh
	sudo chmod 600 /home/$user/.ssh/authorized_keys

	echo "$key" | sudo tee -a /home/$user/.ssh/authorized_keys > /dev/null
done

