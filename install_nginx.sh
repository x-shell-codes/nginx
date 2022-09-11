#!/bin/bash

########################################################################################################################
# Find Us                                                                                                              #
# Author: Mehmet ÖĞMEN                                                                                                 #
# Web   : https://x-shell.codes/scripts/nginx                                                                          #
# Email : mailto:nginx.script@x-shell.codes                                                                            #
# GitHub: https://github.com/x-shell-codes/nginx                                                                       #
########################################################################################################################
# Contact The Developer:                                                                                               #
# https://www.mehmetogmen.com.tr - mailto:www@mehmetogmen.com.tr                                                       #
########################################################################################################################

########################################################################################################################
# Constants                                                                                                            #
########################################################################################################################
NORMAL_LINE=$(tput sgr0)
BLACK_LINE=$(tput setaf 0)
WHITE_LINE=$(tput setaf 7)
RED_LINE=$(tput setaf 1)
YELLOW_LINE=$(tput setaf 3)
GREEN_LINE=$(tput setaf 2)
BLUE_LINE=$(tput setaf 4)
POWDER_BLUE_LINE=$(tput setaf 153)
BRIGHT_LINE=$(tput bold)
REVERSE_LINE=$(tput smso)
UNDER_LINE=$(tput smul)

########################################################################################################################
# Version                                                                                                              #
########################################################################################################################
function Version() {
  echo "install_nginx version 1.0.0"
  echo
  echo "${BRIGHT_LINE}${UNDER_LINE}Find Us${NORMAL}"
  echo "${BRIGHT_LINE}Author${NORMAL}: Mehmet ÖĞMEN"
  echo "${BRIGHT_LINE}Web${NORMAL}   : https://x-shell.codes/scripts/nginx"
  echo "${BRIGHT_LINE}Email${NORMAL} : mailto:nginx.script@x-shell.codes"
  echo "${BRIGHT_LINE}GitHub${NORMAL}: https://github.com/x-shell-codes/nginx"
}

########################################################################################################################
# Help                                                                                                                 #
########################################################################################################################
function Help() {
  echo "Nginx installation script."
  echo
  echo "Options:"
  echo "-h | --help        Display this help."
  echo "-V | --version     Print software version and exit."
  echo
  echo "For more details see https://github.com/x-shell-codes/nginx."
}

########################################################################################################################
# Line Helper Functions                                                                                                #
########################################################################################################################
function ErrorLine() {
    echo "${RED_LINE}$1${NORMAL_LINE}"
}

function WarningLine() {
    echo "${YELLOW_LINE}$1${NORMAL_LINE}"
}

function SuccessLine() {
    echo "${GREEN_LINE}$1${NORMAL_LINE}"
}

function InfoLine() {
    echo "${BLUE_LINE}$1${NORMAL_LINE}"
}

########################################################################################################################
# Arguments Parsing                                                                                                    #
########################################################################################################################
for i in "$@"; do
  case $i in
  -h | --help)
    Help
    exit
    ;;
  -V | --version)
    Version
    exit
    ;;
  -* | --*)
    ErrorLine "Unexpected option: $1"
    echo
    echo "Help:"
    Help
    exit
    ;;
  esac
done

########################################################################################################################
# CheckRootUser Function                                                                                               #
########################################################################################################################
function CheckRootUser() {
  if [ "$(whoami)" != root ]; then
    ErrorLine "You need to run the script as user root or add sudo before command."
    exit 1
  fi
}

########################################################################################################################
# NginxInstallCheck Function                                                                                           #
########################################################################################################################
function NginxInstallCheck() {
  REQUIRED_PKG="nginx"
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
  if [ "" = "$PKG_OK" ]; then
    InfoLine "Installing $REQUIRED_PKG..."
    sudo apt -y install $REQUIRED_PKG
    SuccessLine "$REQUIRED_PKG installed."
  else
    WarningLine "$REQUIRED_PKG is already installed."
  fi
}

########################################################################################################################
# NginxConfEdit Function                                                                                               #
########################################################################################################################
function NginxConfEdit() {
  grep -q "include /var/www/*/*" /etc/nginx/nginx.conf

  if [ $? == 1 ]; then
    InfoLine "/etc/nginx/nginx.conf editing..."
    sed -i "/sites-enabled/a \        include /var/www/*/*/nginx.conf;" /etc/nginx/nginx.conf
    SuccessLine "/etc/nginx/nginx.conf edited."
  else
    WarningLine "/etc/nginx/nginx.conf already edited."
  fi

  service nginx restart
}

########################################################################################################################
# Main Program                                                                                                         #
########################################################################################################################
echo "${POWDER_BLUE_LINE}${BRIGHT_LINE}${REVERSE_LINE}   INSTALLING NGINX   ${NORMAL_LINE}"

CheckRootUser

NginxInstallCheck

echo

NginxConfEdit

echo

SuccessLine "Nginx installation completed."

echo

InfoLine "--------------------------------------------"
InfoLine "Check whether the nginx is installed or not?"
InfoLine "--------------------------------------------"

hostname=$(hostname -I)
ipv4=$(curl icanhazip.com -4 -s)
ipv6=$(curl icanhazip.com -6 -s)

echo 'http://127.0.0.1'
echo 'http://'"$hostname"
echo 'http://'"$ipv4"
if [ $ipv6 ]; then
  echo 'http://'"$ipv6"
fi
