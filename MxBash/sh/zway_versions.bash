#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         zway_versions.bash
#h Type:         Linux shell script
#h Purpose:      print list of all official z-way versions
#h Project:      
#h Usage:        export no_hyperlinks=true|false
#h               ./zway_versions.bash
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2024-08-31/peb
#v History:      V1.0.0 2022-08-21/peb first version
#h Copyright:    (C) piet66 2023
#h License:      http://opensource.org/licenses/MIT
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='zway_versions.bash'
VERSION='V1.0.0'
WRITTEN='2024-08-31/peb'

URL_CHANGELOG="https://storage.z-wave.me/z-way-server/ChangeLog"
URL_CHANGELOG_AUTOM_RAW="https://raw.githubusercontent.com/Z-Wave-Me/home-automation/master/CHANGELOG.md"
URL_CHANGELOG_AUTOM_MD="https://github.com/Z-Wave-Me/home-automation/blob/master/CHANGELOG.md"

#b Variables
#-----------
_self="${0##*/}"
ret=0
SDIR=`dirname $0`
WDIR=`pwd`

#b Functions
#-----------
function print_link {
    url="$2"
    text="$4"
    if [ "$no_hyperlinks" == true ]
    then
        echo -en "${1}${text}:"
        echo -en "${3}${url}"
    else
        echo -en "\t\e]8;;$url\e\\$text\e]8;;\e\\"
    fi
}

#b Commands
#----------
pushd $SDIR >/dev/null 
    zway_builds=`curl -s "$URL_CHANGELOG_AUTOM_RAW" --get --data-urlencode ''`
    echo $zway_builds | grep 'New features:' >/dev/null 2>&1
    if [ $? -ne 0 ]
    then
        echo $URL_CHANGELOG_AUTOM_RAW
        echo  $zway_builds
        exit 1
    fi
    lines=`echo -e $zway_builds | grep -Po '(\d{2}\.\d{2}\.\d{4}\sv\d+\.\d+\.*\S*)\s' | sort -k2 -V`
    while read line
    do
        version=`echo $line | cut -d'v' -f2`
        anchor=`echo $line | sed -e 's/\.//g' -e 's/\ /-/g'`
        #correct version 5.0.0 to 4.1.4:
        versionDL=`echo $version | sed -e 's%5.0.0%4.1.4%'`
        line=`echo $line | sed -e 's%5.0.0%4.1.4/5.0.0%'`
        formatted=`printf '%-20s' "$line"`
        echo -n "$formatted"
        link="${URL_CHANGELOG_AUTOM_MD}#$anchor"
        text='link to version'
        print_link '\n   ' "$link" '\t' "$text"

        text='download link'
        link=`./zway_download.bash $versionDL`
        [ $? -eq 0 ] && print_link '\n   ' "$link" '\t' "$text"
        echo ''
    done <<< "$(echo -e "$lines")"

    echo ''
    echo Source: Z-Way Change Log
    echo "    $URL_CHANGELOG"
    echo "    $URL_CHANGELOG_AUTOM_MD"
    echo ''
    hint1='If your terminal does not support hyperlinks, call before:'
    hint2='export no_hyperlinks=true'
    echo -e "\e[2m$hint1\n$hint2\e[0m"
popd >/dev/null 



