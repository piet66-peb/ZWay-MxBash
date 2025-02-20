#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         download_MxBash.bash
#h Type:         Linux shell script
#h Purpose:      download the MxBash package from Github and copy it to the 
#h               Z-Way folder userModules
#h Project:      
#h Usage:        <path>/download_MxBash.bash
#h               or with wget:
#h               url=https://github.com/piet66-peb/ZWay-MxBash/raw/refs/heads/main/download_MxBash.bash
#h               cd /tmp; wget -q -O - $url | sudo bash
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.1.0 2025-02-20/peb
#v History:      V1.0.0 2024-10-02/peb first version
#h Copyright:    (C) piet66 2024
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='download_MxBash.bash'
VERSION='V1.1.0'
WRITTEN='2025-02-20/peb'

#b Variables
#-----------
pack=MxBash

gitpack=ZWay-$pack
url=https://github.com/piet66-peb/$gitpack/archive/refs/heads/main.zip
gitzip=$gitpack.zip
module=${gitpack}-main/${pack}
tardir=/opt/z-way-server/automation/userModules/
tmp=/tmp

#b Commands
#----------
set -e  # exit if any command fails

echo cd $tmp...
pushd $tmp >/dev/null

echo downloading $gitzip...
[ -e "$gitzip" ] && sudo rm $gitzip
wget -nv -O $gitzip $url

echo extracting $gitzip...
[ -e "$module" ] && sudo rm -R $module
sudo unzip -q -o $gitzip

echo copying $pack to $tardir...
sudo cp -dpR $module $tardir

echo done.
popd >/dev/null

