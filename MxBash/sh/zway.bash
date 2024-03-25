#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         zway.bash
#h Type:         Linux shell script
#h Purpose:      managing Z-Way service
#h Project:      z-Way Homeserver
#h Installation: - put scripts to any folder
#h               - make them executable: sudo chmod a+x *.bash
#h               - rename the file params_template to params
#h                 and enter your parameters
#h Usage:        with calling the menu:
#h                   ./zway.bash
#h               without calling the menu:
#h                   ./zway.bash <function>
#h               available functions:
#h                   status            print important states of z-way-server
#h                   details           print detail data of z-way-server processes
#h                   cpu               cpu load of z-way-server
#h                   top               top z-way-server
#h                   jobqueue          print current contents of job queue
#h                   system            print important system data (HW + SW)
#h                   start             start z-way-server
#h                   stop              stop z-way-server
#h                   run_in_foreground run z-way-server in foreground
#h                   logrotate         force rotate of z-way-server log
#h                                     (start a new file in /var/logs/)
#h                   backup            backup current z-way-server folder (whole tree)
#h                   restore           restore the z-way-server folder from backup 
#h                                     archive
#h                   up-downgrade      up-downgrade z-way
#h                   devices           known zwave devices
#h                   reboot            reboot operating system
#h               if MxBaseModule is used:
#h                   lock              lock all Mx modules for running at next 
#h                                     start, useful e.g. for z-way up-downgrades 
#h                                     without starting the user apps
#h                   unlock            reset lock of all Mx modules
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    bashmenu.bash, whiptail
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V3.1.0 2024-03-25/peb
#v History:      V1.0.0 2017-02-03/peb first version
#h Copyright:    (C) piet66 2017
#h License:      http://opensource.org/licenses/MIT
#h
#h-------------------------------------------------------------------------------

MODULE='zway.bash'
VERSION='V3.1.0'
WRITTEN='2024-03-25/peb'

#------------
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

#-----------
#b Constants
#-----------
YES=0
NO=1

URL_CHANGELOG="https://storage.z-wave.me/z-way-server/ChangeLog"
URL_CHANGELOG_AUTOM="https://raw.githubusercontent.com/Z-Wave-Me/home-automation/master/CHANGELOG.md"
URL_PACKAGE="https://storage.z-wave.me/z-way-server/"

PRODUCT=z-way
SERVICE=z-way-server
SERVICE_PATH=/opt/$SERVICE
USERMODULES=$SERVICE_PATH/automation/userModules

ARCHITECTURE=`dpkg --print-architecture`
IP=localhost

MXBASEMODULE=$USERMODULES/MxBaseModule
LOCKED_FILE=$MXBASEMODULE/htdocs/LOCKED

MXWATCHDOG=$USERMODULES/MxWatchdog
WDOG_ACTIVE=$MXWATCHDOG/sh/WDOG_ACTIVE

MXMQTTSUB=$USERMODULES/MxMQTTSub
MXMQTTPUB=$USERMODULES/MxMQTTPub
[ ! -e $MXMQTTSUB ] && [ ! -e $MXMQTTPUB ] && MQTT_PORT=

#-----------
#b Variables
#-----------
_self="${0##*/}"
ret=0
ZWAY_DIR=${ZWAY_DIR}/
ZWAY_FILE=$_self

SYSTEMD='Systemd-systemctl'
SYSTEMD_GEN='Systemd-generated(init.d)'
SYSVINIT='SysVinit-init.d'
SERVICE_MANAGER=    # $SYSTEMD|$SYSVINIT|$SYSTEMD_GEN

SYSVINIT_ORIG="${ZWAY_DIR}install_systemd/config_z-way-server.orig"

#-----------
#b Functions
#-----------
function get_LOCKED () {
    if  [ "$MXLOCK" == "yes" ] && [ -e $LOCKED_FILE ]
    then
        [ ! -f $LOCKED_FILE ] && echo no>$LOCKED_FILE
        cat $LOCKED_FILE
    fi
}

function service_manager
{
    if [ $(service_running $SERVICE) -eq $YES ]
    then
        count=`sudo systemctl status $SERVICE.service --no-pager 2>&1 | grep 'active (running)' -c`
        if [ "$count" != "0" ]
        then
            count=`sudo systemctl status $SERVICE.service --no-pager 2>&1 | grep 'init.d' -c`
            if [ "$count" != "0" ]
            then
                echo $SYSTEMD_GEN
            else
                echo $SYSTEMD
            fi
        else
            echo $SYSVINIT
        fi
    else
        f=/etc/systemd/system/${SERVICE}.service
        if [ -e $f ]
        then
            echo $SYSTEMD
        else
            count=`sudo systemctl status $SERVICE.service --no-pager 2>&1 | grep 'init.d' -c`
            if [ "$count" != "0" ]
            then
                echo $SYSTEMD_GEN
            else
                echo $SYSVINIT
            fi
        fi
    fi
}

