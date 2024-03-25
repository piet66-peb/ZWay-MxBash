#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         install_init.d.bash
#h Type:         Linux shell script
#h Purpose:      replaces the SysVinit configuration 
#h Project:      
#h Usage:        ./install_init.d.bash [<replacement file>]
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2024-03-23/peb
#v History:      V1.0.0 2024-02-24/peb first version
#h Copyright:    (C) piet66 2024
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='install_init.d.bash'
VERSION='V1.0.0'
WRITTEN='2024-03-23/peb'

#b Variables
#-----------
d=/etc/init.d
s=z-way-server
p=$d/$s
t=`dirname $0`
o='config_z-way-server.orig'
r="$1"
[ "$r" == "" ] && r='config_z-way-server.replace'

#b Commands
#----------
if [ ! -e "$o" ]
then
    echo -e '\n'saving the original SysVinit config file to "$o"...
    echo sudo cp $p "$t/$o"
    sudo cp $p "$t/$o"
fi

echo -e '\n'replacing the original SysVinit config file...
echo sudo cp $t/$r $p
sudo cp $t/$r $p

echo -e '\n'creating links...
echo sudo update-rc.d $s defaults
sudo update-rc.d $s defaults
sudo ls -l /etc/rc*.d/*z-way*

