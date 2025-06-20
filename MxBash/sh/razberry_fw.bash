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
#h Version:      V1.0.0 2025-06-16/peb
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
WRITTEN='2025-06-16/peb'

#-----------
#b Variables
#-----------
expand_hyperlinks=false

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
    if [ "$expand_hyperlinks" == true ]
    then
        echo -e "${1}${text}:"
        echo -e "${3}${url}"
    else
        echo -e "\e]8;;$url\e\\$text\e]8;;\e\\"
    fi
}
function set_expand_hyperlinks {
    read -p  'expand hyperlinks? [yN]: ' inputvar
    if [ "$inputvar" == y ]
    then
        expand_hyperlinks=true
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
        set_expand_hyperlinks

        #----------
        #b Razberry
        #----------
        echo ''
        DATA=/opt/z-way-server/config/zddx/0e0d0c0b-DevicesData.xml
        if [ -f "$DATA" ]
        then
            UUID=`gr uuid`
            if [ "$UUID" == "null" ] || [ "$UUID" == "" ]
            then
                UUID=1
            fi
            VENDORID=`gr manufacturerId`
            MAJOR=`gr APIVersionMajor`
            MINOR=`gr APIVersionMinor`
            LOADERCRC=`gr bootloader`
            if [ "$LOADERCRC" == "null" ] || [ "$LOADERCRC" == "" ]
            then
               LOADERCRC=`gr bootloaderCRC`
               if [ "$LOADERCRC" == "null" ] || [ "$LOADERCRC" == "" ]
               then
                   LOADERCRC=`gr crc`
               fi
               if [ "$LOADERCRC" == "null" ] || [ "$LOADERCRC" == "" ]
               then
                   LOADERCRC=0
               fi
            fi
            BOOTLOADERVERSION=`gr version`

            #get zway version:
            ZWAY=`cd /opt/z-way-server; LD_LIBRARY_PATH=./libs ./z-way-server -h 2>/dev/null | head -n 1 | cut -f3 -d' '`

            echo Current versions
            echo -e '\t'zway version: $ZWAY
            echo -e '\t'firmware version: $MAJOR.$MINOR
            echo -e '\t'bootloader CRC: $LOADERCRC
            echo -e '\t'bootloader version: $BOOTLOADERVERSION
            echo ''

            URL="https://service.z-wave.me/expertui"
            url="${URL}/uzb/"
            url="$url""?vendorId=$VENDORID"
            url="$url""&appVersionMajor=$MAJOR"
            url="$url""&appVersionMinor=$MINOR"
            url="$url""&bootloaderCRC=$LOADERCRC"
            url="$url""&zway=$ZWAY&uuid=$UUID"
            url0="$url""&token=all"
            #echo $url0

            response=`curl -s "$url0" --get --data-urlencode ''`
            #echo $response
            echo $response | grep 'data' >/dev/null 2>&1
            if [ $? -ne 0 ]
            then
                echo $response
                response=
                echo ''
            fi
            if [ "$response"  == '{"data":[]}' ]
            then
                response=
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
                        if [ $bootloader -eq 0 ] && [ "$bootloaderCRC" != "$LOADERCRC" ]
                        then
                            continue
                        fi

                        echo $comment
                        echo -e '\torg family: ' `gr2 org_family`
                        echo -e '\tfw family: ' `gr2 fw_family`
                        echo -e '\tchip family: ' `gr2 chip_family`
                        echo -e '\tchip id: ' `gr2 chip_id`

                        if [ $bootloader -eq 0 ]
                        then
                            # firmware update
                            targetAppVersionMajor=`gr2 targetAppVersionMajor`
                            targetAppVersionMinor=`gr2 targetAppVersionMinor`
                            echo -e '\t'target version:: $targetAppVersionMajor.$targetAppVersionMinor
                        else
                            # bootloader update
                            targetBootloaderCRC=`gr2 targetBootloaderCRC`
                            echo -e '\t'target version:: $targetBootloaderCRC
                        fi
                        echo -e '\t'released: $released, $enabled
                        echo -e '\t'comment: $comment
                        echo -en '\t'file name: $fileURL
                        download="${URL}/uzb/$fileURL"
                        text1=' >>link to file'
                        print_link '\n\t' "$download" '\t   ' "$text1"
                        echo ''
                    fi
                done <<< "$(echo -e "$response" | sed -e 's/{/\n{/g')"
            fi #if [ "$response" != "" ]

            if [ "$download"  == '' ]
            then
                echo no firmware upgrade available
                echo ''
            fi
            text2='>>link to description'
            print_link '' "$url0" '  ' "$text2"
        fi #if [ -f "$DATA" ]
    fi #if [ -d /opt/z-way-server ]

    url3="${URL}/uzb-stats/versions-graph.html?hw=$VENDORID"
    text3='>>link to firmware tree (active)'
    print_link '' "$url3" '  ' "$text3"

    url3="${url3}&with_hidden"
    text3='>>link to firmware tree (all)'
    print_link '' "$url3" '  ' "$text3"

    url4="https://z-wave.me/support/uzbrazberry-firmwares/"
    text4='>>firmwares changelog'
    print_link '' "$url4" '  ' "$text4"

    echo ''

