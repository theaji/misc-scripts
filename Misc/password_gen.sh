#!/bin/bash -e
# Author: Theo A
# Date: 02/02/23
# Description: Script to generate a random password 
# Modified date/reason: 06/02/23 - changed max password length from 100 to 50

echo
#Prompt user for how many characters to include in password and store in variable "input"
read -rp "How many characters would you like your password to be?: " input

#Only accept input between 8-50
if [ "$input" -ge "8" ] && [ "$input" -le "50" ] 2> /dev/null; then
  randompw=$(tr -dc 'A-Za-z0-9!"#$%&\()*+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c "$input")
  echo
  echo "Your randomly generated password is: "
  echo
  echo "$randompw"
else
  echo
  echo "ERROR! Please enter a number between 8 and 50"
fi
echo

