# ============================================================
# mihomo (Clash Meta) Docker Image
# 多阶段构建：从上游源码编译 → 最小化运行镜像
# 支持 amd64 / arm64
# ============================================================

# ---- 阶段 1: 编译 ----
FROM --platform=$BUILDPLATFORM golang:1.24-alpine AS builder

ARG TARGETOS
ARG TARGETARCH
ARG MIHOMO_VERSION=latest

RUN apk add --no-cache git tzdata

# 克隆 mihomo 源码
RUN if [ "$MIHOMO_VERSION" = "latest" ]; then \
        git clone --depth 1 https://github.com/MetaCubeX/mihomo.git /src; \
    else \
        git clone --depth 1 --branch "$MIHOMO_VERSION" https://github.com/MetaCubeX/mihomo.git /src; \
    fi

WORKDIR /src

# 获取版本信息
RUN git describe --tags HEAD 2>/dev/null || git rev-parse --short HEAD > /dev/null

# 编译
RUN CGO_ENABLED=0 \
    GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    go build -v -ldflags "\
        -s -w \
        -X 'github.com/metacubex/mihomo/constant.Version=$(git describe --tags HEAD 2>/dev/null || echo dev)' \
        -X 'github.com/metacubex/mihomo/constant.BuildTime=$(date -u +%Y-%m-%dT%H:%M:%SZ)' \
    " -o /mihomo ./cmd/mihomo

# ---- 阶段 2: 运行镜像 ----
FROM alpine:3.21 AS runtime

LABEL maintainer="carl800-1"
LABEL description="mihomo (Clash Meta) - A rule-based proxy in Go"

# 安装运行时依赖
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    curl \
    && rm -rf /var/cache/apk/*

# 创建非 root 用户
RUN addgroup -S clash && adduser -S clash -G clash

# 从编译阶段复制二进制
COPY --from=builder /mihomo /usr/bin/mihomo
RUN chmod +x /usr/bin/mihomo

# 创建配置目录
RUN mkdir -p /root/.config/mihomo && chown -R clash:clash /root/.config/mihomo

# 时区
ENV TZ=Asia/Shanghai

# DNS 端口
EXPOSE 53/udp
# HTTP 代理端口
EXPOSE 7890
# SOCKS5 代理端口
EXPOSE 7891
# RESTful API 端口
EXPOSE 9090
# 混合代理端口
EXPOSE 7892
# TUN 模式不需要额外端口

# 健康检查
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -sf http://localhost:9090/version || exit 1

# 切换到非 root 用户
USER clash

ENTRYPOINT ["mihomo"]
CMD ["-d", "/root/.config/mihomo"]
