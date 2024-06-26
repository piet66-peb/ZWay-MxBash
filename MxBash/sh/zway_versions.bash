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
#h Version:      V1.0.0 2024-04-04/peb
#v History:      V1.0.0 2022-08-21/peb first version
#h Copyright:    (C) piet66 2023
#h License:      http://opensource.org/licenses/MIT
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='zway_versions.bash'
VERSION='V1.0.0'
WRITTEN='2024-04-04/peb'

URL_CHANGELOG="https://storage.z-wave.me/z-way-server/ChangeLog"
URL_CHANGELOG_AUTOM_RAW="https://raw.githubusercontent.com/Z-Wave-Me/home-automation/master/CHANGELOG.md"
URL_CHANGELOG_AUTOM_MD="https://github.com/Z-Wave-Me/home-automation/blob/master/CHANGELOG.md"

#b Variables
#-----------
_self="${0##*/}"
ret=0
SDIR=`dirname $0`
WDIR=`pwd`

#b Commands
#----------
pushd $SDIR >/dev/null 
    zway_builds=`curl -s "$URL_CHANGELOG_AUTOM_RAW" --get --data-urlencode ''`
    lines=`echo -e $zway_builds | grep -Po '(\d{2}\.\d{2}\.\d{4}\sv\d+\.\d+\.*\S*)\s' | sort -k2 -V`
    while read line
    do
        echo -n $line
        latest=`echo $line | sed -e 's/\.//g' -e 's/\ /-/g'`
        link=${URL_CHANGELOG_AUTOM_MD}#$latest
        text='link to version'
        echo -en " \t\e]8;;$link\e\\$text\e]8;;\e\\"

        version=`echo $line | cut -d'v' -f2`
        text='download link'
        link=`./zway_download.bash $version`
        [ $? -eq 0 ] && echo -en " \e]8;;$link\e\\$text\e]8;;\e\\"
        #[ -z $link ] || echo -en " \e]8;;$link\e\\$text\e]8;;\e\\"
        echo ''
    done <<< "$(echo -e "$lines")"

    echo ''
    echo Source: Z-Way Change Log
    echo "    $URL_CHANGELOG"
    echo "    $URL_CHANGELOG_AUTOM_MD"
popd >/dev/null 



