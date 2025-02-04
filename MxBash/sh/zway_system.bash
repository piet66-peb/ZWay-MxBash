#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         zway_system.bash
#h Type:         Linux shell script
#h Purpose:      managing Z-Way service
#h Project:      z-Way Homeserver
#h Installation: - put scripts to any folder
#h               - make them executable: sudo chmod a+x *.bash
#h               - rename the file params_template to params
#h                 and enter your parameters
#h Usage:        ./zway_system.bash
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2025-02-04/peb
#v History:      V1.0.0 2025-02-04/peb first version
#h Copyright:    (C) piet66 2025
#h License:      http://opensource.org/licenses/MIT
#h
#h-------------------------------------------------------------------------------

MODULE='zway.bash'
VERSION='V1.0.0'
WRITTEN='2025-02-04/peb'

#----------
#b Commands
#----------
cat /sys/firmware/devicetree/base/model
echo -n ' Serial#:' ; cat /proc/cpuinfo | grep Serial | cut -d' ' -f2
echo -n 'Memory:' ; cat /proc/meminfo | grep MemTotal | cut -c16-
echo Software architecture: `dpkg --print-architecture`=`getconf LONG_BIT` bit
cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2
uname -a

echo ''
DATA=/opt/z-way-server/config/zddx/0e0d0c0b-DevicesData.xml
if [ -f "$DATA" ]
then
    function gr {
      grep -m1 '"'$1'"' $DATA | sed 's/^.*value="//' | sed 's/".*$//'
    }
    manufacturerId=`gr manufacturerId`
    vendor=`gr vendor`
    ZWaveChip=`gr ZWaveChip`
    SDK=`gr SDK`
    APIVersion=`gr APIVersion`
    PRODTYPE=`gr manufacturerProductType`
    PRODID=`gr manufacturerProductId`
    bootloader=`gr bootloader`
    if [ "$bootloader" == "null" ] || [ "$bootloader" == "" ]
    then
       bootloader=`gr bootloaderCRC`
       if [ "$bootloader" == "null" ] || [ "$bootloader" == "" ]
       then
           bootloader=`gr crc`
       fi
    fi
    echo $vendor'('$manufacturerId')' $ZWaveChip $SDK $APIVersion/$bootloader $PRODTYPE/$PRODID
fi
cd /opt/z-way-server; LD_LIBRARY_PATH=./libs ./z-way-server -h 2>/dev/null | head -n 1

