#!/usr/bin env

## Lela Andrews May 9, 2019
## Script for creating user accounts with standardized appearance, 
## standardized settings, and access to RAID.
set -e

## Find scripts and repository location.
    repodir="$( cd "$( dirname "$0" )" && pwd )"
    filesdir="$repodir/home_directory_files"
    htmldir="$repodir/html"
    initdir="$repodir/collected"

# default group variable
dgrp=`id -un`

initrun=$(cat $repodir/.initrun)
echo "
$scriptdir
$repodir
$filesdir
$htmldir
$initdir
$initrun"
