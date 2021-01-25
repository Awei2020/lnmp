#QQ:89605281
#lnmp自动部署
#!/bin/bash
echo -e "\033[32m 请关闭防火墙 如果是阿里云请打开安全组 \033[0m"
sleep 3

function nginx(){
if [ -d /etc/nginx ];then
	echo "存在nginx目录请检查环境"
exit 1
fi

echo -e "\033[32m 准备更新源 \033[0m"
sleep 3

yum -y install epel-release && yum update -y

if [ $? == 0 ];then
	echo -e "\033[32m 安装nginx源 \033[0m"
	sleep 2
	yum localinstall -y http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm && yum -y install nginx
else
	echo -e "\033[32m 安装失败，重启脚本 \033[0m"
	exit 1
fi
rm -f /etc/nginx/nginx.conf
mv ./nginx.conf /etc/nginx/nginx.conf
systemctl start nginx
systemctl enable nginx

echo -e "\033[32m 安装成功  \033[0m"

}

function php(){
echo -e "\033[32m 安装PHP  \033[0m"
sleep 2
php=`rpm -qa php*`
if [ "${php}x" != "x" ];then
	echo -e "\033[32m 存在php环境  \033[0m"
	exit 1
else
	rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
fi
if [ $? == 0 ];then
	yum install -y php71w php71w-cli php71w-common php71w-devel php71w-embedded php71w-gd php71w-mcrypt php71w-mbstring php71w-pdo php71w-xml php71w-fpm php71w-mysqlnd php71w-opcache php71w-pecl-memcached php71w-pecl-redis php71w-pecl-mongodb
else
	echo -e "\033[32m PHP安装失败  \033[0m"
	exit 1
fi

echo -e "\033[32m 请修改/etc/php-fpm.d/www.conf下的user和group为nginx  \033[0m"
rm -f /etc/php-fpm.d/www.conf
mv ./www.conf /etc/php-fpm.d/www.conf
systemctl start php-fpm.service
systemctl enable php-fpm.service
echo -e "\033[32m 安装成功  \033[0m"


}


function mysql(){
if [ -d /var/lib/mysql ];then
	echo -e "\033[32m 存在MySQL环境  \033[0m"
	exit 1

else
	echo -e "\033[32m 安装MySQL源  \033[0m"
	sleep 2
	yum -y localinstall http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm
fi
if [ $? == 0 ];then
	echo -e "\033[32m 安装MySQL  \033[0m"
	yum -y install mysql-community-server mysql-community-devel
else 
	echo -e "\033[32m 安装失败，重启脚本  \033[0m"
fi
systemctl start mysqld
systemctl enable mysqld
grep 'temporary password' /var/log/mysqld.log
grep 'temporary password' /var/log/messages
echo -e "\033[32m 请使用您的临时密码登录MySQL  \033[0m"
echo -e "\033[32m 安装成功  \033[0m"
}

read -p "请输入你的需求,1:nginx,2:PHP,3:MySQL:" need

case $need in
"1")
nginx
;;
"2")
php
;;
"3")
mysql
;;
*)
echo -e "\033[32m 请选择好你的参数  \033[0m"
;;
esac
