FROM alpine:3.21

LABEL maintainer="carl800-1"

RUN apk add --no-cache ca-certificates tzdata curl && rm -rf /var/cache/apk/*

COPY mihomo /usr/bin/mihomo
RUN chmod +x /usr/bin/mihomo

RUN addgroup -S clash && adduser -S clash -G clash
RUN mkdir -p /root/.config/mihomo && chown -R clash:clash /root/.config/mihomo

ENV TZ=Asia/Shanghai

EXPOSE 53/udp 7890 7891 7892 9090

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -sf http://localhost:9090/version || exit 1

USER clash

ENTRYPOINT ["mihomo"]
CMD ["-d", "/root/.config/mihomo"]
