#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         extract_backup.bash
#h Type:         Linux shell script
#h Purpose:      extracts a backup file
#h Project:      
#h Usage:        extract_backup.bash <archive file> [<target path>]
#h               default target path: ..
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2024-04-11/peb
#v History:      V1.0.0 2024-02-25/peb first version
#h Copyright:    (C) piet66 2024
#h License:      http://opensource.org/licenses/MIT
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='extract_backup.bash'
VERSION='V1.0.0'
WRITTEN='2024-04-11/peb'

#b Commands
#----------

archive="$1"

if [ "$archive" == "" ]
then
    echo 'usage:  extract_backup.bash <archive file> [<target path>]' 
    exit
fi

if [ ! -e "$archive" ]
then
    echo archive "$archive" does not exist, break.
    exit
fi

target='../'
[ "$2" != "" ] && target="$2"
[ "$3" != "" ] && params="$3"
echo extracting archive "$archive" to "$target"
sudo tar -xvf ${archive} -C ${target} --overwrite ${params}
exit $?

