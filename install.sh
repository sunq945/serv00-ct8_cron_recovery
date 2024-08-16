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

[[ $SERVER_TYPE == "ct8" ]] && WORKDIR="/usr/home/$USER/domains/$DOMAIN/public_html" || WORKDIR="/usr/home/$USER/domains/$DOMAIN/public_html"
[ -d "$WORKDIR" ] || (mkdir -p "$WORKDIR" && chmod 777 "$WORKDIR")

setup(){  
    
    reading "\n确定要安装吗？【y/n】: " choice
    case "$choice" in
        [Yy])
          devil www options $DOMAIN php_exec on 
          generate_base_info   
	                   
          generate_cron_snapshot 
          yellow "正在下载文件..."          
          download_php          
          download_keepalive_sh	 
          show_url     
          ;;
        [Nn]) exit 0 ;;
    	  *) red "无效的选择，请输入y或n" && menu ;;
    esac  
}


uninstall(){
    rm -f $WORKDIR/keepalive.php
    rm -f $WORKDIR/keepalive.sh
    rm -f $WORKDIR/cron.snapshot
    rm -f /usr/home/$USER/logs/keepalive.log
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
"cmd":"/bin/bash $WORKDIR/keepalive.sh",
"url":"https://$DOMAIN/keepalive.php?name=$WEB_USERNAME&psw=$WEB_PASSWORD"
}
EOF
}

download_php(){
    rm -f $WORKDIR/keepalive.php
    yellow "正在下载 keepalive.php "
    wget -q --show-progress -c "https://raw.githubusercontent.com/sunq945/serv00-ct8_keepalive/main/keepalive.php" -O "keepalive.php"
    green "下载 keepalive.php 完毕"
}

download_keepalive_sh(){
    rm -f $WORKDIR/keepalive.sh
    yellow "正在下载 keepalive.sh "
    wget -q --show-progress -c "https://raw.githubusercontent.com/sunq945/serv00-ct8_keepalive/main/keepalive.sh" -O "keepalive.sh" &&  chmod +x keepalive.sh
    green "下载 keepalive.sh 完毕"
    
}

generate_cron_snapshot(){
    rm -f cron.snapshot
    yellow "正在生成crontab记录快照..."   
    crontab -l > cron.snapshot
    result=$(crontab -l)    
    green "生成crontab快照完毕"
}

show_url(){
    local path=$(pwd)
    cd $WORKDIR
    if [ -e data.json ];then
        url=$(jq -r '.url' data.json)
    else
        red "错误：$WORKDIR/data.json 不存在,请重新安装！"
    fi
    green "keepalive 所使用的页面链接为："
    purple "$url"    
    # echo "$url" | xclip-selection c
    # yellow "上述链接已经为您复制到剪切板，直接到目标位置粘贴即可"
    printf "\n"
    cd $path
}

#主菜单
menu() {
   cd $WORKDIR
   clear
   echo ""
   purple "============ serv00|ct8 定时任务保活 一键安装脚本 =======\n"
   echo -e "${green}脚本地址：${re}${yellow}https://github.com/sunq945/serv00-ct8_keepalive${re}\n"
   purple "转载请注明出处，请勿滥用\n"
   green "1. 安装"
   echo  "==========================="
   green "2. 重新生成当前crotab快照"
   echo  "==========================="
   green "3. 查看网页链接信息"
   echo  "==========================="
   yellow "4. 卸载"
   echo  "===========================" 
   red "0. 退出脚本"
   echo  "==========================="
   reading "请输入选择(0-4): " choice
   echo ""
    case "${choice}" in
        1) setup ;;
        2) generate_cron_snapshot ;; 
        3) show_url ;;
        4) uninstall ;;      
        0) exit 0 ;;
        *) red "无效的选项，请输入 0 到 4" ;;
    esac
}
menu
