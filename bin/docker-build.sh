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

build_docker()
{
    for ver in ${phpVersion}
    do
        cd ${dockerFilePath}${ver}
        # 编译docker镜像
        docker build -t ${1}/laravel-php${ver}:${version} .
        # 将新版本号写入docker-compose.yml文件
        if [[ ${system} -eq "Darwin" ]]; then
            sed -i '' "s#image: maple52zoe/laravel-php${ver}:.\.0#image: ${1}/laravel-php${ver}:${version}#g" ${ymlFile}
        else
            sed -i "s#image: maple52zoe/laravel-php${ver}:.\.0#image: ${1}/laravel-php${ver}:${version}#g" ${ymlFile}
        fi

    done
}
read -p "是否登录docker,并push自己镜像至你的docker hub？确认请输入y:" num

if [[ ${num} == y ]]; then

    read -p "确认请输入你的仓库名称:" hubName
    # 登录docker
    docker login
    # 编译docker
    build_docker ${hubName}
    # push到自己的仓库
    docker push ${phpVersion}/laravel-php${ver}:${version}

else
    # 编译docker
    build_docker "maple52zoe"
fi

