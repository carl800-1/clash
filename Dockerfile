# ============================================================
# mihomo (Clash Meta) Docker Image
# Multi-stage: build from upstream source → minimal Alpine runtime
# Supports amd64 / arm64
# ============================================================

# ---- Stage 1: Build ----
FROM --platform=$BUILDPLATFORM golang:1.24-alpine AS builder

ARG TARGETOS
ARG TARGETARCH
ARG MIHOMO_VERSION=latest

# 设置 Go proxy（加速国内下载）
ENV GOPROXY=https://goproxy.cn,direct
ENV GONOSUMDB=sun.com/*

RUN apk add --no-cache git

# Clone mihomo source
RUN if [ "$MIHOMO_VERSION" = "latest" ]; then \
        git clone --depth 1 https://github.com/MetaCubeX/mihomo.git /src; \
    else \
        git clone --depth 1 --branch "$MIHOMO_VERSION" https://github.com/MetaCubeX/mihomo.git /src; \
    fi

WORKDIR /src

# Build
RUN CGO_ENABLED=0 \
    GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    go build -v -ldflags "\
        -s -w \
        -X 'github.com/metacubex/mihomo/constant.Version=$(git describe --tags HEAD 2>/dev/null || echo dev)' \
        -X 'github.com/metacubex/mihomo/constant.BuildTime=$(date -u +%Y-%m-%dT%H:%M:%SZ)' \
    " -o /mihomo ./cmd/mihomo

# ---- Stage 2: Runtime ----
FROM alpine:3.21 AS runtime

LABEL maintainer="carl800-1"
LABEL description="mihomo (Clash Meta) - A rule-based proxy in Go"

RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    curl \
    && rm -rf /var/cache/apk/*

# Non-root user
RUN addgroup -S clash && adduser -S clash -G clash

COPY --from=builder /mihomo /usr/bin/mihomo
RUN chmod +x /usr/bin/mihomo

RUN mkdir -p /root/.config/mihomo && chown -R clash:clash /root/.config/mihomo

ENV TZ=Asia/Shanghai

EXPOSE 53/udp 7890 7891 7892 9090

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -sf http://localhost:9090/version || exit 1

USER clash

ENTRYPOINT ["mihomo"]
CMD ["-d", "/root/.config/mihomo"]
