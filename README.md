# serv00-ct8 crontab 列表的自动恢复


# 原理
受 [彻底颠覆以往对 Serv00 的保活方法——X-for-Serv00 为例](https://linux.do/t/topic/167096?page=1) 这篇文章的启发，原理如下
把当前的crontab列表快照一下，就是做个备份，保存在snapshot.cron中，然后做个脚本去检测当前crontab是否被清空，如果被清空则把备份的快照重新恢复到crontab中。而这个调用脚本的动作则是由一个php页面来完成的。这个php页面由第三方服务器来定时访问就可以了。

# 安装和使用

## 1、安装：
安装命令：
```
bash <(curl -fSsl https://raw.githubusercontent.com/sunq945/serv00-ct8_cron_recovery/main/install.sh)
```
## 2、使用：
安装完成后，会自动生成访问页面链接地址，你可以使用该地址，用第三方服务器来调用即可，这个目前本人还没有实践。可参考文章：

1、[彻底颠覆以往对 Serv00 的保活方法——X-for-Serv00 为例](https://linux.do/t/topic/167096?page=3)

2、https://github.com/k0baya/X-for-serv00

