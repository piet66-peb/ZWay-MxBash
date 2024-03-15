#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         contents_backup.bash
#h Type:         Linux shell script
#h Purpose:      stores a list of contents of a backup file
#h Project:      
#h Usage:        contents_backup.bash <archive file>
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2024-02-25/peb
#v History:      V1.0.0 2024-02-25/peb first version
#h Copyright:    (C) piet66 2024
#h License:      http://opensource.org/licenses/MIT
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='contents_backup.bash'
VERSION='V1.0.0'
WRITTEN='2024-02-25/peb'

#b Commands
#----------

archive="$1"

if [ "$archive" == "" ]
then
    echo 'usage:  contents_backup.bash <archive file>'
    exit
fi

if [ ! -e "$archive" ]
then
    echo archive "$archive" does not exist, break.
    exit
fi

contents=${archive}.contents
echo creating contents file $contents
sudo tar -ztvf "$archive" >"$contents"




