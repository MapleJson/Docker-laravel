#!/bin/bash

source ./centos_square_config.ini

#红
err_echo(){
echo -e "\e[91m[Error]: $1 \e[0m"
}
#绿
info_echo(){
echo -e "\e[92m[Info]: $1 \e[0m"
}

#安装nginx
nginx_install()
{
info_echo "开始安装nginx!!!"
sleep 1
echo '[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/$basearch/
gpgcheck=0
enabled=1' > /etc/yum.repos.d/nginx.repo
yum install nginx -y
info_echo "nginx安装完成!!!"
}

#安装php
php_install()
{
info_echo "开始安装php!!!"
sleep 1
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum --enablerepo=remi,remi-php71 install php php-common php-devel php-cli php-gd php-redis php-pear php-mysqlnd php-pdo php-mbstring php-xml php-soap php-mcrypt php-fpm php-bcmath php-amqp php-event unzip zip php-zip -y
info_echo "php安装完成!!!"
}

#修改php.ini配置
php_changed()
{
info_echo "开始修改php.ini文件内容!!!"
sleep 1
#开启短标签(标签将被识别)
sed -i '/^short_open_tag = Off/i\#开启短标签(标签将被识别)' /etc/php.ini
sed -i 's/^short_open_tag = Off/short_open_tag = on/g' /etc/php.ini
#禁用特殊函数
sed -i '/^disable_functions =/i\#禁用特殊函数' /etc/php.ini
sed -i 's/^disable_functions =/disable_functions = phpinfo,exec,system,popen,pclose,shell_exec,dl,chmod,chown,eval/g' /etc/php.ini
#脚本最大执行秒数
sed -i '/^max_execution_time = 30/i\#脚本最大执行秒数' /etc/php.ini
sed -i 's/^max_execution_time = 30/max_execution_time = 120/g' /etc/php.ini
#分析请求数据的最大限制时间
sed -i '/^max_input_time = 60/i\#分析请求数据的最大限制时间' /etc/php.ini
sed -i 's/^max_input_time = 60/max_input_time = 120/g' /etc/php.ini
#限制提交的表单数量
sed -i '/;max_input_vars = 1000$/i\#限制提交的表单数量' /etc/php.ini
sed -i 's/;max_input_vars = .*/; max_input_vars = 10000/g' /etc/php.ini
#脚本执行的内存限制
sed -i '/memory_limit = 128M/i\#脚本执行的内存限制' /etc/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 12800M/g' /etc/php.ini
#设置报告错误的类型
sed -i '/^error_reporting = E_ALL \& \~E_DEPRECATED \& \~E_STRICT/i\#设置报告错误的类型' /etc/php.ini
sed -i 's/^error_reporting = E_ALL \& \~E_DEPRECATED \& \~E_STRICT/error_reporting = E_ALL \& \~E_NOTICE/g' /etc/php.ini
#上传单个文件最大字节
sed -i '/upload_max_filesize = 2M/i\#上传单个文件最大字节' /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' /etc/php.ini
#默认套接字超时时间
sed -i '/default_socket_timeout = 60/i\#默认套接字超时时间' /etc/php.ini
sed -i 's/default_socket_timeout = 60/default_socket_timeout = 120/g' /etc/php.ini
#修改php时区(上海时间)
sed -i 's/^;date.timezone =/i\#修改php时区(上海时间)'
sed -i 's/^;date.timezone =/date.timezone = Asia\/Shanghai/g' /etc/php.ini
info_echo "php.ini文件内容修改完成!!!"
}

