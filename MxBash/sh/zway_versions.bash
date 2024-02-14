#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         zway_versions.bash
#h Type:         Linux shell script
#h Purpose:      print list of all official z-way versions
#h Project:      
#h Usage:        ./zway_versions.bash
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2023-11-29/peb
#v History:      V1.0.0 2022-08-21/peb first version
#h Copyright:    (C) piet66 2023
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='zway_versions.bash'
VERSION='V1.0.0'
WRITTEN='2023-11-29/peb'

URL_CHANGELOG="https://storage.z-wave.me/z-way-server/ChangeLog"
URL_CHANGELOG_AUTOM="https://raw.githubusercontent.com/Z-Wave-Me/home-automation/master/CHANGELOG.md"

#b Variables
#-----------
_self="${0##*/}"
ret=0
SDIR=`dirname $0`
WDIR=`pwd`

#b Commands
#----------
pushd $SDIR >/dev/null 
    zway_builds=`curl -s "$URL_CHANGELOG_AUTOM" --get --data-urlencode ''`
    echo $zway_builds | grep -Po '(\d{2}\.\d{2}\.\d{4}\sv\d+\.\d+\.*\S*)\s' | sort -k2 -V

    echo ''
    echo Source: Z-Way Change Log
    echo  $URL_CHANGELOG 
    echo  $URL_CHANGELOG_AUTOM 
popd >/dev/null 



