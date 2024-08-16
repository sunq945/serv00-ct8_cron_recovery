#!/bin/bash

# 定义颜色
re="\033[0m"
red="\033[1;91m"
green="\e[1;32m"
yellow="\e[1;33m"
purple="\e[1;35m"
red() { echo -e "\e[1;91m$1\033[0m"; }
green() { echo -e "\e[1;32m$1\033[0m"; }
yellow() { echo -e "\e[1;33m$1\033[0m"; }
purple() { echo -e "\e[1;35m$1\033[0m"; }
reading() { read -p "$(red "$1")" "$2"; }

USERNAME=$(whoami)
HOSTNAME=$(hostname)

BASH_SOURCE="$0"
appname="keepalive"
LOGS_DIR="/usr/home/$USER/logs"
[ -d "$LOGS_DIR" ] || (mkdir -p "$LOGS_DIR" && chmod 755 "$LOGS_DIR")


SERVER_TYPE=$(echo $HOSTNAME | awk -F'.' '{print $2}')

if [ $SERVER_TYPE == "ct8" ];then
    DOMAIN=$USER.ct8.pl
elif [ $SERVER_TYPE == "serv00" ];then
    DOMAIN=$USER.serv00.net
else
    DOMAIN="unknown-domain"
fi

[[ $SERVER_TYPE == "ct8" ]] && WORKDIR="/usr/home/$USER/domains/$DOMAIN/logs" || WORKDIR="/usr/home/$USER/domains/$DOMAIN/logs"


printLog(){
    local time=$(date "+%Y-%m-%d %H:%M:%S")
    local log_str="[${time}]:$1"    
    local FILE=$BASH_SOURCE
    local filename=$(basename $FILE .sh)
    echo "$log_str" >> $LOGS_DIR/$filename.log
}

add_cron(){
    if [ -n "$(crontab -l)" ];then    
        printLog "cron job is normal"    
        exit 0
    fi

    if [ -e "./cron.snapshot" ];then
        crontab cron.snapshot
        printLog "cron added ok"    
        exit 1
    else
        red "cron.snapshot doesn't exit"
        printLog "cron.snapshot doesn't exit"
        exit -1
    fi
}

main(){
    cd $WORKDIR
    add_cron
}

main
