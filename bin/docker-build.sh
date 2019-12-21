#!/bin/bash
# 定义镜像版本
read -p "请输入你的镜像版本号,默认为[1.0]:" version

if [[ -z "${version}" ]]; then
	version=1.0
fi
# PHP版本
read -p "请输入你要编译的PHP版本,以空格分隔,默认为[56 70 71 72]:" phpVersion

if [[ -z "${phpVersion}" ]]; then
	phpVersion="56 70 71 72"
fi
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
        echo "=======> 开始生成镜像 ${hubName}/laravel-php${ver}:${version} <======="
        cd ${dockerFilePath}${ver}
        # 编译docker镜像
        docker build -t ${1}/laravel-php${ver}:${version} .
        # 将新版本号写入docker-compose.yml文件
        if [[ ${system} -eq "Darwin" ]]; then
            sed -i '' "s#image: maple52zoe/laravel-php${ver}:.\.0#image: ${1}/laravel-php${ver}:${version}#g" ${ymlFile}
        else
            sed -i "s#image: maple52zoe/laravel-php${ver}:.\.0#image: ${1}/laravel-php${ver}:${version}#g" ${ymlFile}
        fi
        echo "=======> 镜像${hubName}/laravel-php${ver}:${version}生成完成! <======="
        if [[ ${2} == y ]]; then
            # push到自己的仓库
            echo "=======> 开始push镜像 ${hubName}/laravel-php${ver}:${version} <======="
            docker push ${hubName}/laravel-php${ver}:${version}
            echo "=======> 镜像 ${hubName}/laravel-php${ver}:${version} push完成! <======="
        fi
    done
}

read -p "请输入你的仓库名称,默认为[maple52zoe]:" hubName

if [[ -z "${hubName}" ]]; then
	hubName=maple52zoe
fi

read -p "是否登录docker,并push镜像至你的docker hub？请输入[y|n],默认为[n]:" num

if [[ -z "${num}" ]]; then
	num=n
fi

if [[ ${num} == y ]]; then
    # 登录docker
    docker login
fi

# 编译docker
build_docker ${hubName} ${num}

