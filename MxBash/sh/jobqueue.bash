#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         jobqueue.bash
#h Type:         Linux shell script
#h Purpose:      monitor the Z-Way jobqueue
#h Project:      
#h Usage:        ./jobqueue.bash <seconds>
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2024-08-13/peb
#v History:      V1.0.0 2024-08-13/peb first version
#h Copyright:    (C) piet66 2024
#h License:      http://opensource.org/licenses/MIT
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='zway_info.bash'
VERSION='V1.0.0'
WRITTEN='2024-08-13/peb'

#b Parameters
#------------
ZWAY_DIR=`dirname $0`
PARAMS=${ZWAY_DIR}/params
if [ -e "$PARAMS" ]
then
    . "$PARAMS"
else
    if [ $# -eq 0 ]
    then
        echo "no parameter file 'params' found"
        echo "in folder $ZWAY_DIR"
        echo ''
    fi
fi

#b Constants
#-----------
SERVICE=z-way-server
SERVICE_PATH=/opt/$SERVICE
USERMODULES=$SERVICE_PATH/automation/userModules
IP=localhost

#b Variables
#-----------
_self="${0##*/}"
ZWAY_DIR=${ZWAY_DIR}/
SECS="$1"

#b Functions
#-----------
function service_running
{
    procid=`pidof $SERVICE`
    ret=$YES
    [ "$procid" == '' ] && ret=$NO
    echo $ret
}

#b Main
#------
stop_run=false
while  [ $stop_run == false ]
do
    if [ "$USERPW" == '' ]
    then
        echo 'parameter $USERPW must be defined to get jobqueue'
        $stop_run=true

    elif [ $(service_running $SERVICE) != $NO ]
    then
        echo 'jobqueue:'
        queue=`curl -s -u $USERPW --globoff "$IP:8083/ZWaveAPI/InspectQueue"`
        #echo $queue

        firstchar=${queue:0:1}
        if [ "$firstchar" == "[" ]
        then
            if [ "$queue" == "[]" ]
            then
                echo ''
                echo -n 'current number of jobs in queue: 0'
            else
                if [ "${zwave_devices[0]}" == '' ]
                then
                    . ${ZWAY_DIR}/zwave_devices.bash
                fi
                lines=`echo $queue | sed 's/\]\],/\\]\],\n/g' | nl` #add newlines + line numbers
                echo "$lines" | while read line
                do
                    devid=`echo $line | grep -Po '],(\d{1,3}),' | grep -Po '\d*'`
                    text=`echo $line | sed -e 's/"RSSI.*$//' | grep -Po '"(.*)"' | grep -Po '.*'`
                    no=`echo $line | cut -f1 -d' '`
                    #echo $line
                    echo "$no  node $devid=${zwave_devices[$devid]}:"
                    echo "   $text"
                done
                echo ''
                echo -n 'current number of jobs in queue: '; echo $queue | sed 's/\]\],/\\]\],\n/g' | wc -l 
            fi
        else
            echo $queue
        fi
    fi
    if  [ $stop_run == false ]
    then
        if [ "$SECS" != '' ]
        then
            echo ''
            sleep $SECS
            if [ $? -ne 0 ]
            then
                stop_run=true
            fi
        else
            stop_run=true
        fi
    fi
done
