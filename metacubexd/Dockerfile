FROM docker.io/node:20-alpine AS builder

USER root
ENV HUSKY=0
WORKDIR /build

ARG METACUBEXD_VERSION=v1.251.3

# 从 GitHub Release 下载预编译包
ADD https://github.com/MetaCubeX/metacubexd/releases/download/${METACUBEXD_VERSION}/compressed-dist.tgz /build/compressed-dist.tgz

RUN tar -xzf compressed-dist.tgz && \
    mv .output /app/.output && \
    rm compressed-dist.tgz

# 运行时镜像
FROM docker.io/node:20-alpine

ENV PORT=80
EXPOSE 80

WORKDIR /app

COPY --from=builder /app/.output ./.output

# 入口脚本
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# 非 root 用户
RUN addgroup -S app && adduser -S app -G app
USER app

CMD ["/docker-entrypoint.sh"]
