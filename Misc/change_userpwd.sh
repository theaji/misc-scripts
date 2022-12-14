#/bin/bash -xe

#### Builds on the random password generator to reset the password for an individual user account

#Check if username is supplied or not
if [ $# -lt 1 ]; then
echo "Please supply a username"
echo "Example: " sudo $0 "username"
exit
fi

user=$1

#Prompt user for how many characters to include in password
read -p "How many characters would you like your password to be? : " input

#Only accept input between 8-100
if [ "$input" -ge "8" -a "$input" -le "100" ] 2> /dev/null; then
  randompw=$(tr -dc 'A-Za-z0-9!"#$%&\()*+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c $input)
  echo $user:$randompw | chpasswd
  echo "The password for:" $user "has been changed to: "
  echo $randompw
else
  echo "Please enter a number between 8 and 100"
fi


