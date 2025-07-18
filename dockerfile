# 使用 nginx:alpine 作为基础镜像
FROM docker.io/library/nginx:alpine

# 设置工作目录
WORKDIR /app

# 复制当前目录下的文件到 Nginx 的默认 Web 目录，并设置所有者为 nginx 用户和组
COPY --chown=nginx:nginx . /app

# 添加自定义 Nginx 配置文件
#COPY site.conf /etc/nginx/conf.d/site.conf
RUN mv site.conf /etc/nginx/conf.d/site.conf

# 将 /etc/nginx/conf.d/default.conf 文件重命名为 default.conf.bak
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak

# 暴露 80 443 端口
EXPOSE 80
EXPOSE 443

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]