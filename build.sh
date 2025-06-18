#!/bin/bash

# Atlassian AI Gateway Proxy 构建脚本
# Build script for Atlassian AI Gateway Proxy

set -e

echo "🚀 开始构建 Atlassian AI Gateway Proxy..."
echo "🚀 Starting build for Atlassian AI Gateway Proxy..."

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装，请先安装Docker"
    echo "❌ Docker is not installed, please install Docker first"
    exit 1
fi

# 获取版本信息
VERSION=${1:-latest}
IMAGE_NAME="atlassian-proxy"
FULL_IMAGE_NAME="${IMAGE_NAME}:${VERSION}"

echo "📦 构建Docker镜像: ${FULL_IMAGE_NAME}"
echo "📦 Building Docker image: ${FULL_IMAGE_NAME}"

# 构建Docker镜像
docker build -t "${FULL_IMAGE_NAME}" .

echo "✅ 镜像构建完成: ${FULL_IMAGE_NAME}"
echo "✅ Image build completed: ${FULL_IMAGE_NAME}"

# 显示镜像信息
echo "📋 镜像信息:"
echo "📋 Image info:"
docker images "${IMAGE_NAME}"

echo ""
echo "🎉 构建完成！"
echo "🎉 Build completed!"
echo ""
echo "运行容器 | Run container:"
echo "docker run -d --name atlassian-proxy -p 8000:8000 -v \$(pwd)/data:/app/data ${FULL_IMAGE_NAME}"
echo ""
echo "或使用docker-compose | Or use docker-compose:"
echo "docker-compose up -d"
