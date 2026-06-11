# mihomo + Metacubexd Docker 方案

适用于 **绿联 NAS 4800P** (Intel N5095, amd64) 的代理 Docker 部署方案。

## 架构

```
┌──────────────────────────────────────────┐
│  Docker (docker-compose)                 │
│                                          │
│  ┌─────────────┐    ┌─────────────────┐  │
│  │   mihomo    │    │  metacubexd     │  │
│  │  代理核心    │◄───│  Web UI 面板    │  │
│  │             │    │                 │  │
│  │ :7890 HTTP  │    │  :8080 Web界面  │  │
│  │ :7891 SOCKS │    │                 │  │
│  │ :9090 API   │    │                 │  │
│  └─────────────┘    └─────────────────┘  │
│         │                                │
│    config.yaml (挂载卷)                   │
│    ./mihomo/config/                      │
└──────────────────────────────────────────┘
```

## 快速部署

### 方式一：一键脚本（推荐）

```bash
git clone <仓库地址>
cd docker-clash
bash deploy.sh
```

### 方式二：手动部署

```bash
# 1. 编辑配置
vim mihomo/config/config.yaml

# 2. 启动服务
docker compose up -d --build

# 3. 查看日志
docker compose logs -f
```

## 端口说明

| 端口 | 服务 | 说明 |
|------|------|------|
| 8080 | metacubexd | Web UI 面板 |
| 7890 | mihomo | HTTP 代理 |
| 7891 | mihomo | SOCKS5 代理 |
| 9090 | mihomo | API (内部使用) |

## 目录结构

```
docker-clash/
├── docker-compose.yml          # 编排文件
├── deploy.sh                   # 一键部署脚本
├── README.md                   # 本文件
├── .dockerignore
├── .github/
│   └── workflows/
│       └── docker.yml          # GitHub Actions 自动构建
├── mihomo/
│   └── config/
│       └── config.yaml         # 代理配置（需自行编辑）
└── metacubexd/
    ├── Dockerfile              # 定制构建
    └── docker-entrypoint.sh    # 入口脚本
```

## 常用命令

```bash
# 启动
docker compose up -d

# 停止
docker compose down

# 重启
docker compose restart

# 查看日志
docker compose logs -f

# 更新镜像
docker compose pull && docker compose up -d

# 重建（配置更改后）
docker compose up -d --build
```

## 配置说明

编辑 `mihomo/config/config.yaml`：
- 添加你的代理节点
- 配置代理组
- 设置规则

配置兼容 Clash / ClashX / mihomo 格式。

## 与 ClashX 协同

Mac 上继续使用 ClashX，NAS 上运行 mihomo + Metacubexd：
- 两者使用同一份 config.yaml 格式
- 通过 Web UI 在 NAS 上管理代理
- 各自独立运行，互不干扰

## GitHub Actions

推送代码到 GitHub 后自动：
1. 构建 linux/amd64 Docker 镜像
2. 推送到 ghcr.io
3. 支持 tag 版本管理

## 系统要求

- Docker 20.10+
- Docker Compose v2
- Linux amd64 (x86_64)
- 至少 256MB 可用内存
