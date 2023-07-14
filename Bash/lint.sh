#!/bin/bash

# Quick script to lint all python files in a directory
# Install flake8 using: pip install flake8

FILES=$(ls ./*.py)

for FILE in $FILES
	do
	   echo "Linting $FILE.. result: "
           flake8 "$FILE" --count --select=E9,F63,F7,F82 --show-source --statistics
done

