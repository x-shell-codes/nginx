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
  echo "nginx version 1.0.0"
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
  echo "Set up a Linux nginx area."
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
# Install Function                                                                                                     #
########################################################################################################################
function Install() {
  if [ -f "install_nginx.sh" ]; then
    bash install_nginx.sh
  else
    wget https://raw.githubusercontent.com/x-shell-codes/nginx/master/install_nginx.sh
    bash install_nginx.sh
    rm install_nginx.sh
  fi
}

########################################################################################################################
# CreateDomain Function                                                                                                #
########################################################################################################################
function CreateDomain() {
  domain=$1
  subdomain=$2
  isLocal=$3
  certificate=$4

  if [ -f "create_domain.sh" ]; then
    bash create_domain.sh --domain="$domain" --subdomain="$subdomain" --isLocal="$isLocal" --certificate="$certificate"
  else
    wget https://raw.githubusercontent.com/x-shell-codes/nginx/master/create_domain.sh
    bash create_domain.sh --domain="$domain" --subdomain="$subdomain" --isLocal="$isLocal" --certificate="$certificate"
    rm create_domain.sh
  fi
}

########################################################################################################################
# Main Program                                                                                                         #
########################################################################################################################
echo "${POWDER_BLUE_LINE}${BRIGHT_LINE}${REVERSE_LINE}INSTALLING NGINX & CREATING DOMAIN${NORMAL_LINE}"

CheckRootUser

export DEBIAN_FRONTEND=noninteractive

if [ -z "$domain" ]; then
  ErrorLine "Domain name is empty."
  exit
elif [ -z "$subdomain" ]; then
  ErrorLine "Subdomain name is empty."
  exit
fi

Install

echo

CreateDomain "$domain" "$subdomain" "$isLocal" "$certificate"