function service_running
{
    procid=`pidof $SERVICE`
    ret=$YES
    [ "$procid" == '' ] && ret=$NO
    echo $ret
}

function manage_service
{
    if [ "$2" == "start" ]
    then
        if [ $(service_running $SERVICE) -eq $NO ]
        then
            if [ $(service_manager $SERVICE) != $SYSVINIT ]
            then
                echo -e "\n"sudo systemctl enable $SERVICE.service
                sudo systemctl enable $SERVICE.service >/dev/null 2>&1
                echo -e "\n"sudo systemctl start $SERVICE.service
                sudo systemctl start $SERVICE.service
            else
                if [ -x "$SYSVINIT_ORIG" ]
                then
                    echo -e "\n"sudo "$SYSVINIT_ORIG" $2
                    sudo "$SYSVINIT_ORIG" $2
                else
                    echo -e "\n"sudo /etc/init.d/$SERVICE $2
                    sudo /etc/init.d/$SERVICE $2
                fi
            fi

            # for automatic restart if crashed:
            if [ -e $MXWATCHDOG ]
            then
                [ ! -e $WDOG_ACTIVE ] && echo y >$WDOG_ACTIVE
            fi
        fi
    elif [ "$2" == "stop" ]
    then
        if [ $(service_running $SERVICE) -eq $YES ]
        then
            if [ $(service_manager $SERVICE) != $SYSVINIT ]
            then
                echo -e "\n"sudo systemctl stop $SERVICE.service
                sudo systemctl stop $SERVICE.service
                echo -e "\n"sudo systemctl disable $SERVICE.service
                sudo systemctl disable $SERVICE.service >/dev/null 2>&1
            else
                if [ -x "$SYSVINIT_ORIG" ]
                then
                    echo -e "\n"sudo "$SYSVINIT_ORIG" $2
                    sudo "$SYSVINIT_ORIG" $2
                else
                    echo -e "\n"sudo /etc/init.d/$SERVICE $2
                    sudo /etc/init.d/$SERVICE $2
                fi
            fi
        fi
            
        if [ -e $MXWATCHDOG ]
        then
            rm -f $WDOG_ACTIVE
        fi
    fi
}

function get_backups
{
    space=`printf '\xE2\x80\x89'`
    cd $BACKUP_PATH; 
    files=`ls -x1 --sort=time *.tar.gz`
    for fil in $files 
    do
        dat=`stat -c%z $fil`
        dat=${dat%:*}
        dat="${dat// /$'_'}"
        echo "$dat$space$fil"
    done
}

#----------
#b Commands
#----------
LOCKED=`get_LOCKED`

