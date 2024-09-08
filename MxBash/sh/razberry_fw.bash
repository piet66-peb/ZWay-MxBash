#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         razberry_fw.bash
#h Type:         Linux shell script
#h Purpose:      get Razberry/ UZB firmware
#h Project:      
#h Usage:        export no_hyperlinks=true|false
#h               ./razberry_fw.bash
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2024-07-29/peb
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
WRITTEN='2024-07-29/peb'

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
function print_link {
    url="$2"
    text="$4"
    if [ "$no_hyperlinks" == true ]
    then
        echo -e "${1}${text}:"
        echo -e "${3}${url}"
    else
        echo -e "\e]8;;$url\e\\$text\e]8;;\e\\"
    fi
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
            BOOTLOADERVERSION=`gr version`

            url="https://service.z-wave.me/expertui/uzb/"
            url="$url""?vendorId=$VENDORID"
            url="$url""&appVersionMajor=$MAJOR"
            url="$url""&appVersionMinor=$MINOR"
            url="$url""&bootloaderCRC=$LOADER"
            url="$url""&token=all&uuid=1"
            url="$url""&bootloaderVersion=$BOOTLOADERVERSION"
            response=`curl -s "$url" --get --data-urlencode ''`
            echo $response | grep 'data' >/dev/null 2>&1
            if [ $? -ne 0 ]
            then
                echo $response
                response=
                echo ''
            fi
            if [ "$response"  == '{"data":[]}' ]
            then
                echo no firmware upgrade available
                response=
                echo ''
            fi

            if [ "$response" != "" ]
            then
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
    
                        bootloaderCRC=`gr2 bootloaderCRC`
                        if [ $bootloader -eq 0 ] && [ "$bootloaderCRC" != "$LOADER" ]
                        then
                            continue
                        fi

                        echo $comment
                        if [ $bootloader -eq 0 ]
                        then
                            # firmware update
                            echo -e '\t'current bootloaderCRC: $bootloaderCRC
                            echo -e '\t'current version: $MAJOR.$MINOR
                            targetAppVersionMajor=`gr2 targetAppVersionMajor`
                            targetAppVersionMinor=`gr2 targetAppVersionMinor`
                            echo -e '\t'target version:: $targetAppVersionMajor.$targetAppVersionMinor
                        else
                            # bootloader update
                            echo -e '\t'current bootloaderCRC: $bootloaderCRC
                            echo -e '\t'current version: $LOADER
                            targetBootloaderCRC=`gr2 targetBootloaderCRC`
                            echo -e '\t'target version:: $targetBootloaderCRC
                        fi
                        echo -e '\t'released: $released, $enabled
                        echo -en '\t'file name: $fileURL
                        download="https://service.z-wave.me/expertui/uzb/$fileURL"
                        text=' >>link to file'
                        print_link '\n\t' "$download" '\t   ' "$text"
                        echo ''
                    fi
                done <<< "$(echo -e "$response" | sed -e 's/{/\n{/g')"
            fi
        fi
    fi

    text='>>link to source file'
    print_link '' "$url" '  ' "$text"

    url="https://service.z-wave.me/expertui/uzb-stats/versions-graph.html?hw=$VENDORID&with_hidden"
    text='>>link to firmware tree'
    print_link '' "$url" '  ' "$text"

    url="https://z-wave.me/support/uzbrazberry-firmwares/"
    text='>>changelog'
    print_link '' "$url" '  ' "$text"

    echo ''
    hint1='If your terminal does not support hyperlinks, call before:'
    hint2='export no_hyperlinks=true'
    echo -e "\e[2m$hint1\n$hint2\e[0m"

