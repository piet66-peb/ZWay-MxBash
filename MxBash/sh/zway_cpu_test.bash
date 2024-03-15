#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         zway_cpu_test.bash
#h Type:         Linux shell script
#h Purpose:      test script for displaying z-way processes an their cpu consumption
#h Project:      
#h Usage:        ./zway_cpu_test.bash
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2024-02-25/peb
#v History:      V1.0.0 2022-08-14/peb first version
#h Copyright:    (C) piet66 2022
#h License:      http://opensource.org/licenses/MIT
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='zway_cpu_test.bash'
VERSION='V1.0.0'
WRITTEN='2024-02-25/peb'

zway='z-way-server'

#b Commands
#----------
procno=`pidof $zway`
count=10

echo '>>' top -bn1 -p $procno
top -bn1 -p $procno

echo ''
echo '>>' ${count}x: top -bn1 -p $procno'; sleep 1s'
top -bn1 | grep PID
for i in $(seq $count); do
    top -bn1 -p $procno | grep root
    sleep 1s
    echo ''
done

echo ''
echo '>>' ${count}x: top -Hbn1 -p $procno -o -PID -i'; sleep 1s'
top -bn1 | grep PID
for i in $(seq $count); do
    top -Hbn1 -p $procno -o -PID -i | grep root
    sleep 1s
    echo ''
done

echo ''
echo '>>' top -Hbn1 -p $procno -o -PID
top -bn1 | grep PID | grep -v grep
top -Hbn1 -p $procno -o -PID | grep root

echo ''
echo '>>' ps -C $zway
ps -C $zway -o user,pid,%cpu,%mem,vsz,rss,tname,stat,start_time,time,args

echo ''
echo '>>' ps uHcp $procno
ps uHcp $procno

echo ''
#sudo lsof -n -p $procno
