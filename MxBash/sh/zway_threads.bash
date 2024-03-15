#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         zway_threads.bash
#h Type:         Linux shell script
#h Purpose:      displays z-way threads an their cpu consumption
#h Project:      
#h Usage:        ./zway_threads.bash
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2024-02-25/peb
#v History:      V1.0.0 2024-02-18/peb first version
#h Copyright:    (C) piet66 2022
#h License:      http://opensource.org/licenses/MIT
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='zway_threads.bash'
VERSION='V1.0.0'
WRITTEN='2024-02-25/peb'

#b Commands
#----------
echo running threads:
echo ''
top -Hbn1 | grep USER | grep -v grep
top -Hbn1 | grep z-way-server | grep -v grep
top -Hbn1 | grep OptimizingCompi | grep -v grep
top -Hbn1 | grep 'v8:' | grep -v grep
top -Hbn1 | grep 'zway/' | grep -v grep




