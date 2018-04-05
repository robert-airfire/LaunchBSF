#!/bin/sh

# check user
uid=$(id -u)
[ $uid -ne 0 ] && { echo "must run as root" ; exit 1; }

# make perl module directory (if needed)
mkdir -p /usr/local/share/perl

# copy perl modules to /usr/local/share/perl
cp LaunchArchiveRsync.pm LaunchLog.pm LaunchSmoke.pm LaunchWaitARL.pm /usr/local/share/perl

# the LaunchBSF to /usr/local/bin
cp LaunchBSF /usr/local/bin

# install necessary system packages...
echo "install system package....i think this is all required"
apt-get install libdatetime-timezone-perl libdatetime-format-strptime-perl #libtext-csv-xs-perl
