#!/bin/bash
# 定义镜像版本
version=5.0
# PHP版本
phpVersion="56 70 71 72"
# Dockerfile文件目录
dockerFilePath=${HOME}/docker/docker-files/web-nginx-php
# 定义yml文件路径
ymlFile=${HOME}/docker/php-laravel/docker-compose.yml
# 获取系统版本
system=$(uname)

for ver in ${phpVersion}
do
    cd ${dockerFilePath}${ver}
    # 编译docker镜像
    docker build -t maple52zoe/laravel-php${ver}:${version} .
    # 将新版本号写入docker-compose.yml文件
    if [[ ${system} -eq "Darwin" ]]; then
        sed -i '' "s#image: maple52zoe/laravel-php${ver}:.\.0#image: maple52zoe/laravel-php${ver}:${version}#g" ${ymlFile}
    else
        sed -i "s#image: maple52zoe/laravel-php${ver}:.\.0#image: maple52zoe/laravel-php${ver}:${version}#g" ${ymlFile}
    fi

done