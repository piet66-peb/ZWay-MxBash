#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         install_systemd.bash
#h Type:         Linux shell script
#h Purpose:      installs Systemd configuration to /etc/systemd/system/
#h Project:      
#h Usage:        ./install_systemd.bash
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2024-03-15/peb
#v History:      V1.0.0 2024-02-24/peb first version
#h Copyright:    (C) piet66 2024
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='install_systemd.d.bash'
VERSION='V1.0.0'
WRITTEN='2024-03-15/peb'

#b Commands
#----------
s=z-way-server
t=/etc/systemd/system/

echo copy configuration file to $t
sudo cp `dirname $0`/$s.service $t
sudo systemctl daemon-reload
#sudo systemctl enable $s
#sudo systemctl start $s
#sudo systemctl status $s --no-pager

