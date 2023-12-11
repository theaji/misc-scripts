#!/usr/bin/env bash
# Author: Theo
# Description: This script creates a virtual environment and runs the speedtest script
# Modified: 12/11/2023
# Modification reason: added help function


######################
# Initialize variables
######################

 
DIR="/tmp/speedtest"
SRC="/tmp/speedtest/test/bin"
EXIT_ON_ERROR="true"
DISTRO=$(cat /etc/*release | grep "^ID=" | sed s/^ID=//g | tr -d '"')



#########################################
# help - used to provide usage guidance
#########################################

help() {
  echo
  echo "Supported cli arguments:"
  echo -e "\t[-h] ->> print this help (optional)"
  echo
  echo -e "\t[-d] ->> run script in debug mode (optional)"
  echo
  echo "USAGE: $0 "
  echo
}

##############################
# debug - set debug if desired
##############################
debug() {
#if [ "${DEBUG}" == "true" ]; then
  set -x
#fi
}

### Set to true to exit if a non-zero exit status is encountered
if [ "${EXIT_ON_ERROR}" == "true" ]; then
  set -e
fi

#############################################
# checks - prerequisite checks
#############################################
# Check python is installed
pycheck() {
	echo
        echo "Checking if Python is installed..."
        echo	
	if ! command -v python3 > /dev/null 
	then
		echo "Python is not installed. Please install Python and try again"
		exit
	else
		echo "$(python3 --version)" is installed... continuing...
		echo
                setup
	fi
}


######################################################
# setup - program to be run
######################################################

setup() {
#Check if folder already exists and avoid recreating
if [ -d "$DIR" ] 
then
	echo "$DIR already exists....running script again.."
        echo
	source "$SRC/activate"
	python3 speedTest.py
else
	echo "$DIR does not exist... creating directory"
	echo
	mkdir "$DIR"
	echo "creating python virtual environment..."
	echo
	python3 -m venv "$DIR/test"
	source "$SRC/activate" && pip install -r requirements.txt
	python3 speedTest.py

fi

}

#############################
# Process input variables
############################

while getopts ":hcdi:n:" opt; do
	case "${opt}" in
    	# display help
    	h)
      	help # call help function
      	exit 0
      	;;
        d)
        debug
        ;;
   	*) # incorrect option
       	echo "Error: Invalid options"
       	help
       	exit 1
       	;;
	esac
done

################
# BEGIN PROGRAM
################

if [[ $# -gt 1 ]]; then
    	help
else
	echo
    	echo "Running on $DISTRO with PID $$"
	sleep 2
	pycheck
    	
fi

