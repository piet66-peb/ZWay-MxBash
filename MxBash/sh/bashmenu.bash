#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         bashmenu.bash
#h Type:         Linux shell script
#h Purpose:      a select menu for bash scripts
#h Project:      
#h Usage:        <selected option>=`./bashmenu.bash <title> <list of options>`
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    whiptail
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0 2024-03-20/peb
#v History:      V1.0 2023-06-21/peb first version
#h Copyright:    (C) piet66 2023
#h
#h-------------------------------------------------------------------------------

#b Constants
#-----------
MODULE='bashmenu.bash'
VERSION='V1.0'
WRITTEN='2024-03-20/peb'

if [ $# -lt 2 ]
then
    echo "wrong number of parameters: $#" >&2
    echo 0
    exit 1
fi

title="$1"; shift
[ "$title" == "" ] && title="Menu"

#whiptail seems not to support blanks in options:
space=`printf '\xE2\x80\x89'`
shopt -s extglob    #for replace all blanks in an option by space

num=0
list+="$num break "
for option in "$@"
do
    num=$((num + 1))
    list+="${num} ${option//+( )/$space} " 
done
shopt -u extglob    #reset

ret=`whiptail --nocancel --menu "$title" 0 0 0 $list 3>&1 1>&2 2>&3`
r=$?
[ $r -eq 255 ] && r=0
[ $r -eq 1 ] && r=0
if [ $r -ne 0 ]
then
    echo $r:$ret >&2
    echo ""
    exit 1
fi
[ "$ret" == "" ] && ret=""

case "$ret" in
     "") echo "";;
    "0") echo "break";;
      *) echo ${!ret};;
esac

exit 0
