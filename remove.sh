#!/bin/bash

# 定义镜像名称
name=default_site
# 定义镜像仓库地址
host=127.0.0.1:5000

# 查询包含指定 name 的容器
if docker ps -a --filter "name=$name" -q | grep -q .; then
    # 删除所有匹配的容器
    docker ps -a --filter "name=$name" -q | xargs docker rm -f
    echo "已删除名字含有 $name 的容器"
else
    echo "未找到名字含有 $name 的容器，无需处理。"
fi

# 查询包含指定 name 的镜像
if docker images --filter "reference=$host/$name*" -q | sort -u | grep -q .; then
    # 删除所有匹配的镜像
    docker images --filter "reference=$host/$name*" -q | sort -u | xargs -r docker rmi -f
    echo "已删除名字含有 $host/$name 的镜像"
else
    echo "未找到名字含有 $host/$name 的镜像，无需处理。"
fi