PARAM1=''$1
case $PARAM1 in
    version) 
        echo ''
        echo $MODULE $VERSION $WRITTEN
        SCRIPT=$(realpath "$0")
        echo $SCRIPT
        SCRIPT_S=$(realpath -s "$0")
        [ "$SCRIPT" != "§SCGRIPR_S" ] && echo $SCRIPT_S
        echo ''
        ;;
    logrotate) 
        echo ''
        echo force logrotate $SERVICE.log
        sudo logrotate -f /etc/logrotate.d/z-way-server
        ;;
    status) 
        if [ $(service_running $SERVICE) -eq $YES ]
        then
            echo $SERVICE is running

            count=`pidof $SERVICE | wc -w`
            if [ $count -gt 1 ]
            then
                echo ''
                echo "warning: $SERVICE is running $count times !!!"
                ps aux | grep "$SERVICE" | grep -v grep | grep -v '/z-way-server'
                echo ''
            fi
        else
            echo $SERVICE is not running
        fi
        f=/etc/init.d/$SERVICE
        [ -e $f ] && echo $f existing
        f=/etc/systemd/system/${SERVICE}.service
        [ -e $f ] && echo $f existing
        echo startmanager: $(service_manager $SERVICE)

        CONFIG=/opt/z-way-server/config.xml
        LOG_LEVEL=`grep  log-level $CONFIG`
        LOG_LEVEL="${LOG_LEVEL#*>}"
        LOG_LEVEL="${LOG_LEVEL%<*}"
        echo "current log-level: $LOG_LEVEL"
        echo ''

        if [ -e $MXWATCHDOG ]
        then
            if [ -e $WDOG_ACTIVE ]
            then
                echo watchdog is active
            else
                echo watchdog is deactivated
            fi
        fi

        if [ "$LOCKED" != "" ]
        then
            [ "$LOCKED" == 'no' ] && echo Mx modules are not locked
            [ "$LOCKED" == 'yes' ] && echo all Mx modules are locked !!!!!!!!!!!!!!!!!
        fi
   
        if [ "$MQTT_PORT" != "" ]
        then 
            #display open MQTT sockets
            echo ''
            echo MQTT sockets:
            ss -tr | grep "State"
            for p in $MQTT_PORT
            do
                ss -tr | grep ":$p"
            done
        fi

        if [ "$USERPW" != "" ]
        then
            echo ''
            $0 jobcount
        fi
        echo ''
        if [ $(service_running $SERVICE) != $NO ]
        then
            procid=`pidof $SERVICE`
            ps -p $procid -o %cpu,%mem,cmd
        fi

        echo ''
        if [ $(service_running $SERVICE) == $NO ] && 
           [ -e ${ZWAY_DIR}zway_threads.bash ]
        then
            ${ZWAY_DIR}zway_threads.bash
        fi
        ;;
    details) 
        sudo systemctl --no-pager status $SERVICE >/dev/null 2>&1
        # 0	"program is running or service is OK"	unit is active
        # 1	"program is dead and /var/run pid file exists"	unit not failed (used by is-failed)
        # 2	"program is dead and /var/lock lock file exists"	unused
        # 3	"program is not running"	unit is not active
        # 4	"program or service status is unknown"	no such unit
        if [ $? -ne 4 ]
        then
            systemctl --no-pager status $SERVICE --no-pager -l

            #echo journalctl -u z-way-server -n 10 --no-pager
            #journalctl -u z-way-server -n 10 --no-pager
        fi

        if [ $(service_running $SERVICE) != $NO ]
        then
            echo ''
            procid=`pidof $SERVICE`
            pstree -hclpt $procid

            echo ''
        fi
        ;;
    jobqueue) 
        if [ "$USERPW" == '' ]
        then
            echo 'parameter $USERPW must be defined to get jobqueue'
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
                    lines=`echo $queue | sed 's/\]\],/\\]\],\n/g' | nl`
                    echo "$lines" | while read line
                    do
                        devid=`echo $line | grep -Po '],(\d{1,3}),' | grep -Po '\d*'`
                        echo $line
                        echo '  *** ' $devid=${zwave_devices[$devid]}
                    done
                    echo ''
                    echo -n 'current number of jobs in queue: '; echo $queue | sed 's/\]\],/\\]\],\n/g' | wc -l 
                fi
            else
                echo $queue
            fi
        fi
        ;;
    jobcount) 
        if [ "$USERPW" == '' ]
        then
            echo 'parameter $USERPW is not defined'
        elif [ $(service_running $SERVICE) != $NO ]
        then
            echo 'jobqueue:'
            queue=`curl -s -u $USERPW --globoff "$IP:8083/ZWaveAPI/InspectQueue"`

            firstchar=${queue:0:1}
            if [ "$firstchar" == "[" ]
            then
                if [ "$queue" == "[]" ]
                then
                echo -n 'current number of jobs in queue: 0'
                else
                    echo -n 'current number of jobs in queue: '; echo $queue | sed 's/\]\],/\\]\],\n/g' | wc -l 
                fi
            else
                echo $queue
            fi
        fi
        ;;
    cpu) 
        if [ $(service_running $SERVICE) != $NO ]
        then
            ${ZWAY_DIR}zway_cpu.bash
        fi
        ;;
    top) 
        if [ $(service_running $SERVICE) != $NO ]
        then
            procid=`pidof $SERVICE`
            top -Hp $procid
        fi
        ;;
    system) 
        cat /sys/firmware/devicetree/base/model
        echo -n ' Serial#:' ; cat /proc/cpuinfo | grep Serial | cut -d' ' -f2
        echo -n 'Memory:' ; cat /proc/meminfo | grep MemTotal | cut -c16-
        echo Software architecture: `dpkg --print-architecture`=`getconf LONG_BIT` bit
        cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2
        uname -a

        echo ''
        DATA=/opt/z-way-server/config/zddx/0e0d0c0b-DevicesData.xml
        if [ -f "$DATA" ]
        then
            function gr {
              grep -m1 '"'$1'"' $DATA | sed 's/^.*value="//' | sed 's/".*$//'
            }
            vendor=`gr vendor`
            ZWaveChip=`gr ZWaveChip`
            SDK=`gr SDK`
            APIVersion=`gr APIVersion`
            PRODTYPE=`gr manufacturerProductType`
            PRODID=`gr manufacturerProductId`
            bootloader=`gr bootloader`
            if [ "$bootloader" == "null" ] || [ "$bootloader" == "" ]
            then
               bootloader=`gr bootloaderCRC`
               if [ "$bootloader" == "null" ] || [ "$bootloader" == "" ]
               then
                   bootloader=`gr crc`
               fi
            fi
            echo $vendor $ZWaveChip $SDK $APIVersion/$bootloader $PRODTYPE/$PRODID
        fi
        cd /opt/z-way-server; LD_LIBRARY_PATH=./libs ./z-way-server -h 2>/dev/null | head -n 1
        ;;
    start) 
        if [ $(service_running $SERVICE) == $NO ]
        then
            echo starting $SERVICE...
            manage_service $SERVICE stop
            sleep 3
            manage_service $SERVICE start
            ret=$?
        else
            echo service $SERVICE is already running
        fi
        ;;
    stop) 
        echo stopping $SERVICE...
        manage_service $SERVICE stop
        ret=$?
        ;;
    run_in_foreground) 
        read -p "Really run $SERVICE in foreground? [y,N] " CONT
        case ${CONT:-N} in
            ([Yy]) ;;
            ([Nn]) exit 200;;
            (*)    exit 200;;
            esac

        pushd $SERVICE_PATH >/dev/null 2>&1
            echo  LD_LIBRARY_PATH=libs ./z-way-server
            LD_LIBRARY_PATH=libs ./z-way-server
        popd 2>&1
        ;;
    lock) 
        echo locking all Mx modules...
        echo yes>$LOCKED_FILE
        ret=$?
        ;;
    unlock) 
        echo unlocking all Mx modules...
        echo no>$LOCKED_FILE
        ret=$?
        ;;
    backup) 
        if [ "$BACKUP_PATH" == '' ]
        then
            echo 'parameter $BACKUP_PATH must be defined for backup and restore'
        else
            if [ $(service_running $SERVICE) -eq $YES ]
            then
                echo stop service $SERVICE first, break!
                exit 1
            fi

            SOURCE_FOLDER=z-way-server
            VERS_CURR=`cd /opt/z-way-server; LD_LIBRARY_PATH=./libs ./z-way-server -h 2>/dev/null | head -n 1 | cut -d' ' -f3`
            TS=`date +%s`
    
            echo 'This function saves the whole z-way-server tree into a *.tar.gz archive.'
            echo "It's not the same as creating *.zab and *.zbk backups!"
            echo ''
    
            if [ -d "$BACKUP_PATH" ]
            then
                echo "backup folder $BACKUP_PATH"
            else
                read -p "backup folder $BACKUP_PATH is not existing, create? [Y,n] " CONT
                case ${CONT:-Y} in
                    ([Yy]) ;;
                    ([Nn]) exit 200;;
                    (*)    exit 200;;
                esac

                if [ -e $MXWATCHDOG ]
                then
                    rm -f $WDOG_ACTIVE
                fi

                mkdir -pv "$BACKUP_PATH"
                ret=$?
                [ $ret -ne 0 ] && exit $ret
                echo ''
            fi
    
            BACKUP_FILE=${SOURCE_FOLDER}_${TS}_${VERS_CURR}.tar.gz

            read -p  "back up $SOURCE_FOLDER to ${BACKUP_FILE}? [Y,n] " CONT
            case ${CONT:-Y} in
                ([Yy]) ;;
                ([Nn]) exit 200;;
                (*)    exit 200;;
            esac

            pushd /opt/ >/dev/null 2>&1
                if [ -h "$SOURCE_FOLDER" ]
                then
                    LINK_PATH=`readlink $SOURCE_FOLDER`
                    cd $LINK_PATH/..
                fi
                sudo tar -cvzf $BACKUP_PATH/${BACKUP_FILE} $SOURCE_FOLDER
                ret=$?
                if [ "$ret" -eq 0 ]
                then
                    #create contents file
                    contents_backup=${ZWAY_DIR}contents_backup.bash
                    if [ -x "$contents_backup" ]
                    then
                        "$contents_backup" "$BACKUP_PATH/${BACKUP_FILE}"
                    fi
                fi
            popd >/dev/null 2>&1
        fi

        echo ''
        if [ $(service_running $SERVICE) -eq $YES ]
        then
            SM="$(service_manager $SERVICE)"
            echo $SERVICE was restarted with startmanager $SM
            echo ' !!!! (automatic restart during backup?)'
        else
            echo start $SERVICE again!
        fi
        ;;
    restore) 
        if [ "$BACKUP_PATH" == '' ]
        then
            echo 'parameter $BACKUP_PATH must be defined for backup and restore'
        elif [ ! -d "$BACKUP_PATH" ]
        then
            echo "backup folder $BACKUP_PATH is not existing, break!"
        else
            SOURCE_FOLDER=z-way-server
            VERS_CURR=`cd /opt/z-way-server; LD_LIBRARY_PATH=./libs ./z-way-server -h 2>/dev/null | head -n 1 | cut -d' ' -f3`
    
            echo 'This function restores the whole z-way-server tree from a *.tar.gz archive.'
            echo "It's not the same as restoring *.zab and *.zbk backups!"
            echo ''
    
            #OPT=`cd $BACKUP_PATH; ls -x1 --sort=time *.tar.gz`
            OPT=`get_backups`
            BACKUP_FILE=`${ZWAY_DIR}bashmenu.bash $BACKUP_PATH $OPT`
            [ "$BACKUP_FILE" == "" ] && exit 0
            [ "$BACKUP_FILE" == "break" ] && exit 0
            BACKUP_FILE="${BACKUP_FILE:17}"
    
            if [ $(service_running $SERVICE) -eq $YES ]
            then
                echo stop service $SERVICE first, break!
                exit 1
            fi

            read -p  "restore $SOURCE_FOLDER from ${BACKUP_FILE}? [Y,n] " CONT
            case ${CONT:-Y} in
                ([Yy]) ;;
                ([Nn]) exit 200;;
                (*)    exit 200;;
            esac

            if [ -e $MXWATCHDOG ]
            then
                rm -f $WDOG_ACTIVE
            fi
            extract_backup=${ZWAY_DIR}extract_backup.bash
            if [ ! -e "$extract_backup" ]
            then
                echo "$extract_backup" not found, break.
                exit 1
            fi
            cp "$extract_backup" "$BACKUP_PATH"

            pushd /opt/ >/dev/null 2>&1
                RESTORE_PATH=`dirname $SOURCE_FOLDER`
                if [ -h "$SOURCE_FOLDER" ]
                then
                    LINK_PATH=`readlink $SOURCE_FOLDER`
                    RESTORE_PATH=`dirname $LINK_PATH`
                fi
                #sudo tar -xvf $BACKUP_PATH/$BACKUP_FILE -C ${LINK_PATH} --overwrite
                $BACKUP_PATH/extract_backup.bash "$BACKUP_PATH/$BACKUP_FILE" "$RESTORE_PATH"
                ret=$?
                if [ $ret -ne 0 ]
                then
                    echo error restoring $BACKUP_FILE, break!
                    popd >/dev/null 2>&1
                    exit $ret
                fi
                echo ''
                VERS_NEW=`cd /opt/z-way-server; LD_LIBRARY_PATH=./libs ./z-way-server -h 2>/dev/null | head -n 1 | cut -d' ' -f3`
                echo version old: $VERS_CURR. version new: $VERS_NEW
            popd >/dev/null 2>&1
        fi

        echo ''
        if [ $(service_running $SERVICE) -eq $YES ]
        then
            SM="$(service_manager $SERVICE)"
            echo $SERVICE was restarted with startmanager $SM
            echo ' !!!! (automatic restart during restore?)'
        else
            echo start $SERVICE again!
        fi
        ;;
    up-downgrade) 
        if [ "$ARCHITECTURE" != 'armhf' ] && [ "$ARCHITECTURE" != 'amd64' ]
        then
            echo "this function is not supported for $ARCHITECTURE, break!"
            exit 1
        fi

        if [ $(service_running $SERVICE) -eq $YES ]
        then
            echo stop service $SERVICE first, break!
            exit 1
        fi

        VERS_CURR=`cd /opt/z-way-server; LD_LIBRARY_PATH=./libs ./z-way-server -h 2>/dev/null | head -n 1 | cut -d' ' -f3`

        zway_builds=`curl -s "$URL_CHANGELOG_AUTOM" --get --data-urlencode ''`
        versions=`echo $zway_builds | grep -Po '(\d{2}\.\d{2}\.\d{4}\sv\d+\.\d+\.*\S*)\s' | cut -dv -f2`
        MANUAL="manual input..."
        VERS_NEW=`${ZWAY_DIR}bashmenu.bash 'z-way versions' "$MANUAL" $versions`
        [ "$VERS_NEW" == "break" ] && exit 200

        if [ "$VERS_NEW" == "$MANUAL" ]
        then
            VERS_NEW=
            read -p "enter new $PRODUCT version (e.g. 4.1.1):" VERS_NEW
        fi
        [ "$VERS_NEW" == "" ] && exit 200
        echo target z-way version $VERS_NEW entered.
        
        echo ''
        PKG=z-way-${VERS_NEW}_${ARCHITECTURE}.deb
        echo filename=$PKG
       
        read -p "up-downgrade $PRODUCT from version $VERS_CURR to version v${VERS_NEW}? [Y,n] " CONT 
        case ${CONT:-Y} in
            ([Yy]) ;;
            ([Nn]) exit 200;;
            (*)    exit 200;;
        esac

        if [ -e $MXWATCHDOG ]
        then
            rm -f $WDOG_ACTIVE
        fi

        echo downloading $PKG to /tmp/...
        wget -O /tmp/$PKG ${URL_PACKAGE}/$PKG
        if [ $? -ne 0 ]
        then
            echo error downloading $PKG, break!
            exit 1
        fi
        
        echo ''
        read -p "install ${PKG}? [Y,n] " CONT 
        case ${CONT:-Y} in
            ([Yy]) ;;
            ([Nn]) exit 200;;
            (*)    exit 200;;
        esac

        echo installing ${PKG}...
        sudo dpkg -i /tmp/$PKG
        ret=$?
        if [ $? -ne 0 ]
        then
            echo error installing $PKG, break!
            exit 1
        fi
        echo ''
        VERS_NEW=`cd /opt/z-way-server; LD_LIBRARY_PATH=./libs ./z-way-server -h 2>/dev/null | head -n 1 | cut -d' ' -f3`
        echo version old: $VERS_CURR. version new: $VERS_NEW

        echo ''
        if [ $(service_running $SERVICE) -eq $YES ]
        then
            SM="$(service_manager $SERVICE)"
            echo $SERVICE was restarted with startmanager $SM
            if [ "$SM" != "$SYSVINIT" ]
            then
                echo ' !!!! (automatic restart during up-downgrade?)'
            fi
        else
            echo start $SERVICE again!
        fi
        ;;
    changelog) 
        ${ZWAY_DIR}zway_versions.bash
        ;;
    devices) 
        ${ZWAY_DIR}zwave_devices.bash --print
        ;;
    reboot) 
        sudo shutdown -r now
        ;;
    *)          
        OPT_START='status details system start run_in_foreground logrotate'
        OPT_STOP="status details cpu top jobqueue system stop logrotate"
        if [ $(service_running $SERVICE) == $NO ]
        then
            OPT="$OPT_START"
        else
            OPT="$OPT_STOP"
        fi
        if [ "$LOCKED" != "" ]
        then
            [ $LOCKED == "no" ]  && lockaction=lock
            [ $LOCKED == "yes" ] && lockaction=unlock
            option=`${ZWAY_DIR}bashmenu.bash $_self $OPT "backup z-way-server" "restore z-way-server" "changelog versions" "up-downgrade z-way" "devices (zwave)" "${lockaction} Mx modules" "reboot"`
        else
            option=`${ZWAY_DIR}bashmenu.bash $_self $OPT "backup z-way-server" "restore z-way-server" "changelog versions" "up-downgrade z-way" "devices (zwave)" "reboot"`
        fi

        case "$option" in
            "")
                echo -n 'usage: '$_self' status|details|top|jobcount|jobqueue|cpu|start|stop|run_in_foreground|logrotate|backup|restore|changelog|up-downgrade|devices|reboot'
                if [ "$LOCKED" != "" ]
                then
                    echo '|lock|unlock'
                else
                    echo ''
                fi
                echo ''
                ret=1
                ;;
            "break")
                ;;
            *)
                echo ''
                eval "$COMMAND_PRE"
                echo ''
                $0 $option
                ret=$?
                echo ''
                [ $ret -ne 200 ] && read -p "press any key..."
                $0
                ;;
        esac
        ;;
esac

exit $ret
