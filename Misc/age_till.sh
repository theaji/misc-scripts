#!/bin/bash -e
# Author: Theo A
# Date: 02/04/23
# Description: This script calculates and displays the year the user will turn 50
# Modified: 05/15/23

echo
YEAR=$(date +"%Y")
echo  "What is your name? " 
read -r NAME
echo  "What is your age? " 
read -r AGE
AGEIN=$(( 50 - "$AGE" + $"YEAR"))
echo "$NAME, you will be 50 years old in:" "$AGEIN"
echo

