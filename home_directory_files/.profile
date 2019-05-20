# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# run first-time login script if new user
newuser=$(cat $HOME/.newuser)
if [ "$newuser" == "TRUE" ]; then
    bash /usr/bin/first-time-login.sh
    wait
fi

# if not first-time login and updates are available to instruction file, copy updates
if [ "$newuser" == "FALSE" ]; then
    val1=$(mdsum "$HOME/Desktop/Data analysis information.html")
    val2=$(mdsum "/common/.Desktop_files/Data analysis information.html")
        if [ "$val1" != "$val2" ]; then
            cp "/common/.Desktop_files/Data analysis information.html" $HOME/Desktop/
        fi
fi

