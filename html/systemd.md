
# Using Z-Way with Systemd

To run Z-Way with the **Systemd** startup mechanism, several things 
need to be taken into account.


## The Systemd Configuration File

A working configuration file **z-way-server.service** for Z-Way:

<span style="font-size:14px">
<pre>

\# z-way-server.service: systemd configuration file<br>
[Unit]
Description=Z-Way Server <br>
[Service]
User=root
Group=root<br>
Environment=PATH=/bin:/usr/bin:/sbin:/usr/sbin
WorkingDirectory=/opt/z-way-server
ExecStart=/opt/z-way-server/z-way-server<br>
\#Restart=no
\#RestartSec=2min<br>
[Install]
WantedBy=multi-user.target
</pre>
</span>

This configuration file is stored in folder **./install_systemd** 
and can be installed with the script **./install_systemd.bash**.<br>
For more information on the service unit configuration refer to the 
[freedesktop manual](https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html)


## Installation

1. stop the z-way-server:<br>
   **/etc/init.d/z-way-server stop**<br>
   don't delete the SysVinit configuration file /etc/init.d/z-way-server !
2. install the Systemd configuration file:<br>
   **./install_systemd.bash**
3. start the z-way-server:<br>
   **sudo systemctl enable z-way-server**<br>
   **sudo systemctl start z-way-server**

## The Behavior of Z-Way

Z-Way still uses the SysVinit start-stop mechanism in init.d. 
Especially the behavior on updates has to be considered:

1. First it stops a running z-way-server process with<br>
    <b>sudo /etc/init.d/z-way-server stop</b>
2. During the update it stores a new configuration file, but only if
   there isn't one.
3. At last it starts the z-way-server with<br>
    <b>sudo /etc/init.d/z-way-server stop</b><br>
    Also it creates new run-level-links for the configuration file. 

If you would migrate to Systemd and remove the configuration of SysVinit,
you would have to do some things manually on every update:

1. Before update:<br>
    stop the running z-way-server process
2. After the update:<br>
    stop the z-way-server again<br>
    remove the configuration file again<br>
    start z-way-server with the systemd command

That's inconvenient. And it could cause problems if it's forgotten.

## Coexistence of Systemd with SysVinit

I haven't found any clear information on the web that Systemd and SysVinit 
can coexist on the same process.
In my own tests, I haven't found any problems. The z-way-server is started 
only once at system boot.

If you want to be sure, you can change the startup command in the SysVinit 
configuration file like:
<span style="font-size:14px">
<pre>
<b>[ `pidof z-way-server` ] || </b>start-stop-daemon --start --pidfile $PIDFILE --make-pidfile --background --no-close --chdir $DAEMON_PATH --exec $NAME > /dev/null 2>&1
</pre>
</span>

or like
<span style="font-size:14px">
<pre>
<b>if [ ! -e /etc/systemd/system/z-way-server.service ]
then</b>
    start-stop-daemon --start --pidfile $PIDFILE --make-pidfile --background --no-close --chdir $DAEMON_PATH --exec $NAME > /dev/null 2>&1
<b>fi</b>
</pre>
</span>

This change will not be removed by Z-Way. Z-Way doesn't overwrite the 
configuration file during updates.

## Changes in the SysVinit Configuration File

To solve all the problems described above, at last I came to the following
modification of my SysVinit configuration file:

<span style="font-size:14px">
<pre>
<b>ZWAY_BASH=zway.bash
USERMODULES=$DAEMON_PATH/automation/userModules
ZWAY_BASH_PATH=$USERMODULES/MxBash/sh/$ZWAY_BASH</b>

case "$1" in
  start)
	if [ -x "$RESETFILE" ]; then
		"$RESETFILE" check_reset
	fi
    <b>if [ ! \`pidof $NAME\` ] 
    then
        PARENT=\`cat /proc/$PPID/comm\`
	    if [ -x "$ZWAY_BASH_PATH" ] && [ "$PARENT" != "$ZWAY_BASH" ]
        then
            echo Redirecting to "$ZWAY_BASH"
            "$ZWAY_BASH_PATH" start
        else</b>
	        echo -n "Starting z-way-server: "
	        start-stop-daemon --start --pidfile $PIDFILE --make-pidfile --background --no-close --chdir $DAEMON_PATH --exec $NAME > /dev/null 2>&1
	        echo "done."
        <b>fi
    fi</b>
	;;
  stop)
    <b>if [ \`pidof $NAME\` ] 
    then
        PARENT=\`cat /proc/$PPID/comm\`
	    if [ -x "$ZWAY_BASH_PATH" ] && [ "$PARENT" != "$ZWAY_BASH" ]
        then
            echo Redirecting to "$ZWAY_BASH"
            "$ZWAY_BASH_PATH" stop
        else</b>
    	    echo -n "Stopping z-way-server: "
	        start-stop-daemon --stop --quiet --pidfile $PIDFILE
	        rm -f $PIDFILE
	        echo "done."
        <b>fi
    fi</b>
	;;
</pre>
</span>

If MxBash doesn't exist, it works as normal.<br>
If MxBash exists, start and stop are always done by zway.bash. And 
zway.bash decides which mechanism to use.

This configuration file is stored in folder **./install_systemd** 
with name **SysVinit_z-way-server** and can be installed with the script 
**./install_init.d.bash**.


