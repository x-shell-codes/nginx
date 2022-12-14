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
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG | grep "install ok installed")
  if [ "" = "$PKG_OK" ]; then
    InfoLine "Installing $REQUIRED_PKG..."
    apt install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y --force-yes $REQUIRED_PKG
    systemctl enable nginx.service
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

  # Configure Primary Nginx Settings
  sed -i "s/user www-data;/user deployer;/" /etc/nginx/nginx.conf
  sed -i "s/worker_processes.*/worker_processes auto;/" /etc/nginx/nginx.conf
  sed -i "s/# multi_accept.*/multi_accept on;/" /etc/nginx/nginx.conf
  sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 128;/" /etc/nginx/nginx.conf

  service nginx restart
}

########################################################################################################################
# Main Program                                                                                                         #
########################################################################################################################
echo "${POWDER_BLUE_LINE}${BRIGHT_LINE}${REVERSE_LINE}INSTALLING NGINX${NORMAL_LINE}"

CheckRootUser

export DEBIAN_FRONTEND=noninteractive

NginxInstallCheck

echo

NginxConfEdit

# Generate dhparam File
if [ ! -f /etc/nginx/dhparams.pem ]; then
  openssl dhparam -out /etc/nginx/dhparams.pem 2048
fi

# Configure Gzip Settings
wget -O /etc/nginx/conf.d/gzip.conf https://raw.githubusercontent.com/x-shell-codes/nginx/master/conf.d/gzip.conf

# Configure Cloudflare Real IPs
wget -O /etc/nginx/conf.d/cloudflare.conf https://raw.githubusercontent.com/x-shell-codes/nginx/master/conf.d/cloudflare.conf

#service nginx restart
NGINX=$(ps aux | grep nginx | grep -v grep)
if [[ -z $NGINX ]]; then
  service nginx start
  echo "Started Nginx"
else
  service nginx reload
  echo "Reloaded Nginx"
fi

echo "deployer ALL=NOPASSWD: /usr/sbin/service nginx *" >>/etc/sudoers.d/nginx

# Add Deployer User To www-data Group
usermod -a -G www-data deployer
id deployer
groups deployer

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
