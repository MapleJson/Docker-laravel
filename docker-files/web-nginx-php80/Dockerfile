FROM centos:7

ENV php_conf /etc/php-fpm.d/www.conf

RUN set -eux; \
    rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    rpm -ivh  http://rpms.remirepo.net/enterprise/remi-release-8.rpm && \
    yum install nginx supervisor -y && \
    yum --enablerepo=remi,remi-php80 install php php-common php-devel php-cli php-gd php-posix php-pecl-redis php-pecl-zip php-mysqlnd php-pdo php-mbstring php-xml php-soap php-pecl-mcrypt php-mcrypt php-fpm php-bcmath php-pecl-mongodb php-pecl-event php-pecl-swoole php-process php-rdkafka php-yaf -y && \
    yum install -y git vim wget telnet && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer
ADD nginx.conf /etc/nginx/nginx.conf
ADD supervisord.conf /etc/supervisord.conf
ADD start.sh /start.sh
RUN sed -i \
    -e "s#user = apache#user = nginx#g" \
    -e "s#group = apache#group = nginx#g" \
    -e "s#php\_value\[session\.save\_handler\] = files#php_value[session.save_handler] = redis#g" \
    -e "s#php\_value\[session\.save\_path]    = \/var\/lib\/php\/session#php_value[session.save_path]    = 'tcp://redis-session:6379?auth=!redis-password'#g" ${php_conf} && \
    mkdir -p /home/data/www && \
    chown -R nginx:nginx /home && \
    chmod 755 /start.sh

VOLUME ["/home/data/www"]

EXPOSE 80 443
CMD ["/start.sh"]
