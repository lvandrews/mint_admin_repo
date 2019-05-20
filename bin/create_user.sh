#!/usr/bin env

## Lela Andrews May 9, 2019
## Script for creating user accounts with standardized appearance, 
## standardized settings, and access to RAID.
set -e

# default group variable
dgrp="ecoss"

# RAID drive variable
raid="RAID1"

echo "Set up a new user account. Sure.

This script is not made to handle errors. If you make a mistake,
use Ctrl-C to abandon the process and start over.

This command needs to run with sudo to ensure adequate permissions
for creating and modifying a new user account.

Let me collect some info first.

Enter the name of the new user (First Last):
"
    read username

echo "
Enter the userID of the new user:
"
    read userid

# Check if userid already exists. Exit if it does.
    usercheck=$(cat /etc/passwd | cut -f1 -d":" | grep "$userid" || true)

    if [[ ! -z $usercheck ]]; then
        echo "UserID $userid already exists. Exiting.
        $usercheck
        "
        exit 1
#        else
#        echo "valid userid"
    fi

# useradd command to create new account
sudo adduser --disabled-password --gecos "$username" "$userid"

wait

# usermod command to set default group to $dgrp
sudo usermod -g $dgrp -G $dgrp,arb,cdrom "$userid"
wait

# set default password and force it expired
echo -e "Aeiouy12345\nAeiouy12345" | sudo passwd $userid &>/dev/null
wait

sudo chage -d 0 $userid

# create home directory
sudo mkdir /home/$userid/Desktop
sudo chown $userid:$dgrp /home/$userid/Desktop/

# Copy default settings to new account, adjust ownership, set placeholder for first login
echo "Copying files..."
cp /home/$dgrp/.bashrc /home/$userid/
sudo chown $userid:$userid /home/$userid/.bashrc
cp /home/$dgrp/.profile /home/$userid/
sudo chown $userid:$userid /home/$userid/.profile
cp -r /home/$dgrp/.cinnamon/ /home/$userid/
sudo chown -R $userid:$userid /home/$userid/.cinnamon/
cp /home/$dgrp/.cinnamon_settings /home/$userid/
sudo chown -R $userid:$userid /home/$userid/.cinnamon_settings
echo "TRUE" > /home/$userid/.newuser
sudo chown -R $userid:$userid /home/$userid/.newuser
cp -r /home/$dgrp/.local/ /home/$userid/.local/
sudo chown -R $userid:$userid /home/$userid/.local/
cp -r /home/$dgrp/.linuxmint/ /home/$userid/
sudo chown -R $userid:$userid /home/$userid/.linuxmint/

# Copy instruction file and adjust permissions
cp /common/.Desktop_files/Data\ analysis\ information.html /home/$userid/Desktop/
sudo chown $userid:$dgrp /home/$userid/Desktop/Data\ analysis\ information.html
sudo chmod 666 /home/$userid/Desktop/Data\ analysis\ information.html

# Make user directory on RAID and link to user desktop
if [ ! -d /$raid/$userid ]; then
    sudo mkdir /$raid/$userid
    sudo chown $userid:$userid /$raid/$userid
fi

if [ ! -L /home/$userid/Desktop/RAID ]; then
    ln -s /RAID1/$userid/ /home/$userid/Desktop/RAID
    sudo chown $userid:$userid /home/$userid/Desktop/RAID
fi

# Copy conda environment scripts
cp /home/$dgrp/.condarc /home/$userid/
cp /home/$dgrp/.default_env /home/$userid/
sudo chown $userid:$userid /home/$userid/.default_env
cp /home/$dgrp/.q1_env /home/$userid/
sudo chown $userid:$userid /home/$userid/.q1_env

# Report on new user
echo "
New user created.
UserID: $userid
Passwd: Aeiouy12345"

exit 0
