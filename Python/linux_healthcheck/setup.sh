#!/bin/bash -e

# This script creates a virtual environment and runs the health_check python script

DIR="/tmp/hcheck"
SRC="/tmp/hcheck/test/bin"

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
	fi
}

#Call function
pycheck

#Check if folder already exists and avoid recreating
if [ -d "$DIR" ] 
then
	echo "$DIR already exists....running script again.."
        echo
	source "$SRC/activate"
	python3 health_check.py
else
	echo "$DIR does not exist... creating directory"
	echo
	mkdir "$DIR"
	echo "creating python virtual environment..."
	echo
	python3 -m venv "$DIR/test"
	source "$SRC/activate" && pip install -r requirements.txt
	python3 health_check.py

fi


