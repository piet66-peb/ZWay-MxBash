#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         install_init.d.bash
#h Type:         Linux shell script
#h Purpose:      installs SysVinit configuration to /etc/init.d/
#h Project:      
#h Usage:        ./install_init.d.bash
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2024-03-20/peb
#v History:      V1.0.0 2024-02-24/peb first version
#h Copyright:    (C) piet66 2024
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='install_init.d.bash'
VERSION='V1.0.0'
WRITTEN='2024-03-20/peb'

#b Commands
#----------
d=/etc/init.d
s=z-way-server
p=$d/$s
t=`dirname $0`


echo sudo cp $t/SysVinit_$s $p
sudo cp $t/SysVinit_$s $p

echo create links:
echo sudo update-rc.d $s defaults
sudo update-rc.d $s defaults

