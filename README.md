# Atlassian AI Gateway Proxy

一个Go实现的OpenAI兼容API代理，用于转发请求到Atlassian AI Gateway (Rovo Dev)，具有凭证池管理、轮询重试和指数退避功能。

A Go implementation of an OpenAI-compatible API proxy that forwards requests to the Atlassian AI Gateway (Rovo Dev) with credential pooling, round-robin retries, and exponential back-off.

## 功能特点 | Features

- **OpenAI兼容的API端点** | **OpenAI-compatible API endpoints**:
  - `GET /v1/models` – 返回支持的模型列表 | returns supported model list
  - `POST /v1/chat/completions` – 支持流式和非流式请求 | supports streamed and non-streamed requests
  - `GET /health` – 健康检查端点 | health check endpoint

- **凭证池管理** | **Credential pool management** 
  - 如果请求失败（401、403或任何5xx错误），会在指数退避后尝试下一个凭证，退避从0.5秒开始，最多到16秒
  - If a request fails with 401, 403 or any 5xx, the next credential is tried after an exponential back-off that starts at 0.5s and doubles up to 16s

- **流式响应支持** | **Streaming support** 
  - 处理流式和非流式聊天完成请求
  - Handles both streaming and non-streaming chat completions

- **错误处理** | **Error handling** 
  - 适当的HTTP状态码和错误消息
  - Proper HTTP status codes and error messages

- **Web管理界面** | **Web Management Interface**
  - 凭证管理（添加、查看、删除）| Credential management (add, view, delete)
  - API令牌管理 | API token management
  - 管理员密码管理 | Admin password management

## 安装 | Installation

1. 确保已安装Go 1.24.1或更高版本 | Make sure you have Go 1.24.1 or later installed
2. 克隆此仓库 | Clone this repository
3. 安装依赖 | Install dependencies:
   ```bash
     go mod tidy
   ```
4. 构建应用程序 | Build the application:
   ```bash
     go build -o atlassian-proxy
   ```

## 配置 | Configuration

首次运行时，应用程序会自动生成一个随机的管理员密码。请在首次登录后立即修改此密码。

When first run, the application will automatically generate a random admin password. Please change this password immediately after first login.

## 运行 | Running

启动服务器 | Start the server:
```bash
  ./atlassian-proxy
```

或直接使用Go运行 | Or run directly with Go:
```bash
  go run .
```

服务器默认在8000端口启动。您可以通过设置`PORT`环境变量来更改端口 | The server will start on port 8000 by default. You can change the port by setting the `PORT` environment variable:
```bash
  PORT=3000 ./atlassian-proxy
```

## 使用方法 | Usage

服务器运行后，将提供一个OpenAI兼容的API，地址为`http://localhost:8000/v1`，以及一个Web管理界面，地址为`http://localhost:8000/admin/login`。

Once running, the server provides an OpenAI-compatible API at `http://localhost:8000/v1` and a web management interface at `http://localhost:8000/admin/login`.

### Web管理界面 | Web Management Interface

访问`http://localhost:8000/admin/login`登录管理界面。首次登录时，使用控制台输出的初始密码。

Visit `http://localhost:8000/admin/login` to access the management interface. Use the initial password output to the console for first login.

在管理界面中，您可以：
- 管理凭证（添加、查看、删除）
- 生成和查看API令牌
- 修改管理员密码
- 重置管理员密码

In the management interface, you can:
- Manage credentials (add, view, delete)
- Generate and view API tokens
- Change admin password
- Reset admin password

### API使用 | API Usage

#### 列出模型 | List Models
```bash
  curl http://localhost:8000/v1/models
```

#### 聊天完成（非流式）| Chat Completion (Non-streaming)
```bash
  curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "model": "anthropic:claude-3-5-sonnet-v2@20241022",
    "messages": [
      {"role": "user", "content": "Hello, how are you?"}
    ]
  }'
```

#### 聊天完成（流式）| Chat Completion (Streaming)
```bash
  curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "model": "anthropic:claude-3-5-sonnet-v2@20241022",
    "messages": [
      {"role": "user", "content": "Hello, how are you?"}
    ],
    "stream": true
  }'
```

## 支持的模型 | Supported Models

代理支持以下模型 | The proxy supports the following models:
- `anthropic:claude-3-5-sonnet-v2@20241022`
- `anthropic:claude-3-7-sonnet@20250219`
- `anthropic:claude-sonnet-4@20250514`
- `anthropic:claude-opus-4@20250514`
- `google:gemini-2.0-flash-001`
- `google:gemini-2.5-pro-preview-03-25`
- `google:gemini-2.5-flash-preview-04-17`
- `bedrock:anthropic.claude-3-5-sonnet-20241022-v2:0`
- `bedrock:anthropic.claude-3-7-sonnet-20250219-v1:0`
- `bedrock:anthropic.claude-sonnet-4-20250514-v1:0`
- `bedrock:anthropic.claude-opus-4-20250514-v1:0`

