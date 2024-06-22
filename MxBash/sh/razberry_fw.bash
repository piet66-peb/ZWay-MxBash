#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         razberry_fw.bash
#h Type:         Linux shell script
#h Purpose:      get Razberry/ UZB firmware
#h Project:      
#h Usage:        ./razberry_fw.bash
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2024-06-15/peb
#v History:      V1.0.0 2024-06-15/peb first version
#h Copyright:    (C) piet66 2024
#h License:      http://opensource.org/licenses/MIT
#h
#h-------------------------------------------------------------------------------

#-----------
#b Constants
#-----------
MODULE='razberry_fw.bash'
VERSION='V1.0.0'
WRITTEN='2024-06-15/peb'

#-----------
#b Variables
#-----------

#-----------
#b Functions
#-----------
function gr {
    grep -m1 '"'$1'"' $DATA | sed 's/^.*value="//' | sed 's/".*$//'
}
function gr2 {
    echo $line | sed -e 's/^.*'$1'/"'$1'/g' -e 's/",.*$//g' -e 's/^.*"//g'
}

#----------
#b Welcome
#----------

#----------
#b Commands
#----------
    if [ -d /opt/z-way-server ]
    then
        #----------
        #b Razberry
        #----------
        echo ''
        DATA=/opt/z-way-server/config/zddx/0e0d0c0b-DevicesData.xml
        if [ -f "$DATA" ]
        then
            VENDORID=`gr manufacturerId`
            MAJOR=`gr APIVersionMajor`
            MINOR=`gr APIVersionMinor`
            LOADER=`gr bootloader`
            if [ "$LOADER" == "null" ] || [ "$LOADER" == "" ]
            then
               LOADER=`gr bootloaderCRC`
               if [ "$LOADER" == "null" ] || [ "$LOADER" == "" ]
               then
                   LOADER=`gr crc`
               fi
               if [ "$LOADER" == "null" ] || [ "$LOADER" == "" ]
               then
                   LOADER=0
               fi
            fi

            url="https://service.z-wave.me/expertui/uzb/?vendorId=$VENDORID&appVersionMajor=$MAJOR&appVersionMinor=$MINOR&bootloaderCRC=$LOADER&token=all&uuid=1"
            response=`curl -s "$url" --get --data-urlencode ''`
            if [ "$response"  == '{"data":[]}' ]
            then
                echo no firmware for upgrade available
                exit 1
            fi

            while read line
            do
                echo $line | grep 'fileURL' >/dev/null 2>&1
                if [ $? -eq 0 ]
                then
                    #echo $line
                    comment=`gr2 comment`
                    released=`gr2 released`
                    enabled=`gr2 enabled`
                    fileURL=`gr2 fileURL`
                    bootloader=`echo $fileURL | grep -c 'bootloader'`

                    echo $comment
                    if [ $bootloader -eq 0 ]
                    then
                        echo -e '\t'current version: $MAJOR.$MINOR
                        targetAppVersionMajor=`gr2 targetAppVersionMajor`
                        targetAppVersionMinor=`gr2 targetAppVersionMinor`
                        echo -e '\t'target version:: $targetAppVersionMajor.$targetAppVersionMinor
                    else
                        echo -e '\t'current version: $LOADER
                        targetBootloaderCRC=`gr2 targetBootloaderCRC`
                        echo -e '\t'target version:: $targetBootloaderCRC
                    fi
                    echo -en '\t'file name: $fileURL
                    download="https://service.z-wave.me/expertui/uzb/$fileURL"
                    text=' >>link to file'
                    echo -e "\e]8;;$download\e\\$text\e]8;;\e\\"
                    echo -e '\t'released: $released, $enabled
                    echo ''
                fi
            done <<< "$(echo -e "$response" | sed -e 's/{/\n{/g')"
        fi
    fi

    text='>>link to source file'
    echo -e "\e]8;;$url\e\\$text\e]8;;\e\\"

    url=https://service.z-wave.me/expertui/uzb-stats/versions-graph.html?hw=$VENDORID
    text='>>link to firmware tree'
    echo -e "\e]8;;$url\e\\$text\e]8;;\e\\"
