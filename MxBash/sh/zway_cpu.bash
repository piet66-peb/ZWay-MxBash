#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         zway_cpu.bash
#h Type:         Linux shell script
#h Purpose:      displays z-way processes an their cpu consumption
#h Project:      
#h Usage:        ./zway_cpu.bash
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2023-12-24/peb
#v History:      V1.0.0 2023-09-24/peb first version
#h Copyright:    (C) piet66 2022
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='zway_cpu.bash'
VERSION='V1.0.0'
WRITTEN='2023-12-24/peb'

SERVICE='z-way-server'
FORMAT='%20s %5s %5s %10s %10s %10s %s\n'

#b Functions
#-----------
ltrim_0() {
    var=`echo $1 | sed 's/^0*//'`
    [ "$var" == '' ] && var=0
    echo $var
}

convert_cpu() {
    # converts time from format [[dd-]hh:]mm:ss into seconds
    dd=`echo ${1%-*}`
    [ "$dd" == "$1" ] && dd=0
    ss=`echo ${1##*:}`
    mm_ss=`echo ${1#*:}`
    if [ "$mm_ss" != $ss ]
    then
        mm=`echo ${mm_ss%:*}`
        hh_mm_ss=`echo ${1#*-}`
        hh=`echo ${hh_mm_ss%%:*}`
    else
        mm=`echo ${1%:*}`
        hh=0
    fi
    ss=`ltrim_0 $ss`
    mm=`ltrim_0 $mm`
    hh=`ltrim_0 $hh`
    dd=`ltrim_0 $dd`

    seconds=$ss
    [ "$mm" != "0" ] && (( seconds=seconds+mm*60 ));
    [ "$hh" != "0" ] && (( seconds=seconds+hh*3660 ));
    [ "$dd" != "0" ] && (( seconds=seconds+dd*86400 ));
    #echo time=$1 $dd:$hh:$mm:$ss = $seconds seconds
    echo $seconds
}

compute_percent() {
    # converts percent ($2/$1*100)
    v1=$1
    v2=$2
    #v1=`echo ${v1##*(0)}`
    #v2=`echo ${v2##*(0)}`
    if [ $1 -eq 0 ]
    then
        echo $1
    elif [ $2 -eq 0 ]
    then
        echo $2
    else
        #(( percent=v2*100/v1 ));
        percent=`awk "BEGIN {printf \"%.2f\n\", $v2*100/$v1}"`
        echo $percent
    fi
}

#b Commands
#----------
procid=`pidof $SERVICE`
echo process id of $SERVICE: $procid
echo ''
ps ucp $procid
echo ''
ps uchH $procid
echo ''

server_seconds=0
line=`ps uchp $procid`
name=`echo $line | cut -d' ' -f11`
cpu=`echo $line | cut -d' ' -f3`
time=`echo $line | cut -d' ' -f10`   #format:[[dd-]hh:]mm:ss
server_seconds=`convert_cpu $time`
percent=100.00
printf "$FORMAT" "COMMAND" "PID" "%CPU" "TIME" "SECONDS" "PERCENT"
printf "$FORMAT" "$name" "$procid" "$cpu" "$time" "$server_seconds" "$percent"
echo ''

ps uHchp $procid -T | while read line
do
    name=`echo $line | cut -d' ' -f12`
    cpu=`echo $line | cut -d' ' -f4`
    time=`echo $line | cut -d' ' -f11`  #format:[[dd-]hh:]mm:ss
    pid=`echo $line | cut -d' ' -f3`
    detail_seconds=`convert_cpu $time`
    percent=`compute_percent $server_seconds $detail_seconds`
    printf "$FORMAT" "$name" "$pid" "$cpu" "$time" "$detail_seconds" "$percent"
done

