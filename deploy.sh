#!/bin/bash

# 部署脚本：将项目文件复制到目标目录
# 排除 .git、.github、.dockerignore、dockerfile 等文件

# 打印环境变量日志
echo "=========================================="
echo "部署脚本 - 环境变量验证："
echo "=========================================="
if [ -z "${DEPLOY_TARGET_DIR}" ]; then
  echo "📋 DEPLOY_TARGET_DIR: 未从 Repository Secrets 读取"
  echo "   将使用脚本默认值"
else
  echo "✅ DEPLOY_TARGET_DIR: 已从 Repository Secrets 读取"
  echo "   变量长度: ${#DEPLOY_TARGET_DIR} 字符"
  echo "   （Repository Secrets 的值会被 GitHub Actions 自动隐藏为 ***）"
fi
echo "=========================================="

# 源目录（当前工作目录）
SOURCE_DIR="."

# 目标目录（可通过环境变量 DEPLOY_TARGET_DIR 覆盖）
TARGET_DIR="${DEPLOY_TARGET_DIR:-/home/www}"

# 打印最终使用的目标目录信息
echo "=========================================="
echo "部署配置："
echo "=========================================="
echo "源目录: $(pwd)"
echo "目标目录: $TARGET_DIR"
if [ -d "$TARGET_DIR" ]; then
  echo "目标目录状态: ✅ 已存在"
else
  echo "目标目录状态: ℹ️  不存在，将自动创建"
fi
echo "=========================================="

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
  
  if [ $? -eq 0 ]; then
    echo "部署成功！文件已复制到 $TARGET_DIR"
  else
    echo "部署失败！"
    exit 1
  fi
else
  # 如果没有 rsync，使用 tar 创建临时目录再替换
  echo "rsync 未安装，使用 tar 命令..."
  
  # 创建临时目录
  TEMP_DIR="${TARGET_DIR}.tmp.$$"
  mkdir -p "$TEMP_DIR"
  
  # 使用 tar 复制文件到临时目录，排除指定的文件和目录
  echo "开始复制文件到临时目录..."
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
    echo "文件复制到临时目录成功"
    
    # 备份旧目录（如果存在）
    OLD_DIR="${TARGET_DIR}.old.$$"
    if [ -d "$TARGET_DIR" ]; then
      mv "$TARGET_DIR" "$OLD_DIR" 2>/dev/null || {
        echo "警告: 无法重命名旧目录，尝试清空..."
        rm -rf "$TARGET_DIR"/* "$TARGET_DIR"/.[!.]* "$TARGET_DIR"/..?* 2>/dev/null
      }
    fi
    
    # 将临时目录移动到目标目录
    mv "$TEMP_DIR" "$TARGET_DIR" 2>/dev/null || {
      echo "尝试复制临时目录内容..."
      cp -r "$TEMP_DIR"/* "$TARGET_DIR"/ 2>/dev/null
      rm -rf "$TEMP_DIR"
    }
    
    # 清理旧目录备份
    rm -rf "$OLD_DIR" 2>/dev/null
    
    # 验证部署结果
    if [ -d "$TARGET_DIR" ] && [ "$(ls -A $TARGET_DIR 2>/dev/null)" ]; then
      echo "✅ 部署成功！文件已复制到 $TARGET_DIR"
      echo "已部署文件数量: $(find "$TARGET_DIR" -type f 2>/dev/null | wc -l)"
    else
      echo "❌ 部署失败！目标目录为空"
      exit 1
    fi
  else
    echo "❌ 部署失败！临时目录创建失败"
    rm -rf "$TEMP_DIR" 2>/dev/null
    exit 1
  fi
fi

