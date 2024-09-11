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

SERVER_TYPE=$(echo $HOSTNAME | awk -F'.' '{print $2}')

if [ $SERVER_TYPE == "ct8" ];then
    DOMAIN=$USER.ct8.pl
elif [ $SERVER_TYPE == "serv00" ];then
    DOMAIN=$USER.serv00.net
else
    DOMAIN="unknown-domain"
fi

WORKDIR="/usr/home/$USER/domains/$DOMAIN/public_html"

setup(){  
    
    reading "\n确定要安装吗？【y/n】: " choice
    case "$choice" in
        [Yy])
          devil www options $DOMAIN php_exec on 
          generate_base_info  	                   
          generate_cron_snapshot 
          yellow "正在下载文件..."          
          download_php          
          download_cronrecovery_sh
          download_token_generator	
          generate_token 
          #show_url     
          ;;
        [Nn]) exit 0 ;;
    	  *) red "无效的选择，请输入y或n" && menu ;;
    esac  
}


uninstall(){
    yellow "正在卸载..."
    rm -f $WORKDIR/cronrecovery.php
    rm -f $WORKDIR/cronrecovery.sh
    rm -f $WORKDIR/token_generator
    rm -f $WORKDIR/snapshot.cron
    rm -f $WORKDIR/data.json
    rm -f $WORKDIR/token.txt    
    rm -f /usr/home/$USER/logs/cronrecovery.log
    green "卸载完成"
}

generate_web_token(){
	local content="{\"name\":\"$1\",\"psw\":\"$2\"}"
	local stringb64=$(echo -n "${content}" |base64 | sed 's#/#_#g' | sed 's/+/-/g' | sed 's/=//g')
	echo "$stringb64"
}

generate_base_info(){
    yellow "请输入 WEB_USERNAME（默认值：admin）："
    read -r WEB_USERNAME
    yellow "请输入 WEB_PASSWORD（默认值：password）："
    read -r WEB_PASSWORD
    WEB_USERNAME=${WEB_USERNAME:-'admin'}
    WEB_PASSWORD=${WEB_PASSWORD:-'password'}
cat > data.json << EOF
{
"WEB_USERNAME":"${WEB_USERNAME:-'admin'}",
"WEB_PASSWORD":"${WEB_PASSWORD:-'password'}",
"cmd":"/bin/bash $WORKDIR/cronrecovery.sh",
"url":"https://$DOMAIN/cronrecovery.php?token=$(generate_web_token ${WEB_USERNAME} ${WEB_PASSWORD})"
}
EOF
}

download_php(){
    rm -f $WORKDIR/cronrecovery.php
    yellow "正在下载 cronrecovery.php "
    wget -q --show-progress -c "https://raw.githubusercontent.com/sunq945/serv00-ct8_cron_recovery/main/cronrecovery.php" -O "cronrecovery.php"
    green "下载 cronrecovery.php 完毕"
}

download_cronrecovery_sh(){
    rm -f $WORKDIR/cronrecovery.sh
    yellow "正在下载 cronrecovery.sh "
    wget -q --show-progress -c "https://raw.githubusercontent.com/sunq945/serv00-ct8_cron_recovery/main/cronrecovery.sh" -O "cronrecovery.sh" &&  chmod +x cronrecovery.sh
    green "下载 cronrecovery.sh 完毕"
    
}

download_token_generator(){
    rm -f $WORKDIR/token_generator
    yellow "正在下载 token_generator "
    wget -q --show-progress -c "https://raw.githubusercontent.com/sunq945/serv00-ct8_cron_recovery/main/server" -O "token_generator" &&  chmod +x token_generator
    green "下载 token_generator 完毕"
    
}

generate_cron_snapshot(){
    rm -f snapshot.cron
    yellow "正在生成crontab记录快照..."   
    crontab -l > snapshot.cron
    # result=$(crontab -l)    
    green "生成crontab快照完毕"
}

generate_token(){
    local USERNAME
    local PASSWORD
    if [ -e data.json ];then
        USERNAME=$(jq -r '.WEB_USERNAME' data.json)
        PASSWORD=$(jq -r '.WEB_PASSWORD' data.json)
        if [ -z ${USERNAME} ] || [ -z ${PASSWORD} ];then
            red "错误： 读取变量 WEB_USERNAME 或  WEB_PASSWORD 为空！"
            exit -1
        fi
    else
        red "错误：$WORKDIR/data.json 不存在,请重新安装！"
        exit -1
    fi

    if [ -e ./token_generator ];then
        ./token_generator  ${USERNAME} ${PASSWORD} ${DOMAIN} cronrecovery.php 
    else
        red "错误：$WORKDIR/token_generator 不存在,请重新安装！"
    fi
}

show_token(){
    if [ -e ./token.txt ];then
        text=$(cat ./token.txt)
        green "token如下："
        purple "$text\n"    
    else
        red "错误：$WORKDIR/data.json 不存在,请重新安装！"
    fi   
}

update_base_info(){
    generate_base_info
    #show_url
    generate_token
}

#主菜单
menu() {
   cd $WORKDIR
   clear
   echo ""
   purple "============ serv00|ct8 恢复定时任务 一键安装脚本 v1.0.0=======\n"
   echo -e "${green}脚本地址：${re}${yellow}https://github.com/sunq945/serv00-ct8_cron_recovery${re}\n"
   purple "转载请注明出处，请勿滥用\n"
   green "1. 安装"
   echo  "==========================="
   green "2. 重新生成当前crontab快照"
   echo  "==========================="
   green "3. 更新网页用户名和密码"
   echo  "==========================="
   green "4. 查看token信息"
   echo  "==========================="   
   red "5. 卸载"
   echo  "===========================" 
   red "0. 退出脚本"
   echo  "==========================="
   reading "请输入选择(0-5): " choice
   echo ""
    case "${choice}" in
        1) setup ;;
        2) generate_cron_snapshot ;; 
        3) update_base_info ;;
        4) show_token ;;
        5) uninstall ;;      
        0) exit 0 ;;
        *) red "无效的选项，请输入 0 到 5" ;;
    esac
}
menu
