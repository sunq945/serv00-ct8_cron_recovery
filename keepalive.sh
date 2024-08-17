#!/bin/bash

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

WORKDIR="/usr/home/$USER/domains/$DOMAIN/public_html"

printLog(){
    local time=$(date "+%Y-%m-%d %H:%M:%S")
    local log_str="[${time}]:$1"    
    local FILE=$BASH_SOURCE
    local filename=$(basename $FILE .sh)
    echo "$log_str" >> $LOGS_DIR/$filename.log
}

echo_msg(){
    printLog  "$1"
    printf "$1"
}

add_cron(){
    local msg
    if [ -n "$(crontab -l)" ];then    
        echo_msg "cron job is normal"
        exit 0
    fi

    if [ -e "./cron.snapshot" ];then
        if [ -n $(cat ./cron.snapshot) ];then
            crontab cron.snapshot
            echo_msg "cron added ok" 
            exit 1            
        else            
            echo_msg "cron.snapshot is empty,no need to crontab"   
            exit 1              
        fi

    else        
        echo_msg "cron.snapshot doesn't exit"
        exit -1
    fi
}

main(){
    cd $WORKDIR
    add_cron
}

main
