#!/usr/bin env

## Lela Andrews May 20, 2019
## Script for collecting necessary information from Cinnamon
## for creating user accounts with standardized appearance.

set -e

## Find scripts and repository location.
    repodir="$( cd "$( dirname "$0" )" && pwd )"
    filesdir="$repodir/home_directory_files"
    htmldir="$repodir/html"
    initdir="$repodir/collected"

# default group variable
dgrp=`id -un`

initrun=$(cat $repodir/.initrun)
if [ "$initrun" == "FALSE" ]; then
    echo "
This is the first time running the install.sh script for this
repository. This will copy desktop settings for your local
Cinnamon environment and store them in an untracked directory.

When you create a new user account the new user will see the
desktop as you do aside from small things like icon size or
default browser."
    elif [ "$initrun" == "TRUE" ]; then
    echo "
You are rerunning the install.sh script. This will update all
settings for user accounts you generate subsequently to
reflect desktop settings as currently implemented."
fi

sleep 2s

echo "
This process will copy several files and directories from your
home directory for use in creating new user accounts. Ensure
these files are constructed appropriately for such usage:
.bashrc
.profile
.condarc
.local
.cinnamon

Press any key to continue or Ctrl-C to exit now."
read ok

sleep 2s

echo "
Copying files and settings..."

# if missing, set initdir
mkdir -p $initdir

# copy .bashrc, .profile, .condarc, .local and .cinnamon to "collected" directory
cp $HOME/.bashrc $initdir/
cp $HOME/.profile $initdir/
cp $HOME/.condarc $initdir/
cp -r $HOME/.local $initdir/
cp -r $HOME/.cinnamon $initdir/

# backup existing Cinnamon settings to file
dconf dump /org/cinnamon/ > $initdir/.cinnamon_settings

# set initrun variable to TRUE
echo "TRUE" > $repodir/.initrun

echo "
Done!!!
"

exit 0
