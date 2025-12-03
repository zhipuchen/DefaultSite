#!/bin/bash

# 部署脚本：将项目文件复制到目标目录
# 排除 .git、.github、.dockerignore、dockerfile 等文件

# 源目录（当前工作目录）
SOURCE_DIR="."

# 目标目录（可通过环境变量 DEPLOY_TARGET_DIR 覆盖）
TARGET_DIR="${DEPLOY_TARGET_DIR:-/home/www}"

# 创建目标目录（如果不存在）
mkdir -p "$TARGET_DIR"

# 先确保在目标服务器有安装rsync
# 使用 rsync 复制文件，排除指定的文件和目录
rsync -av --delete \
  --exclude='.git' \
  --exclude='.github' \
  --exclude='.dockerignore' \
  --exclude='dockerfile' \
  --exclude='Dockerfile' \
  --exclude='.gitignore' \
  --exclude='*.sh' \
  "$SOURCE_DIR/" "$TARGET_DIR/"

# 检查 rsync 执行结果
if [ $? -ne 0 ]; then
  exit 1
fi