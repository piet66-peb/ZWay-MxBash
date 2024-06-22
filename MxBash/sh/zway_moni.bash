#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         zway_moni.bash
#h Type:         Linux shell script
#h Purpose:      monitoring of process z-way-server
#h Project:      
#h Usage:        ./zway_moni.bash [--print]
#h               entry for cron (run every 10 minutes):
#h                   crontab -e 
#h                   */10 * * * *   /YOUR_PATH/zway_moni.bash
#h                   [sudo service cron reload]
#h Result:       
#h Examples:     
#h Outline:      https://linuxwiki.de/proc/pid#A.2Fproc.2Fpid.2Fstatus
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2024-04-20/peb
#v History:      V1.0.0 2024-02-28/peb first version
#h Copyright:    (C) piet66 2024
#h License:      http://opensource.org/licenses/MIT
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='zway_moni.bash'
VERSION='V1.0.0'
WRITTEN='2024-04-20/peb'

PROCESS='z-way-server'
URL_ZWAY="localhost:8083/ZAutomation/api/v1/devices/"


#b Functions
#-----------

#b Commands
#----------
ZWAY_DIR=`dirname $0`
PARAMS=${ZWAY_DIR}/params
if [ -e "$PARAMS" ]
then
    . "$PARAMS"
else
    echo "no parameter file 'params' found"
    echo "in folder $ZWAY_DIR"
    echo ''
    exit 1
fi

procid=`pidof $PROCESS`

if [ "$1" == "--print" ]
then
    cat /proc/$procid/status
else
    value=`ps -p $procid -o %cpu | grep -v 'CPU' | xargs`
    echo CPU: $value
    TARGET_DEVICE="MxDummyDevice_163"
    C="curl -sSg -u ${USERPW} ${URL_ZWAY}${TARGET_DEVICE}/command/exact?level=${value}"
    $C >/dev/null

    IFS=' '
    cat /proc/$procid/status | grep ^Vm | while read -r tag value scale
    do
        #echo $tag
        #echo $value
        #echo $scale
        case "$tag" in
            VmSize:*) echo $tag $value $scale
                      TARGET_DEVICE="MxDummyDevice_43"
                      C="curl -sSg -u ${USERPW} ${URL_ZWAY}${TARGET_DEVICE}/command/exact?level=${value}"
                      $C >/dev/null
                      ;;
            VmData:*) echo $tag $value $scale
                      TARGET_DEVICE="MxDummyDevice_100"
                      C="curl -sSg -u ${USERPW} ${URL_ZWAY}${TARGET_DEVICE}/command/exact?level=${value}"
                      $C >/dev/null
                      ;;
            VmStk:*) echo $tag $value $scale
                      TARGET_DEVICE="MxDummyDevice_101"
                      C="curl -sSg -u ${USERPW} ${URL_ZWAY}${TARGET_DEVICE}/command/exact?level=${value}"
                      $C >/dev/null
                      ;;
            VmExe:*) echo $tag $value $scale
                      TARGET_DEVICE="MxDummyDevice_135"
                      C="curl -sSg -u ${USERPW} ${URL_ZWAY}${TARGET_DEVICE}/command/exact?level=${value}"
                      $C >/dev/null
                      ;;
            VmLib:*) echo $tag $value $scale
                      TARGET_DEVICE="MxDummyDevice_162"
                      C="curl -sSg -u ${USERPW} ${URL_ZWAY}${TARGET_DEVICE}/command/exact?level=${value}"
                      $C >/dev/null
                      ;;
            VmRSS:*) echo $tag $value $scale
                      TARGET_DEVICE="MxDummyDevice_165"
                      C="curl -sSg -u ${USERPW} ${URL_ZWAY}${TARGET_DEVICE}/command/exact?level=${value}"
                      $C >/dev/null
                      ;;
            VmSwap:*) echo $tag $value $scale
                      TARGET_DEVICE="MxDummyDevice_167"
                      C="curl -sSg -u ${USERPW} ${URL_ZWAY}${TARGET_DEVICE}/command/exact?level=${value}"
                      $C >/dev/null
                      ;;
        esac
    done
fi

#VmPeak
#    Spitzenwert von VmSize 
#VmSize
#    Der gesamte Speicherverbrauch des Prozesses. Enthalten sind Text- und Datensegment, Stack, 
#    statische Variablen sowie Seiten, die mir anderen Prozessen geteilt werden. 
#VmLck
#    Menge des Prozeßspeichers, der aktuell vom Kernel gesperrt ist. Gesperrter Speicher kann 
#    nicht ausgelagert werden. 
#VmHWM
#    Spitzenwert der Resident Set Size ("high water mark") 
#VmRSS
#    Schätzung des Kernels der Resident Set Size für diesen Prozeß. 
#VmData
#    Speicher der für den Datenbereich des Prozesses genutzt wird. Statische Variablen und das 
#    Datensegment sind im Gegensatz zum Stack enthalten. 
#VmStk
#    Menge des Speichers der für den Stack des Prozesses verwendet wird. 
#VmExe
#    Größe der als ausführbar markierten Speicherseiten des Prozesses. 
#VmLib
#    Größe der Shared Memory-Seiten, die in den Adressbereich dies Prozesses eingeblendet wurden. 
#    Dies schließt geteilte Seiten aus, die IPC im Stil des System V nutzen. 
#VmPTE
#    Größe eines Eintrags in der Page Table 
#VmSwap
#    Größe des in den Swap Space ausgelagerten Speichers 
