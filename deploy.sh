#!/bin/bash
# ============================================================
# JX AI 服务部署脚本
# 用法: sudo ./deploy.sh
# ============================================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   JX AI 评论回复服务 - 部署脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请使用 sudo 运行此脚本${NC}"
    echo "用法: sudo ./deploy.sh"
    exit 1
fi

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="jx_ai"
SERVICE_FILE="${SCRIPT_DIR}/jx_ai.service"

echo -e "${YELLOW}[1/6] 安装 Python 依赖...${NC}"
pip3 install aiomysql aiohttp || {
    echo -e "${RED}安装依赖失败，请检查 pip3 是否可用${NC}"
    exit 1
}
echo -e "${GREEN}✓ 依赖安装完成${NC}"
echo ""

echo -e "${YELLOW}[2/6] 创建日志目录...${NC}"
mkdir -p "${SCRIPT_DIR}/logs"
chown -R user:user "${SCRIPT_DIR}/logs"
echo -e "${GREEN}✓ 日志目录创建完成: ${SCRIPT_DIR}/logs${NC}"
echo ""

echo -e "${YELLOW}[3/6] 复制服务文件到 systemd...${NC}"
if [ ! -f "$SERVICE_FILE" ]; then
    echo -e "${RED}找不到服务文件: ${SERVICE_FILE}${NC}"
    exit 1
fi
cp "$SERVICE_FILE" /etc/systemd/system/
echo -e "${GREEN}✓ 服务文件已复制到 /etc/systemd/system/${NC}"
echo ""

echo -e "${YELLOW}[4/6] 重新加载 systemd 配置...${NC}"
systemctl daemon-reload
echo -e "${GREEN}✓ systemd 配置已重新加载${NC}"
echo ""

echo -e "${YELLOW}[5/6] 启用开机自启动...${NC}"
systemctl enable ${SERVICE_NAME}
echo -e "${GREEN}✓ 已启用开机自启动${NC}"
echo ""

echo -e "${YELLOW}[6/6] 启动服务...${NC}"
systemctl start ${SERVICE_NAME}
sleep 2

# 检查服务状态
if systemctl is-active --quiet ${SERVICE_NAME}; then
    echo -e "${GREEN}✓ 服务启动成功！${NC}"
else
    echo -e "${RED}✗ 服务启动失败，请检查日志${NC}"
    echo ""
    echo "查看日志命令:"
    echo "  journalctl -u ${SERVICE_NAME} -f"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   部署完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "常用命令:"
echo "  查看服务状态:  sudo systemctl status ${SERVICE_NAME}"
echo "  查看实时日志:  sudo journalctl -u ${SERVICE_NAME} -f"
echo "  停止服务:      sudo systemctl stop ${SERVICE_NAME}"
echo "  重启服务:      sudo systemctl restart ${SERVICE_NAME}"
echo "  禁用自启动:    sudo systemctl disable ${SERVICE_NAME}"
echo ""
echo "日志文件位置:"
echo "  输出日志: ${SCRIPT_DIR}/logs/output.log"
echo "  错误日志: ${SCRIPT_DIR}/logs/error.log"
echo ""