## 架构 | Architecture

应用程序由以下几个模块组成 | The application consists of several modules:

- `main.go` - 应用程序入口点和服务器设置 | Application entry point and server setup
- `config.go` - 配置和常量 | Configuration and constants
- `models.go` - OpenAI和Atlassian API的数据结构 | Data structures for OpenAI and Atlassian APIs
- `auth.go` - 认证头生成和密码管理 | Authentication header generation and password management
- `client.go` - 带有重试逻辑和流式支持的HTTP客户端 | HTTP client with retry logic and streaming support
- `handlers.go` - HTTP请求处理程序 | HTTP request handlers
- `transform.go` - OpenAI和Atlassian格式之间的数据转换 | Data transformation between OpenAI and Atlassian formats
- `db/db.go` - 数据库操作 | Database operations
- `auth/auth.go` - 认证和密码哈希 | Authentication and password hashing
- `embed.go` - 嵌入静态文件和模板 | Embedded static files and templates

## 开发 | Development

要启用调试模式以获取详细日志，请在`config.go`中设置`DebugMode = true`。

To enable debug mode for verbose logging, set `DebugMode = true` in `config.go`.

## 数据存储 | Data Storage

应用程序使用SQLite数据库（`.credentials.db`）存储凭证、API令牌和管理员密码。

The application uses an SQLite database (`.credentials.db`) to store credentials, API tokens, and admin passwords.

## Docker部署 | Docker Deployment

### 使用Docker构建和运行 | Build and Run with Docker

#### 本地构建Docker镜像 | Build Docker Image Locally
```bash
# 构建镜像
docker build -t atlassian-proxy .

# 运行容器
docker run -d \
  --name atlassian-proxy \
  -p 8000:8000 \
  -v $(pwd)/data:/app/data \
  atlassian-proxy
```

#### 使用GitHub Packages中的镜像 | Use Image from GitHub Packages
```bash
# 拉取最新镜像
docker pull ghcr.io/your-username/atlassian_docker:latest

# 运行容器
docker run -d \
  --name atlassian-proxy \
  -p 8000:8000 \
  -v $(pwd)/data:/app/data \
  ghcr.io/your-username/atlassian_docker:latest
```

#### Docker Compose部署 | Docker Compose Deployment
创建`docker-compose.yml`文件：
```yaml
version: '3.8'
services:
  atlassian-proxy:
    image: ghcr.io/your-username/atlassian_docker:latest
    ports:
      - "8000:8000"
    volumes:
      - ./data:/app/data
    environment:
      - GIN_MODE=release
      - PORT=8000
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

运行：
```bash
docker-compose up -d
```

### 环境变量 | Environment Variables

- `PORT`: 服务器端口（默认：8000）| Server port (default: 8000)
- `GIN_MODE`: Gin框架模式（release/debug）| Gin framework mode (release/debug)

### 数据持久化 | Data Persistence

应用程序使用SQLite数据库存储数据。为了保持数据持久化，请确保将`/app/data`目录挂载到主机：

The application uses SQLite database for data storage. To persist data, make sure to mount the `/app/data` directory to the host:

```bash
-v $(pwd)/data:/app/data
```

## CI/CD | Continuous Integration/Deployment

### GitHub Actions自动构建 | GitHub Actions Auto Build

项目配置了GitHub Actions工作流程，会在以下情况自动构建和发布Docker镜像：

The project is configured with GitHub Actions workflow that automatically builds and publishes Docker images when:

- 推送到`main`或`master`分支 | Push to `main` or `master` branch
- 创建新的版本标签（如`v1.0.0`）| Create new version tags (e.g., `v1.0.0`)
- 创建Pull Request | Create Pull Request

### 镜像标签策略 | Image Tagging Strategy

- `latest`: 最新的main/master分支构建 | Latest main/master branch build
- `v1.0.0`: 特定版本标签 | Specific version tags
- `main`: main分支的最新构建 | Latest build from main branch
- `pr-123`: Pull Request构建 | Pull Request builds

### 使用发布的镜像 | Using Published Images

镜像发布到GitHub Container Registry (ghcr.io)：

Images are published to GitHub Container Registry (ghcr.io):

```bash
# 拉取最新版本
docker pull ghcr.io/your-username/atlassian_docker:latest

# 拉取特定版本
docker pull ghcr.io/your-username/atlassian_docker:v1.0.0
```

**注意**: 请将`your-username`替换为您的GitHub用户名或组织名。

**Note**: Replace `your-username` with your GitHub username or organization name.

## 许可证 | License

本项目按原样提供，仅供教育和开发目的使用。

This project is provided as-is for educational and development purposes.
