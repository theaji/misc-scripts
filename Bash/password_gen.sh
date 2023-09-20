#!/usr/bin/env bash
# Author: Theo A
# Description: Generate a random password
# Modified date/reason: 6/2/23 - added help function

######################
# Initialize variables
######################

EXIT_ON_ERROR="true"
PASSWD_LENGTH=""

#########################################
# help - used to provide usage guidance
#########################################

help() {
  echo
  echo "Supported cli arguments:"
  echo -e "\t[-h] ->> print this help (optional)"
  echo
  echo -e "\t[-d] ->> turn on debug mode (optional)"
  echo
  echo -e "\t[-p] ->> specify password length (required)"
  echo
  echo "USAGE: $0 -p 12"
  echo
}


########################################
# debug: set debug for troubleshooting
########################################
debug() {
  set -x
}

### Set to true to exit if a non-zero exit status is encountered
if [ "${EXIT_ON_ERROR}" == "true" ]; then
  set -e
fi

###########################################
# generatepassword - displays new password
###########################################


GeneratePassword() {
#Only accept input between 8-50

if [ "$PASSWD_LENGTH" -ge "8" ] && [ "$PASSWD_LENGTH" -le "50" ] 2> /dev/null; then

  randompw=$(tr -dc 'A-Za-z0-9!"#$%&\()*+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c "$PASSWD_LENGTH")

  echo
  echo "Your randomly generated password is: "
  echo
  echo "$randompw"


else

  echo
  echo "ERROR! Please enter a number between 8 and 50"
  help

fi

echo

}


#############################
# Process input variables
############################

while getopts ":hdp:" opt; do
	case "${opt}" in
    	# display help
    	h)
      	help # call help function
      	exit 0
      	;;
   	 d)
      	debug
   	   ;;
    	p)
      	PASSWD_LENGTH="${OPTARG}";;
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


if [[ "$#" -gt 2 ]]; then
    	help
elif [[ "$#" -lt 2 ]]; then
    	help
else
    	GeneratePassword
fi
