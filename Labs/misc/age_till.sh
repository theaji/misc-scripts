#!/bin/bash -e
# This script calculates and displays the year the user will turn 50

YEAR=$(date +"%Y")
echo  "What is your name? " 
read -r NAME
echo  "What is your age? " 
read -r AGE
let AGEIN=(50-"$AGE")+"$YEAR"
echo "$NAME, you will be 50 years old in: " "$AGEIN"


