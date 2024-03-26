#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         exam_coredump.bash
#h Type:         Linux shell script
#h Purpose:      examines the coredump
#h Project:      
#h Installation: add to the systemd service file:
#h               ExecStart=/<yourpath>/exam_coredump.bash && 
#h                                               /opt/z-way-server/z-way-server
#h Usage:        /<yourpath>/exam_coredump.bash
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    coredumpctl (systemd-coredump), lz4
#h Platforms:    Linux with systemd/systemctl
#h Authors:      peb piet66
#h Version:      V1.0.0 2024-03-26/peb
#v History:      V1.0.0 2024-03-26/peb first version
#h Copyright:    (C) piet66 2024
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='exam_coredump.bash'
VERSION='V1.0.0'
WRITTEN='2024-03-26/peb'

#b Variables
#-----------
SERVICE=z-way-server
TARDIR=/media/ZWay_USB/coredumps/
currtime=$(date +%s)

#b Functions
#-----------
function collect_data
{
    echo -e "\n===== status after failure:\n"
    echo sudo systemctl status $SERVICE --no-pager -l
    sudo systemctl status $SERVICE --no-pager -l

    echo -e "\n===== journalctl:\n"
    echo journalctl MESSAGE_ID=fc2e22bc6ee647b6b90729ab34a250b1 -o verbose --no-pager
    journalctl MESSAGE_ID=fc2e22bc6ee647b6b90729ab34a250b1 -o verbose --no-pager

    echo -e "\n===== coredumpctl output:\n"
    echo sudo coredumpctl list -1 $SERVICE
    sudo coredumpctl list -1 $SERVICE
    [ $? -ne 0 ] && return 1

    echo -e "\nsudo coredumpctl info --no-pager -1 $SERVICE"
    sudo coredumpctl info --no-pager -1 $SERVICE

    echo -e "\n===== core dump file (lz4 compressed):\n"
    STORAGE=`sudo coredumpctl info --no-pager -1 $SERVICE | grep "Storage:" | cut -d':' -f2`
    EXECUTABLE=`sudo coredumpctl info --no-pager -1 $SERVICE | grep "Executable:" | cut -d':' -f2`
    echo $STORAGE

    echo -e "\n======= getfattr:\n"
    echo sudo getfattr --absolute-names -d $STORAGE
    sudo getfattr --absolute-names -d $STORAGE

    echo -e "\n===== gdb:\n"
    #uncompress lz4 file before using with gdb:
    COREDUMP=${currtime}_coredump
    echo sudo lz4 -df $STORAGE $COREDUMP
    sudo lz4 -d $STORAGE $COREDUMP

    echo sudo gdb $EXECUTABLE $COREDUMP --batch --eval-command="bt full"
    sudo gdb $EXECUTABLE $COREDUMP --batch --eval-command="bt full"
}

#b Main
#------
if [`sudo systemctl is-failed $SERVICE` ]
then
    [ -d "$TARDIR" ] || mkdir -p "$TARDIR"  

    pushd $TARDIR >/dev/null 2>&1
        collect_data >${currtime}_coredump_exam
    popd >/dev/null
fi
exit 0

