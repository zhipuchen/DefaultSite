#!/bin/bash

# 定义镜像名称
name=default_site
# 定义一个日期，格式为 YYYYMMDD
date=$(date +%Y%m%d)
# 定义镜像仓库地址
host=127.0.0.1:5000
# 定义容器端口
port=12345

# 删除重名的容器，先判断是否有重名的容器，如果有，就删除
if docker ps -a | grep -q "${name}_${date}"; then
    docker rm -f ${name}_${date}
    echo "已删除重名的容器"
fi

# 删除 dangling 镜像
if docker images ${host}/${name} --filter "dangling=true" -q | sort -u | grep -q .; then
    docker images ${host}/${name} --filter "dangling=true" -q | sort -u | xargs -r docker rmi -f
    echo "已删除 dangling 镜像"
fi

# 删除重名的镜像，先判断是否有重名的镜像，如果有，就删除
if docker images ${host}/${name}:${date} | grep -q ${date}; then
    docker rmi ${host}/${name}:${date}
    echo "已删除重名的镜像"
fi

# 构建新的镜像
docker build -t ${name}:${date} .
echo "已构建新的镜像"

# 打标签
docker tag ${name}:${date} ${host}/${name}:${date}
echo "已打标签"

# 删除刚刚构建的镜像
docker rmi ${name}:${date}
echo "已删除刚刚构建的镜像副本"

# 推送镜像
docker push ${host}/${name}:${date}
echo "已推送镜像"

# 如果端口被占用，则停止掉占用端口的容器
if docker ps -a | grep -q "${port}"; then
    docker stop $(docker ps -a | grep "${port}" | awk '{print $1}')
    echo "已停止占用端口的容器"
fi

# 运行新的容器
docker run -d -p ${port}:80 --name ${name}_${date} ${host}/${name}:${date}
echo "已拉取镜像并运行新的容器"