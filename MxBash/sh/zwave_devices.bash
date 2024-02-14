#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         zwave_devices.bash
#h Type:         Linux shell script
#h Purpose:      get ZWave devices (number + givenName)
#h Project:      
#h Usage:        ./zwave_devices.bash [--print]
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2023-12-09/peb
#v History:      V1.0.0 2023-12-03/peb first version
#h Copyright:    (C) piet66 2022
#h License:      http://opensource.org/licenses/MIT
#h
#h-------------------------------------------------------------------------------

MODULE='zwave_devices.bash'
VERSION='V1.0.0'
WRITTEN='2023-12-09/peb'

#b Constants
#-----------
SERVICE=z-way-server
SERVICE_PATH=/opt/$SERVICE
CONFIG_FILE=${SERVICE_PATH}/config/zddx/0e0d0c0b-DevicesData.xml

#b Commands
#----------
    #b examine device numbers
    #------------------------
    allNumbers=(1)
    d=`grep "<device id=" $CONFIG_FILE | cut -f2 -d'"'`
    for line in $d
    do
        allNumbers+=("$line")
    done

    #b examine device names
    #----------------------
    ix=0
    declare -A zwave_devices
    zwave_devices[0]='Controller'
    zwave_devices[255]='Broadcast'
    d=`grep "givenName" $CONFIG_FILE | sed 's/""/"_"/g' | cut -f10 -d'"' | sed 's/ /_/g'`
    for line in $d
    do
        ix=$((ix + 1))
        if [ $ix -eq 1 ] &&[ "$line" == '_' ]
        then
            line='Z-Way'
        fi

        name=`echo "$line" | sed 's/_/ /g'`
        zwave_devices["${allNumbers[$ix]}"]="$name"
    done

    if [ "$1" == "--print" ]
    then
        for i in "${!zwave_devices[@]}"
        do
            echo $i=${zwave_devices[$i]}
        done | sort -g
    fi
