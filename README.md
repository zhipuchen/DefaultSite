# DefaultSite

一个基于 Nginx 的静态网站项目，提供 PDA 安装包下载服务。

## 项目概述

DefaultSite 是一个轻量级的静态网站，使用 Nginx 作为 Web 服务器。项目主要提供：
- 默认的 Nginx 欢迎页面
- PDA 安装包下载页面（包含内外网二维码）
- Docker 容器化部署支持
- 多种部署方式（GitHub Pages、远程服务器、私有 Docker 镜像仓库）

## 技术栈

- **Web 服务器**: Nginx (Alpine)
- **容器化**: Docker
- **CI/CD**: GitHub Actions
- **前端**: 原生 HTML + CSS + JavaScript
- **二维码生成**: QRCode.js

## 项目结构

```
DefaultSite/
├── .github/
│   └── workflows/
│       ├── release.yml      # 创建 GitHub Release 的 workflow
│       ├── static.yml       # 部署到 GitHub Pages 的 workflow
│       └── remote.yml       # 部署到远程服务器的 workflow
├── js/                     # JavaScript 库
│   └── qrcode.min.js       # 二维码生成库
├── img/                    # 图片资源
│   └── o_mylove.jpg        # 示例图片
├── index.html              # 默认首页（Nginx 欢迎页面）
├── download.html           # PDA 安装包下载页面
├── favicon.ico             # 网站图标
├── dockerfile              # Docker 镜像构建文件
├── site.conf               # Nginx 配置文件
├── build.sh                # 本地 Docker 构建和部署脚本
├── deploy.sh               # 远程服务器部署脚本
├── docker-command.sh       # Docker 相关命令脚本
├── remove.sh               # 清理脚本
└── .dockerignore           # Docker 构建忽略文件
```

## 主要功能

### 1. PDA 安装包下载页面
提供内外网下载链接的二维码，方便移动设备扫描下载：
- **外网下载**: 阿里云 OSS 上的 PDA.apk
- **内网下载**: 内网服务器上的 PDA.apk

访问地址: `http://your-server/download.html`

### 2. Docker 容器化部署
- 基于 `nginx:alpine` 镜像
- 暴露 80 和 443 端口
- 自定义 Nginx 配置
- 支持 Docker 私有镜像仓库部署

## 部署方式

### 方式一: GitHub Pages 部署

自动部署，当推送到 `main` 分支时触发：
```bash
git push origin main
```

访问地址: `https://your-username.github.io/DefaultSite/`

### 方式二: 远程服务器部署

配置 GitHub Actions 环境变量 `DEPLOY_TARGET_DIR` 后，推送到 `main` 分支时自动部署到远程服务器。

需要在 `.github/workflows/remote.yml` 中配置 `self-hosted` runner。

### 方式三: Docker 本地部署

使用 `build.sh` 脚本构建并部署：
```bash
bash build.sh
```

脚本会：
1. 构建镜像 `default_site:YYYYMMDD`
2. 标记并推送到私有镜像仓库 `127.0.0.1:5000`
3. 运行容器，映射端口 `12345:80`

### 方式四: 手动 Docker 部署

```bash
# 构建镜像
docker build -t default_site .

# 运行容器
docker run -d -p 8080:80 --name default_site default_site
```

### 方式五: rsync 手动部署

```bash
# 设置目标目录环境变量（可选，默认 /home/www）
export DEPLOY_TARGET_DIR=/path/to/target

# 运行部署脚本
bash deploy.sh
```

## GitHub Actions 工作流

### Build Release Package
- **触发条件**: 推送以 `v` 开头的 tag
- **功能**:
  - 压缩源码为 `release.zip`
  - 生成 Release Notes（基于 git commit 历史）
  - 创建 GitHub Release
  - 上传 `release.zip` 作为 Release 资源

```bash
# 创建 tag 并推送，触发 Release 构建
git tag v1.0.4
git push origin v1.0.4
```

### Deploy content to Pages
- **触发条件**: 推送到 `main` 分支
- **功能**: 自动部署到 GitHub Pages

### Deploy content to Remote Server
- **触发条件**: 推送到 `main` 分支
- **功能**: 通过 `deploy.sh` 部署到远程服务器
- **要求**: 配置 self-hosted runner 和 `DEPLOY_TARGET_DIR` 环境变量

## 开发说明

### 修改 Nginx 配置
编辑 `site.conf` 文件，需要重新构建 Docker 镜像。

### 添加静态资源
将文件放在项目根目录，会被自动复制到 Nginx 的 `/app` 目录。

### 修改下载页面
编辑 `download.html`，更新 APK 下载地址：
```javascript
const externalUrl = 'https://your-external-url.apk';
const internalUrl = 'http://your-internal-url.apk';
```

## 环境要求

- Docker (本地部署)
- Git
- GitHub 账号（GitHub Pages 和 Actions）
- 私有 Docker 镜像仓库（可选，`127.0.0.1:5000`）

## 许可证

[查看项目许可证文件]

## 联系方式

项目地址: https://github.com/zhipuchen/DefaultSite

---

最后更新: 2026-03-08
