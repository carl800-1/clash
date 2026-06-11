#!/bin/bash
# mihomo + Metacubexd 一键部署脚本
# 适用于绿联 NAS 4800P (amd64)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== mihomo + Metacubexd Docker 部署 ===${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: 未安装 Docker${NC}"
    exit 1
fi

if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo -e "${RED}错误: 未安装 Docker Compose${NC}"
    exit 1
fi

echo -e "${GREEN}Docker 环境就绪${NC}"

mkdir -p mihomo/config

echo -e "${GREEN}正在启动服务...${NC}"
$COMPOSE_CMD up -d --build

echo -e "${GREEN}=== 部署完成 ===${NC}"
echo ""
echo -e "  Web UI:    http://localhost:8080"
echo -e "  HTTP 代理: http://localhost:7890"
echo -e "  SOCKS 代理: socks5://localhost:7891"
echo -e "  API 端口:   http://localhost:9090"
echo ""
echo -e "  常用命令:"
echo -e "    查看日志:   $COMPOSE_CMD logs -f"
echo -e "    重启服务:   $COMPOSE_CMD restart"
echo -e "    停止服务:   $COMPOSE_CMD down"
echo -e "    更新镜像:   $COMPOSE_CMD pull && $COMPOSE_CMD up -d"
