#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         zway_download.bash
#h Type:         Linux shell script
#h Purpose:      downloads special Z-Way firmware
#h Project:      z-Way Homeserver
#h Installation: 
#h Usage:        ./zway_download.bash <version number>
#h Result:       returns the download link
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2024-04-04/peb
#v History:      V1.0.0 2024-04-04/peb first version
#h Copyright:    (C) piet66 2024
#h License:      http://opensource.org/licenses/MIT
#h
#h-------------------------------------------------------------------------------

MODULE='zway_download.bash'
VERSION='V1.0.0'
WRITTEN='2024-04-04/peb'

#b variables
#-----------
_self="${0##*/}"
ARCHITECTURE=`dpkg --print-architecture`
USAGE="usage: $_self <version number>"
URL_PACKAGE="https://storage.z-wave.me/z-way-server/"

VERSION_NUM="$1"
[ -z $VERSION_NUM ] && echo "$USAGE" && exit 1 

#b commands
#----------
if [ "$ARCHITECTURE" != 'armhf' ] && [ "$ARCHITECTURE" != 'amd64' ]
then
    echo "this function is not supported for $ARCHITECTURE, break!"
    exit 1
fi

main_rel=`echo $VERSION_NUM | cut -d'.' -f1`
if [ $main_rel -lt 3 ]
then
    echo 'releases < 3 are no longer available, break!'
    exit 1
fi

PKG=z-way-${VERSION_NUM}_${ARCHITECTURE}.deb
download_link="${URL_PACKAGE}$PKG"
echo  "$download_link"
exit 0
