#!/bin/sh
set -e

CONFIG_DIR="/root/.config/mihomo"
CONFIG_FILE="$CONFIG_DIR/config.yaml"

# 如果挂载了外部卷，GeoIP 文件可能被覆盖，检查并恢复
if [ ! -f "$CONFIG_DIR/geoip.metadb" ]; then
    # 从镜像内置位置恢复（如果存在）
    if [ -f /usr/share/mihomo/geoip.metadb ]; then
        cp /usr/share/mihomo/geoip.metadb "$CONFIG_DIR/geoip.metadb"
        cp /usr/share/mihomo/geosite.dat "$CONFIG_DIR/geosite.dat"
    fi
fi

# 如果配置文件不存在，创建默认配置
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << 'YAMLEOF'
mixed-port: 7890
socks-port: 7891
allow-lan: true
bind-address: '*'
mode: rule
log-level: info
external-controller: '0.0.0.0:9090'
secret: ''
dns:
  enable: true
  listen: 0.0.0.0:53
  nameserver:
    - 223.5.5.5
    - 114.114.114.114
  fallback:
    - tls://8.8.8.8:853
  fallback-filter:
    geoip: true
    ipcidr:
      - 240.0.0.0/4
proxies: []
proxy-groups:
  - name: "节点选择"
    type: select
    proxies:
      - DIRECT
rules:
  - GEOIP,CN,DIRECT
  - MATCH,节点选择
YAMLEOF
fi

echo "[*] 启动 mihomo..."
mihomo -d "$CONFIG_DIR" &
MIHOMO_PID=$!

echo "[*] 等待 API 就绪..."
for i in $(seq 1 30); do
    if curl -sf http://127.0.0.1:9090/version > /dev/null 2>&1; then
        echo "[+] API 就绪"
        break
    fi
    sleep 1
done

echo "[*] 启动 Web UI 在端口 8080..."
python3 /app/webui/server.py &
WEBUI_PID=$!

echo "[+] mihomo PID: $MIHOMO_PID"
echo "[+] Web UI PID: $WEBUI_PID"
echo ""
echo "=== 服务已就绪 ==="
echo "  HTTP 代理:  0.0.0.0:7890"
echo "  SOCKS 代理: 0.0.0.0:7891"
echo "  Web UI:     http://0.0.0.0:8080"
echo "  API:        http://127.0.0.1:9090"
echo ""

wait $MIHOMO_PID
