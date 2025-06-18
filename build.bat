@echo off
REM Atlassian AI Gateway Proxy 构建脚本 (Windows)
REM Build script for Atlassian AI Gateway Proxy (Windows)

echo 🚀 开始构建 Atlassian AI Gateway Proxy...
echo 🚀 Starting build for Atlassian AI Gateway Proxy...

REM 检查Docker是否安装
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker未安装，请先安装Docker
    echo ❌ Docker is not installed, please install Docker first
    pause
    exit /b 1
)

REM 获取版本信息
set VERSION=%1
if "%VERSION%"=="" set VERSION=latest
set IMAGE_NAME=atlassian-proxy
set FULL_IMAGE_NAME=%IMAGE_NAME%:%VERSION%

echo 📦 构建Docker镜像: %FULL_IMAGE_NAME%
echo 📦 Building Docker image: %FULL_IMAGE_NAME%

REM 构建Docker镜像
docker build -t "%FULL_IMAGE_NAME%" .
if %errorlevel% neq 0 (
    echo ❌ 镜像构建失败
    echo ❌ Image build failed
    pause
    exit /b 1
)

echo ✅ 镜像构建完成: %FULL_IMAGE_NAME%
echo ✅ Image build completed: %FULL_IMAGE_NAME%

REM 显示镜像信息
echo 📋 镜像信息:
echo 📋 Image info:
docker images %IMAGE_NAME%

echo.
echo 🎉 构建完成！
echo 🎉 Build completed!
echo.
echo 运行容器 ^| Run container:
echo docker run -d --name atlassian-proxy -p 8000:8000 -v "%cd%/data:/app/data" %FULL_IMAGE_NAME%
echo.
echo 或使用docker-compose ^| Or use docker-compose:
echo docker-compose up -d

pause
