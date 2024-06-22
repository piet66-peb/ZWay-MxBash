#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         zway_info.bash
#h Type:         Linux shell script
#h Purpose:      get Linux/razberry/zway info
#h Project:      
#h Usage:        ./zway_info.bash
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.2.1 2024-06-15/peb
#v History:      V1.0.0 2019-10-17/peb first version
#h Copyright:    (C) piet66 2022
#h License:      http://opensource.org/licenses/MIT
#h
#h-------------------------------------------------------------------------------

#-----------
#b Constants
#-----------
MODULE='zway_info.bash'
VERSION='V1.2.1'
WRITTEN='2024-06-15/peb'

#-----------
#b Variables
#-----------

#-----------
#b Functions
#-----------

#----------
#b Welcome
#----------

#----------
#b Commands
#----------
    #-------------------
    #b Raspberry Pi data
    #-------------------
    echo ''
    if [ -e /sys/firmware/devicetree/base/model ]
    then
        cat /sys/firmware/devicetree/base/model
        echo -n ',  Serial#:' ; cat /proc/cpuinfo | grep Serial | cut -d' ' -f2
        echo -n 'Memory:' ; cat /proc/meminfo | grep MemTotal | cut -c16-
    fi
    echo Software architecture: `dpkg --print-architecture`=`getconf LONG_BIT` bit
    cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2
    uname -a

    echo && echo Hardware: && lscpu | sed -e "s'Cortex-A53'Cortex-A53=64 bit'" | \
                                      sed -e "s'Cortex-A72'Cortex-A72=64 bit'" | \
                                      sed -e "s'Architecture:       'Kernel architecture:'" | \
                                      sed -e "s'armv7l'armv7l=32 bit'" | \
                                      sed -e "s'arm11'arm11=32 bit'" | \
                                      sed -e "s'Cortex-A7'Cortex-A7=32 bit'"

    #--------------------
    #b frequency and temp
    #--------------------
    if [ -x "$(command -v vcgencmd)" ]
    then
        echo ''
        echo 'Firmware: '
        vcgencmd version
        echo ''
        vcgencmd measure_clock arm
        vcgencmd measure_temp
        for id in "core   " sdram_c sdram_i sdram_p ; do \
            echo -e "$id:\t$(vcgencmd measure_volts $id)" ; \
        done
    fi

    if [ -x "$(command -v tvservice)" ]
    then
        echo ''
        echo tvservice -s
        tvservice -s
    fi

    if [ -d /opt/z-way-server ]
    then
        #----------
        #b Razberry
        #----------
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
    
        #---------------
        #b z-way version
        #---------------
        cd /opt/z-way-server; LD_LIBRARY_PATH=./libs ./z-way-server -h 2>/dev/null | head -n 1
    fi
    echo ''
