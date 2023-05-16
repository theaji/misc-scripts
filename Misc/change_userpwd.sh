#!/bin/bash -e
# Author: Theo A
# Date: 02/02/23
# Description: Builds on the random password generator to reset the password for an individual user account
# Modified: 05/15/23

#Check if username is supplied or not
if [ $# -lt 1	 ]; then
echo "Please supply a username"
echo "Example: " sudo "$0" "username"
exit
fi

user=$1

echo
#Prompt user for how many characters to include in password and store in variable "input"
read -rp "How many characters would you like your password to be? : " input

#Only accept input between 8-100
if [ "$input" -ge "8" ] && [  "$input" -le "100" ] 2> /dev/null; then
  randompw=$(tr -dc 'A-Za-z0-9!"#$%&\()*+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c "$input")
  echo "$user":"$randompw" | chpasswd
  echo "The password for:" "$user" "has been changed to: "
  echo "$randompw"
else
  echo "Please enter a number between 8 and 100"
fi
echo