#修改www.conf文件内容
wwwconf_changed()
{
info_echo "开始修改wwwconf文件!!!"
sleep 1
#设置php监听模式，使用了 Unix 套接字
sed -i '/^listen = 127.0.0.1:9000/i\#设置php监听模式，使用了 Unix 套接字' /etc/php-fpm.d/www.conf
sed -i 's/^listen = 127.0.0.1:9000/listen = \/dev\/shm\/php7-fpm.sock/g' /etc/php-fpm.d/www.conf
#设置监听所属者
sed -i '/^;listen.owner = nobody/i\#设置监听所属者' /etc/php-fpm.d/www.conf
sed -i 's/^;listen.owner = nobody/listen.owner = nginx/g' /etc/php-fpm.d/www.conf
#设置监听所属组
sed -i '/^;listen.group = nobody/i\#设置监听所属组' /etc/php-fpm.d/www.conf
sed -i 's/^;listen.group = nobody/listen.group = nginx/g' /etc/php-fpm.d/www.conf
#设置所属者
sed -i '/^user = apache/i\#设置所属者' /etc/php-fpm.d/www.conf
sed -i 's/^user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
#设置所属组
sed -i '/^group = apache/i\#设置所属组' /etc/php-fpm.d/www.conf
sed -i 's/^group = apache/group = nginx/g' /etc/php-fpm.d/www.conf
#进程管理方式，如果设置成static，进程数自始至终都是pm.max_children指定的数量，pm.start_servers，pm.min_spare_servers，pm.max_spare_servers配置将没有作用
sed -i '/^pm = dynamic/i\#进程管理方式，如果设置成static，进程数自始至终都是pm.max_children指定的数量，pm.start_servers，pm.min_spare_servers，pm.max_spare_servers配置将没有作用' /etc/php-fpm.d/www.conf
sed -i 's/^pm = dynamic/pm = static/g' /etc/php-fpm.d/www.conf
#设置子进程的数量
sed -i '/^pm.max_children = 50$/i\#设置子进程的数量' /etc/php-fpm.d/www.conf
sed -i 's/^pm.max_children = .*/pm.max_children = 500/g' /etc/php-fpm.d/www.conf
#设置每个子进程重生之前服务的请求数。对于可能存在内存泄漏的第三方模块来说是非常有用的。如果设置为 '0' 则一直接受请求，等同于 PHP_FCGI_MAX_REQUESTS 环境变量。默认值：0
sed -i '/^;pm.max_requests = 500/i\#设置每个子进程重生之前服务的请求数。对于可能存在内存泄漏的第三方模块来说是非常有用的。如果设置为 0 则一直接受请求，等同于 PHP_FCGI_MAX_REQUESTS 环境变量。默认值：0' /etc/php-fpm.d/www.conf
sed -i 's/^;pm.max_requests = 500/pm.max_requests = 10240/g' /etc/php-fpm.d/www.conf
#FPM 状态页面的网址。如果没有设置，则无法访问状态页面，默认值：无
sed -i '/^;pm.status_path = \/status/i\#FPM 状态页面的网址。如果没有设置，则无法访问状态页面，默认值：无' /etc/php-fpm.d/www.conf
sed -i 's/^;pm.status_path = \/status/pm.status_path = \/status/g' /etc/php-fpm.d/www.conf
#设置单个请求的超时中止时间。该选项可能会对 php.ini 设置中的 'max_execution_time' 因为某些特殊原因没有中止运行的脚本有用。设置为 '0' 表示 'Off'。可用单位：s（秒），m（分），h（小时）或者 d（天）。默认单位：s（#i#秒）。默认值：0（关闭）
sed -i '/^;request_terminate_timeout = 0/i\#设置单个请求的超时中止时间。该选项可能会对 php.ini 设置中的 max_execution_time 因为某些特殊原因没有中止运行的脚本有用。设置为 0 表示 Off。可用单位：s（秒），m（分），h（小时）或者 d（天）。默认单位：s（#i#秒）。默认值：0（关闭）' /etc/php-fpm.d/www.conf
sed -i 's/^;request_terminate_timeout = 0/request_terminate_timeout = 180s/g' /etc/php-fpm.d/www.conf
#当一个请求该设置的超时时间后，就会将对应的 PHP 调用堆栈信息完整写入到慢日志中。设置为 '0' 表示 'Off'。可用单位：s（秒），m（分），h（小时）或者 d（天）。默认单位：s（秒）。默认值：0（关闭）。
sed -i '/^;request_slowlog_timeout = 0/i\#当一个请求该设置的超时时间后，就会将对应的 PHP 调用堆栈信息完整写入到慢日志中。设置为 '0' 表示 'Off'。可用单位：s（秒），m（分），h（小时）或者 d（天）。默认单位：s（秒）。默认值：0（关闭）。' /etc/php-fpm.d/www.conf
sed -i 's/^;request_slowlog_timeout = 0/request_slowlog_timeout = 5/g' /etc/php-fpm.d/www.conf
#设置文件打开描述符的 rlimit 限制。默认值：系统定义值
sed -i '/^;rlimit_files = 1024/i\#设置文件打开描述符的 rlimit 限制。默认值：系统定义值' /etc/php-fpm.d/www.conf
sed -i 's/^;rlimit_files = 1024/rlimit_files = 102400/g' /etc/php-fpm.d/www.conf
#重定向运行过程中的 stdout 和 stderr 到主要的错误日志文件中。如果没有设置，stdout 和 stderr 将会根据 FastCGI 的规则被重定向到 /dev/null。默认值：无
sed -i '/^;catch_workers_output = yes/i\#重定向运行过程中的 stdout 和 stderr 到主要的错误日志文件中。如果没有设置，stdout 和 stderr 将会根据 FastCGI 的规则被重定向到 /dev/null。默认值：无
' /etc/php-fpm.d/www.conf
sed -i 's/^;catch_workers_output = yes/catch_workers_output = yes/g' /etc/php-fpm.d/www.conf
#修改session相关
sed -i '/^php_value\[session.save_handler\] = files/i\#修改session相关' /etc/php-fpm.d/www.conf
sed -i 's/^php_value\[session.save_handler\] = files/php_value\[session.save_handler\] = Redis/g' /etc/php-fpm.d/www.conf
#修改session路径
sed -i "/^php_value\[session.save_path\]    = \/var\/lib\/php\/session/i\#修改session路径" /etc/php-fpm.d/www.conf
sed -i "s/^php_value\[session.save_path\]    = \/var\/lib\/php\/session/php_value\[session.save_path\]    = \'${session_save_path}\'/g" /etc/php-fpm.d/www.conf
#修改php用户
chown nginx.nginx /var/lib/php/ -R
info_echo "www.conf文件修改完成!!!"
}

