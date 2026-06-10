# ============================================================
# mihomo (Clash Meta) Docker Image
# Multi-stage: build from upstream source -> minimal Alpine runtime
# ============================================================

FROM --platform=$BUILDPLATFORM golang:1.24-alpine AS builder

ARG TARGETOS
ARG TARGETARCH

RUN apk add --no-cache git

# Clone specific stable release
RUN git clone --depth 1 --branch v1.19.27 https://github.com/MetaCubeX/mihomo.git /src

WORKDIR /src

RUN CGO_ENABLED=0 \
    GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    go build -v -ldflags "-s -w" -o /mihomo ./cmd/mihomo

FROM alpine:3.21 AS runtime

LABEL maintainer="carl800-1"

RUN apk add --no-cache ca-certificates tzdata curl && rm -rf /var/cache/apk/*

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
