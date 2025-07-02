# 使用 nginx:alpine 作为基础镜像
FROM nginx:alpine

# 复制当前目录下的文件到 Nginx 的默认 Web 目录，并设置所有者为 nginx 用户和组
COPY --chown=nginx:nginx . /usr/share/nginx/html

# 复制自定义 Nginx 配置文件（可选）
# 如果不需要自定义配置，可以注释掉这行
#COPY nginx.conf /etc/nginx/nginx.conf

# 暴露 80 端口
EXPOSE 80

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]