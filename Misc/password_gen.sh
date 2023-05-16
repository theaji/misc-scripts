#!/bin/bash -e
# Author: Theo A
# Date: 02/02/23
# Description: Script to generate a random password 
# Modified: 05/15/23

echo
#Prompt user for how many characters to include in password and store in variable "input"
read -rp "How many characters would you like your password to be? : " input

#Only accept input between 8-100
if [ "$input" -ge "8" ] && [ "$input" -le "100" ] 2> /dev/null; then
  randompw=$(tr -dc 'A-Za-z0-9!"#$%&\()*+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c "$input")
  echo "Your randomly generated password is: "
  echo "$randompw"
else
  echo "Please enter a number between 8 and 100"
fi
echo

