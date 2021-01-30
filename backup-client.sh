#!/usr/bin/env bash

pcName=erling-dell-laptop
backupPath="/home/bu/${pcName}/current/"
PiAddr="bu@10.147.20.85"


#check for new month
ssh ${PiAddr} "/home/bu/backups.sh ${pcName} newMonth"

# Run rsync backup home folder
#rsync -avzpH --partial --delete ~/ "${PiAddr}:${backupPath}"

# Make backup and check regarding free space
ssh ${PiAddr} "/home/bu/backups.sh ${pcName} hardLink"
