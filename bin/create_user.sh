#!/usr/bin/env bash

## Lela Andrews May 9, 2019
## Script for creating user accounts with standardized appearance, 
## standardized settings, and access to RAID.
set -e

## Find scripts and repository location.
    scriptdir="$( cd "$( dirname "$0" )" && pwd )"
    repodir=`dirname $scriptdir`
    filesdir="$repodir/home_directory_files"
    htmldir="$repodir/html"
    initdir="$repodir/collected"

# Check if install has been run.
    initrun=$(cat $repodir/.initrun)
    if [ "$initrun" == "FALSE" ]; then
        echo "
The install.sh script has not been run. Navigate to the repository
directory and run install.sh (bash install.sh) to collect files
necessary for user account creation. Once done, you can use this
script to create user accounts.

Exiting.
        "
        exit 1
    fi

# Initial dialogue and collect default group and RAID information
echo "Set up a new user account. Sure.

This script is not made to handle errors. If you make a mistake,
use Ctrl-C to abandon the process and start over.

This command needs to run with sudo to ensure adequate permissions
for creating and modifying a new user account.
"
sleep 1s

echo "Enter the name of the default group on your system
(e.g. enggen or ecoss):
"
read dgrp

echo "Enter the name of the RAID drive on your system
(e.g. RAID1 or RAID5):
"
read raid

echo "Please check these default variables. If they are incorrect,
correct them before proceeding further.

Default group: $dgrp
RAID drive: $raid

Are these variables correct (y/n)?
"
    read yn
if [ "$yn" == "n" ]; then
    echo "
Exiting.
"
    exit 1
    elif [ "$yn" != "n" ] && [ "$yn" != "y" ]; then
        echo "
Sorry, I don't understand. Exiting.
"
        exit 1
    elif [ "$yn" == "y" ]; then
        echo "
Great!
"
fi

echo "Let me collect some info first.

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
cp $initdir/.bashrc /home/$userid/
sudo chown $userid:$userid /home/$userid/.bashrc
cp $initdir/.profile /home/$userid/
sudo chown $userid:$userid /home/$userid/.profile
cp -r $initdir/.cinnamon/ /home/$userid/
sudo chown -R $userid:$userid /home/$userid/.cinnamon/
cp $initdir/.cinnamon_settings /home/$userid/
sudo chown -R $userid:$userid /home/$userid/.cinnamon_settings
echo "TRUE" > /home/$userid/.newuser
sudo chown -R $userid:$userid /home/$userid/.newuser
cp -r $initdir/.local/ /home/$userid/.local/
sudo chown -R $userid:$userid /home/$userid/.local/
cp -r $filesdir/.linuxmint/ /home/$userid/
sudo chown -R $userid:$userid /home/$userid/.linuxmint/

# Copy instruction file and adjust permissions
cp $htmldir/Data\ analysis\ information.html /home/$userid/Desktop/
sudo chown $userid:$dgrp /home/$userid/Desktop/Data\ analysis\ information.html
sudo chmod 666 /home/$userid/Desktop/Data\ analysis\ information.html

# Make user directory on RAID and link to user desktop
if [ ! -d /$raid/$userid ]; then
    sudo mkdir /$raid/$userid
    sudo chown $userid:$dgrp /$raid/$userid/
    sudo chmod 775 /$raid/$userid/
fi

if [ ! -L /home/$userid/Desktop/RAID ]; then
    ln -s /$raid/$userid/ /home/$userid/Desktop/RAID
    sudo chown $userid:$userid /home/$userid/Desktop/RAID
fi

# Copy conda environment scripts
cp $initdir/.condarc /home/$userid/
cp $filesdir/.default_env /home/$userid/
sudo chown $userid:$userid /home/$userid/.default_env
cp $filesdir/.q1_env /home/$userid/
sudo chown $userid:$userid /home/$userid/.q1_env

# Report on new user
echo "
New user created.
UserID: $userid
Passwd: Aeiouy12345"

exit 0
