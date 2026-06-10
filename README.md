# mihomo (Clash Meta) Docker

基于 MetaCubeX/mihomo 源码构建的 Docker 镜像，支持多平台（amd64/arm64），通过 GitHub Actions 自动构建并推送到 Docker Hub。

## 快速开始

### 拉取镜像

```bash
docker pull docker.io/carl8001/clash:latest
```

### 最简运行

```bash
docker run -d \
  --name mihomo \
  -p 7890:7890 \
  -p 7891:7891 \
  -p 9090:9090 \
  -v ./config.yaml:/root/.config/mihomo/config.yaml:ro \
  carl8001/clash:latest
```

### docker-compose

```yaml
services:
  mihomo:
    image: carl8001/clash:latest
    container_name: mihomo
    restart: unless-stopped
    ports:
      - "7890:7890"   # HTTP 代理
      - "7891:7891"   # SOCKS5 代理
      - "9090:9090"   # RESTful API
    volumes:
      - ./config.yaml:/root/.config/mihomo/config.yaml:ro
```

## 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `TZ` | 时区 | `Asia/Shanghai` |

## 端口说明

| 端口 | 协议 | 说明 |
|------|------|------|
| 7890 | TCP | HTTP 代理 |
| 7891 | TCP | SOCKS5 代理 |
| 7892 | TCP | 混合代理 (HTTP+SOCKS5) |
| 9090 | TCP | RESTful API |
| 53 | UDP | DNS |

## 在 Kubernetes / 其他环境中使用

镜像支持 amd64 和 arm64 架构。

## 构建

```bash
docker build -t clash:local .
```

## License

GPL-3.0 (mihomo 上游项目许可证)
