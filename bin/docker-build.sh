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

read -p "请输入你的仓库名称,不输入默认为[maple52zoe]:" hubName

if [[ -z "${hubName}" ]]; then
	hubName=maple52zoe
fi

echo ${hubName}

read -p "是否登录docker,并push镜像至你的docker hub？确认请输入y:" num

if [[ ${num} == y ]]; then
    # 登录docker
    docker login
fi

# 编译docker
build_docker ${hubName}

if [[ ${num} == y ]]; then
    # push到自己的仓库
    docker push ${hubName}/laravel-php${ver}:${version}
fi

