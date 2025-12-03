#!/bin/bash

# 部署脚本：将项目文件复制到目标目录
# 排除 .git、.github、.dockerignore、dockerfile 等文件

# 源目录（当前工作目录）
SOURCE_DIR="."

# 目标目录（可通过环境变量 DEPLOY_TARGET_DIR 覆盖）
TARGET_DIR="${DEPLOY_TARGET_DIR:-/home/www}"

# 创建目标目录（如果不存在）
mkdir -p "$TARGET_DIR"

# 检查 rsync 是否可用
if command -v rsync &> /dev/null; then
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
  
  if [ $? -ne 0 ]; then
    exit 1
  fi
else
  # 如果没有 rsync，使用 tar 在 /tmp 创建临时目录再复制
  # 在 /tmp 创建临时目录（避免权限问题）
  TEMP_DIR="/tmp/deploy_$(basename $TARGET_DIR)_$$"
  mkdir -p "$TEMP_DIR"
  
  if [ ! -d "$TEMP_DIR" ]; then
    exit 1
  fi
  
  # 使用 tar 复制文件到临时目录，排除指定的文件和目录
  cd "$SOURCE_DIR" && \
  tar --exclude='.git' \
      --exclude='.github' \
      --exclude='.dockerignore' \
      --exclude='dockerfile' \
      --exclude='Dockerfile' \
      --exclude='.gitignore' \
      --exclude='*.sh' \
      -cf - . 2>/dev/null | (cd "$TEMP_DIR" && tar -xf - 2>&1 | grep -v "Cannot utime" | grep -v "Cannot open" || true)
  
  # 检查临时目录是否有内容
  if [ -d "$TEMP_DIR" ] && [ "$(ls -A $TEMP_DIR 2>/dev/null)" ]; then
    # 清空目标目录
    if [ -d "$TARGET_DIR" ]; then
      find "$TARGET_DIR" -mindepth 1 -delete 2>/dev/null || \
      find "$TARGET_DIR" -mindepth 1 -exec rm -rf {} + 2>/dev/null || \
      rm -rf "$TARGET_DIR"/* "$TARGET_DIR"/.[!.]* "$TARGET_DIR"/..?* 2>/dev/null
    fi
    
    # 确保目标目录存在
    mkdir -p "$TARGET_DIR"
    
    # 将临时目录内容复制到目标目录
    if ! cp -r "$TEMP_DIR"/* "$TARGET_DIR"/ 2>/dev/null; then
      # 如果 cp -r 失败，使用 find + cp 逐文件复制
      cd "$TEMP_DIR"
      find . -type d | while read dir; do
        if [ "$dir" != "." ]; then
          mkdir -p "$TARGET_DIR/$dir" 2>/dev/null
        fi
      done
      
      find . -type f | while read file; do
        target_file="$TARGET_DIR/$file"
        target_dir=$(dirname "$target_file")
        mkdir -p "$target_dir" 2>/dev/null
        cp "$file" "$target_file" 2>/dev/null
      done
    fi
    
    # 统计文件数量
    FILE_COUNT=$(find "$TARGET_DIR" -type f 2>/dev/null | wc -l)
    
    # 清理临时目录
    rm -rf "$TEMP_DIR" 2>/dev/null
    
    # 验证部署结果
    if [ ! -d "$TARGET_DIR" ] || [ "$FILE_COUNT" -eq 0 ]; then
      exit 1
    fi
  else
    rm -rf "$TEMP_DIR" 2>/dev/null
    exit 1
  fi
fi

