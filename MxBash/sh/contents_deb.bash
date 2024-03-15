#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         contents_deb.bash
#h Type:         Linux shell script
#h Purpose:      stores a list of contents of a deb installation pack
#h Project:      
#h Usage:        contents_deb.bash <pack file>
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
MODULE='contents_deb.bash'
VERSION='V1.0.0'
WRITTEN='2024-02-25/peb'

#b Commands
#----------

pack="$1"

if [ "$pack" == "" ]
then
    echo 'usage:  contents_deb.bash <pack file>'
    exit
fi

if [ ! -e "$pack" ]
then
    echo pack "$pack" does not exist, break.
    exit
fi

contents=${pack}.contents
echo creating contents file $contents
dpkg -c "$pack" >"$contents"




