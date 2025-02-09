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
#h Version:      V1.1.0 2025-02-07/peb
#v History:      V1.0.0 2024-10-02/peb first version
#h Copyright:    (C) piet66 2024
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='download_MxBash.bash'
VERSION='V1.1.0'
WRITTEN='2025-02-07/peb'

#b Variables
#-----------
pack=MxBash

#b Commands
#----------
gitpack=ZWay-$pack
url=https://github.com/piet66-peb/$gitpack/archive/refs/heads/main.zip
tardir=/opt/z-way-server/automation/userModules/
cd /tmp; wget -O $gitpack.zip $url
sudo unzip ${gitpack}.zip
sudo cp -dpR ${gitpack}-main/${pack} $tardir

