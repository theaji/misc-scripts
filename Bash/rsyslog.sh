#!/usr/bin/env bash
# Author; Theo
# Description: Script to set up an rsyslog server
# Modification reason: 07/02/2023 - script creation

#####################
#Initialize variables
#####################

DISTRO=$(cat /etc/*release | grep "^ID=" | sed s/^ID=//g)
RSYSLG=$(systemctl is-active rsyslog.service)
HAS_LOGROTATE="$(type "logrotate" &> /dev/null && echo true || echo false)"
SCRIPT="$0"
EXIT_ON_ERROR="true"


echo
echo "Running program $0 with $# arguments and with pid $$ on distribution $DISTRO"


#########################################
# help - used to provide usage guidance
#########################################

help() {
      echo
      echo "Supported cli arguments:"
      echo -e "\t[-h] ->> print this help (optional)"
      echo
      echo -e "\t[-d] ->> enable debug mode (optional)"
      echo
      echo "ALERT: This script should be executed as a user with sudo privileges"
      echo
      echo
 }


#########################
#debug: enable debug mode
#########################
debug() {
    set -x
}

### Set to true to exit if a non-zero exit status is encountered
if [ "${EXIT_ON_ERROR}" == "true" ]; then
      set -e
fi

########################################################
# checkfiles - verifies configurations files are present
########################################################
CheckFiles() {
    echo
    if [ -f /etc/rsyslog.conf ] && [ -f /tmp/60-remote-logs.conf ] && [ -f /tmp/rsyslog.conf ]
    then
   	 # Call CheckDistro function
   	 CheckDistro
    else
   	 echo "ERROR: Unable to find one or more configuration files. Please verify 60-remote-logs.conf and rsyslog.conf exist in the current directory. Also verify rsyslog is installed and the configuration file rsyslog.conf exists in /etc"
   	 echo
    fi
}

##############################################################
# checkDISTRO - verifies script is running on ubuntu or debian
##############################################################

CheckDistro()
{
    if [ "$DISTRO" != "ubuntu" ] && [ "$DISTRO" != "debian" ]
    then
   	 echo
   	 echo "This script was only tested on ubuntu/debian platforms"
   	 exit 1
    else
   	 echo
   	 echo "Script is running on supported platform... proceeding"
   	 sleep 1
     CheckRsyslog
    fi
}

#################################################
# checkrsyslog - verifies if rsyslog is installed
#################################################

CheckRsyslog() {
    if ! command -v rsyslogd &> /dev/null
    then
   	 	echo "rsyslog could not be found...please install the application and try again"
   	 	exit
     elif [ "$RSYSLG" != "active" ]
     then
             echo "rsyslog is not running....attempting to start it" && sudo systemctl start rsyslog.service || echo "there was an issue starting rsyslog" && exit 1
    	CheckLogrotate
	 else
   	  echo
   	  # Call CheckLogrotate function
   	  CheckLogrotate
   	  echo
fi
}

#################################################
# checklogrotate - ensures logrotate is installed
#################################################

CheckLogrotate(){
    if [ "${HAS_LOGROTATE}" != "true" ]; then
   	 echo "logrotate is not installed.... attempting to install"
   	 apt install logrotate -y || echo "There was an issue installing logrotate" && exit 1
	 MoveFiles
	 else
   	  echo
   	  # Call MoveFiles function
   	  MoveFiles
   	  echo
fi

}

###############################################
# movefiles - moves configuration files to /etc
###############################################

MoveFiles() {
    
    echo "Sit tight...copying configuration files"
    sleep 1

    # Replace current rsyslog configuration file and add another configuration file
    sudo mv /etc/rsyslog.conf /etc/rsyslog.conf.bk
    sudo mv /tmp/rsyslog.conf /etc/rsyslog.conf
    sudo mv /tmp/60-remote-logs.conf /etc/rsyslog.d/
    sudo mv /tmp/remotelogs /etc/logrotate.d/
    # create /var/log/remotelogs/ directory
    sudo mkdir -p /var/log/remotelogs/

    # change the ownership to root:adm
    sudo chown -R syslog:adm /var/log/remotelogs/
    
    # Call Verify function
    Verify
}

######################################
# verify - tests rsyslog configuration
######################################

Verify() {

    echo "Sit tight....verifying configuration files"
    sleep 2

    # verify configuration files
    rsyslogd -N1 -f /etc/rsyslog.conf && rsyslogd -N1 -f /etc/rsyslog.d/60-remote-logs.conf 
    if [ "$?" -ne 0 ]; then
     	echo "There was an issue verifying rsyslog configuration file" && exit 1
    	else
            	sleep 1
            	Restart
    	fi
}


###########################################
# restart - prompts user to restart rsyslog
###########################################

Restart ()
{
    # Prompt to restart rsyslog service
    read -rp "Enter 1 to restart rsyslog.service? " answer

    if [ "$answer" == "1" ]
    then
   	 sudo systemctl restart rsyslog.service
   	 sleep 2
   	 echo "rsyslog service has been restarted"
   	 sleep 1
   	 echo
            	cleanup
   	 echo "exiting... goodbye!"
    else
	  	 echo "Exiting....please manually restart rsyslog.service"
    fi
}


###########################################
# createfiles - creates configuration files
###########################################

CreateFiles() {
    
    # Create rsyslog configuration file
    cat << EOF > /tmp/rsyslog.conf
# /etc/rsyslog.conf configuration file for rsyslog
#
# For more information install rsyslog-doc and see
# /usr/share/doc/rsyslog-doc/html/configuration/index.html
#
# Default logging rules can be found in /etc/rsyslog.d/50-default.conf


#################
#### MODULES ####
#################

module(load="imuxsock") # provides support for local system logging
#module(load="immark")  # provides --MARK-- message capability

# provides UDP syslog reception
#module(load="imudp")
#input(type="imudp" port="514")

# provides TCP syslog reception
module(load="imtcp")
input(type="imtcp" port="514")

# provides kernel logging support and enable non-kernel klog messages
module(load="imklog" permitnonkernelfacility="on")

###########################
#### GLOBAL DIRECTIVES ####
###########################

#
# Use traditional timestamp format.
# To enable high precision timestamps, comment out the following line.
#
\$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat

# Filter duplicate messages
\$RepeatedMsgReduction on

#
# Set the default permissions for all log files.
#
\$FileOwner syslog
\$FileGroup adm
\$FileCreateMode 0640
\$DirCreateMode 0755
\$Umask 0022
\$PrivDropToUser syslog
\$PrivDropToGroup syslog

#
# Where to place spool and state files
#
\$WorkDirectory /var/spool/rsyslog

#
# Include all config files in /etc/rsyslog.d/
#
\$IncludeConfig /etc/rsyslog.d/*.conf
EOF
    cat << EOF > /tmp/60-remote-logs.conf
# define template for remote logging
# remote logs will be stored at /var/log/remotelogs directory
# each host will have specific directory based on the system %HOSTNAME%
# name of the log file is %PROGRAMNAME%.log such as sshd.log, su.log
# %HOSTNAME% is the Rsyslog message property
template (
	name="RemoteLogs"
	type="string"
	string="/var/log/remotelogs/%HOSTNAME%/%HOSTNAME%-%PROGRAMNAME%.log"
)

# gather all log messages from all facilities
# at all severity levels to the RemoteLogs template
*.* -?RemoteLogs

# stop the process once the file is written
stop
EOF

    # Create logrotate configuration file
    cat << EOF > /tmp/remotelogs

/var/log/remotelogs/*.log
/var/log/remotelogs/*/*.log
{
    	rotate 12
    	weekly
    	missingok
    	notifempty
    	compress
    	delaycompress
    	sharedscripts
    	postrotate
            	/usr/lib/rsyslog/rsyslog-rotate
    	endscript
}

EOF
    # Call CheckFiles function
    CheckFiles
}

#####################################
# cleanup - used to delete the script
#####################################

cleanup() {
 if [[ -f "${SCRIPT}" ]]; then
 rm "${SCRIPT}"
fi
 echo
echo

}
#############################
# Process input variables
############################
while getopts ":hd" opt; do
    case "${opt}" in
    	# display help
    	h)
      help # call help function
      exit 0
      	;;
    d)
      debug # call debug function
      	;;      
   	*) # incorrect option
      echo "Error: Invalid options"
      help
      exit 1
      	;;
	esac
done

###############
# BEGIN PROGRAM
###############
CreateFiles 
