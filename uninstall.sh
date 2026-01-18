#!/bin/bash
# ============================================================
# JX AI 服务卸载脚本
# 用法: sudo ./uninstall.sh
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}   JX AI 评论回复服务 - 卸载脚本${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请使用 sudo 运行此脚本${NC}"
    exit 1
fi

SERVICE_NAME="jx_ai"

echo -e "${YELLOW}[1/3] 停止服务...${NC}"
systemctl stop ${SERVICE_NAME} 2>/dev/null || true
echo -e "${GREEN}✓ 服务已停止${NC}"

echo -e "${YELLOW}[2/3] 禁用开机自启...${NC}"
systemctl disable ${SERVICE_NAME} 2>/dev/null || true
echo -e "${GREEN}✓ 已禁用开机自启${NC}"

echo -e "${YELLOW}[3/3] 删除服务文件...${NC}"
rm -f /etc/systemd/system/${SERVICE_NAME}.service
systemctl daemon-reload
echo -e "${GREEN}✓ 服务文件已删除${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   卸载完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "注意: 日志文件和程序代码未删除，如需清理请手动删除"
