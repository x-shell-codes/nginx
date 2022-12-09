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
RED_LINE=$(tput setaf 1)
YELLOW_LINE=$(tput setaf 3)
GREEN_LINE=$(tput setaf 2)
BLUE_LINE=$(tput setaf 4)
POWDER_BLUE_LINE=$(tput setaf 153)
BRIGHT_LINE=$(tput bold)
REVERSE_LINE=$(tput smso)
UNDER_LINE=$(tput smul)

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
# Version                                                                                                              #
########################################################################################################################
function Version() {
  echo "create_domain version 1.0.0"
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
  echo "Nginx domain creation script."
  echo
  echo "Options:"
  echo "-d | --domain        Domain name (example.com)"
  echo "-s | --subdomain     Subdomain name (api)"
  echo "-l | --isLocal       Is local env (auto-deject). Values: true, false"
  echo "-c | --certificate   SSL Certificate installation (true). Values: true, false"
  echo "-h | --help          Display this help."
  echo "-V | --version       Print software version and exit."
  echo
  echo "For more details see https://github.com/x-shell-codes/nginx."
}

########################################################################################################################
# Arguments Parsing                                                                                                    #
########################################################################################################################
certificate=true

isLocal=false
if [ -d "/vagrant" ]; then
  isLocal=true
fi

for i in "$@"; do
  case $i in
  -d=* | --domain=*)
    domain="${i#*=}"

    if [ -z "$domain" ]; then
      ErrorLine "Domain name is empty."
      exit
    fi

    shift
    ;;
  -s=* | --subdomain=*)
    subdomain="${i#*=}"

    if [ -z "$subdomain" ]; then
      ErrorLine "Subdomain name is empty."
      exit
    fi

    shift
    ;;
  -l=* | --isLocal=*)
    isLocal="${i#*=}"

    if [ "$isLocal" != "true" ] && [ "$isLocal" != "false" ]; then
      ErrorLine "Is local value is invalid."
      Help
      exit
    fi

    shift
    ;;
  -c=* | --certificate=*)
    certificate="${i#*=}"

    if [ "$certificate" != "true" ] && [ "$certificate" != "false" ]; then
      ErrorLine "Certificate value is invalid."
      Help
      exit
    fi

    shift
    ;;
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
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG | grep "install ok installed")
  if [ "" = "$PKG_OK" ]; then
    ErrorLine "Nginx is not installed."
    exit
  fi
}

########################################################################################################################
# CertificateInstallation Function                                                                                     #
########################################################################################################################
function CertificateInstallation() {
  domain=$1
  subdomain=$2
  isLocal=$3

  wget https://raw.githubusercontent.com/x-shell-codes/ssl/master/ssl.sh
  bash ssl.sh --domain="$domain" --subdomain="$subdomain" --isLocal="$isLocal"
  rm ssl.sh
}

########################################################################################################################
# Main Program                                                                                                         #
########################################################################################################################
echo "${POWDER_BLUE_LINE}${BRIGHT_LINE}${REVERSE_LINE}CREATING DOMAIN${NORMAL_LINE}"

CheckRootUser

export DEBIAN_FRONTEND=noninteractive

NginxInstallCheck

if [ -z "$domain" ]; then
  ErrorLine "Domain name is empty."
  exit
elif [ -z "$subdomain" ]; then
  ErrorLine "Subdomain name is empty."
  exit
fi

InfoLine "/var/www/$domain checking if the folder exists."
if [ ! -d "/var/www/$domain" ]; then
  InfoLine "/var/www/$domain folder does not exist. Creating folder."
  mkdir /var/www/$domain
  SuccessLine "/var/www/$domain folder created."
else
  WarningLine "/var/www/$domain folder already exists."
fi
chown deployer:deployer /var/www/$domain -R

echo

InfoLine "/var/www/$domain/$subdomain checking if the folder exists."
if [ ! -d "/var/www/$domain/$subdomain" ]; then
  if [ "$isLocal" == "true" ]; then
    InfoLine "/vagrant folder exists. Symbolic link is being created from /vagrant to /var/www/$domain/$subdomain."
    ln -s /vagrant /var/www/$domain/$subdomain
    SuccessLine "/var/www/$domain/$subdomain folder created."
  else
    InfoLine "/var/www/$domain/$subdomain folder does not exist. Creating folder."
    mkdir /var/www/$domain/$subdomain
    SuccessLine "/var/www/$domain/$subdomain folder created."
  fi
else
  WarningLine "/var/www/$domain/$subdomain folder already exists."
fi
chown deployer:deployer /var/www/$domain/$subdomain -R

echo

if [ "$certificate" == "true" ]; then
  CertificateInstallation "$domain" "$subdomain" "$isLocal"
fi

echo

service nginx reload

InfoLine "--------------------------------------------"
InfoLine "Check whether the domain is created or not?"
InfoLine "--------------------------------------------"
echo "http://$subdomain.$domain"
if [ "$certificate" == "true" ]; then
  echo "https://$subdomain.$domain"
fi