#安装Composer PHP包管理工具
Composer_PHP()
{
info_echo "开始安装Composer_PHP包管理工具!!!"
sleep 1
yum install git -y
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
info_echo "安装Composer_PHP包管理工具完成!!!"
}

#生成nginx配置文件
nginx_changed()
{
info_echo "开始修改nginx配置文件!!!"
sleep 1
#创建目录
mkdir /etc/nginx/sites-enabled
#nginx主配置文件
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.back
cat << EOF > /etc/nginx/nginx.conf
user  root;
worker_processes 16;
error_log  /var/log/nginx/error.log  warn;
pid        /var/run/nginx.pid;
worker_rlimit_nofile 102400;
events
{
  use epoll;
  worker_connections 102400;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] requesthost:"\$http_host"; "\$request" requesttime:"\$request_time"; '
                      '\$status \$body_bytes_sent "\$http_referer" - \$request_body'
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;

    keepalive_timeout  120;
    server_names_hash_bucket_size 256;
    client_header_buffer_size 64k;
    client_max_body_size 10M;
    large_client_header_buffers 4 128k;
    sendfile on;
    server_tokens off;
    tcp_nopush on;
    tcp_nodelay on;
    open_file_cache max=65535 inactive=60s;
    open_file_cache_valid 80s;
    open_file_cache_min_uses 1;
    fastcgi_connect_timeout 300;
    fastcgi_send_timeout 300;
    fastcgi_read_timeout 300;
    fastcgi_buffer_size 512k;
    fastcgi_buffers 10 512k;
    fastcgi_busy_buffers_size 1024k;
    fastcgi_temp_file_write_size 1024k;
    fastcgi_intercept_errors on;

    gzip  on;
    gzip_http_version 1.0;
    gzip_disable "msie6";
    gzip_min_length 1k;
    gzip_buffers 4 128k;
    gzip_comp_level 3;
    gzip_types text/plain application/x-javascript text/css text/javascript application/x-httpd-php image/jpeg image/gif image/png;
    gzip_vary on;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*.conf;
}
EOF
#api_nginx配置文件
cat << EOF > /etc/nginx/sites-enabled/api.payqer.com.conf
server {
    listen  80; ## listen for ipv4
    server_name ${server_domain};
    access_log  /var/log/nginx/api.payqer.com.access.log main;
    root   ${server_root};
    index  index.html index.php index.htm;
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php {
        if (\$http_referer ~* "PHPSESSID") {
            return 555;
        }
        fastcgi_pass   unix:/dev/shm/php7-fpm.sock;
        fastcgi_index  index.php;
        set \$real_script_name \$fastcgi_script_name;
        if (\$fastcgi_script_name ~ "^(.+?\.php)(/.+)$") {
            set \$real_script_name \$1;
            set \$path_info \$2;
        }
        fastcgi_param SCRIPT_FILENAME ${server_root}\$real_script_name;
        fastcgi_param SCRIPT_NAME \$real_script_name;
        fastcgi_param PATH_INFO \$path_info;
        include fastcgi_params;
    }

    error_page  404 403        /40x.html;
    location = /40x.html {
            root   /usr/share/nginx/html;
    }

    location ~ .*\\.(ico|jpg|jpeg|png|bmp|swf)$
    {
        expires      off;
        access_log   off;
    }
    location ~ .*\\.(js|css)?$
    {
        expires   off;
        access_log off;
    }
}
EOF

info_echo "修改和添加nginx配置文件完成!!!"
}

#开始搭建web服务器
web_install()
{
info_echo "开始搭建web服务器!!!"
#修改时区
rm -rf /etc/localtime 
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
mkdir /etc/nginx/sites-enabled
mkdir -p /home/www
yum install rsync -y
info_echo "开始拉取程序代码!!!"
sleep 2
mkdir ${server_root}
/usr/bin/rsync  -vzrtopg  --delete --exclude ".svn/" --exclude ".env" --exclude "vendor/" --progress ${FaBuIp}:${FaBuRoot} ${server_root}
info_echo "开始拉取后台程序代码!!!"
#安装Composer PHP包管理工具
Composer_PHP
#搭建Composer_php
info_echo "开始搭建Composer_php"
sleep 1
cd ${server_root} && composer install
#修改.env配置文件
}

#首先安装nginx
nginx_install
#安装php
php_install
#修改php.ini配置
php_changed
#修改www.conf文件内容
wwwconf_changed
#开始修改nginx配置文件
nginx_changed
#开始搭建web服务器
web_install


