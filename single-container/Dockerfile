FROM docker.io/alpine:3.21

LABEL maintainer="carl800-1"
LABEL description="mihomo + Web UI for GreenLink NAS 4800P (amd64)"

ARG MIHOMO_VERSION=v1.19.27

RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    curl \
    gzip \
    python3 \
    && rm -rf /var/cache/apk/*

# 下载 mihomo 二进制
ADD https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VERSION}/mihomo-linux-amd64-compatible-${MIHOMO_VERSION}.gz /tmp/mihomo.gz
RUN gzip -d /tmp/mihomo.gz && \
    chmod +x /tmp/mihomo && \
    mv /tmp/mihomo /usr/local/bin/mihomo && \
    rm -f /tmp/mihomo.gz

# 预下载 GeoIP 和 GeoSite 数据库
RUN mkdir -p /root/.config/mihomo
ADD https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb /root/.config/mihomo/geoip.metadb
ADD https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat /root/.config/mihomo/geosite.dat

COPY webui /app/webui

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV TZ=Asia/Shanghai
ENV MIHOMO_CONFIG=/root/.config/mihomo/config.yaml

EXPOSE 53/udp 7890 7891 9090 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
