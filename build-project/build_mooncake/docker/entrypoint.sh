#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2026-2026. All rights reserved.
# =============================================================================
# entrypoint.sh — 容器启动入口
#
# 为什么需要它：
#   1. 启动前可做一次 ldconfig + ldd 自检，把"运行时缺库"的问题在容器
#      启动瞬间就暴露到日志里，比"进程启动一会儿后段错误"友好太多。
#   2. 打印 build profile / lib 版本 / env，便于线上排障。
#   3. 用 `exec "$@"` 把信号正确转给主进程，K8s 优雅停机才能生效；
#      如果直接 ENTRYPOINT 主程序，shell 包装会吞 SIGTERM。
#   4. 后续如需注入配置文件渲染（envsubst < tmpl > conf）有落点，无须改镜像。
#
# 维护要点：
#   * 严格 set -euo pipefail，错误立刻退出；
#   * 不要在这里做"业务逻辑"；只做"诊断 + 转发"；
#   * exec 必须是最后一行。
# =============================================================================
set -euo pipefail

echo "[entrypoint] $(date -u +%FT%TZ) starting Mooncake-Store-Server"
echo "[entrypoint] uname   : $(uname -a)"
echo "[entrypoint] LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}"

function set_permissions() {
    shdo chown -Rh paas:paas /opt/mooncake/ 2>/dev/null
    chmod 700 /opt/mooncake/certs
    chmod 750 /opt/mooncake/logs
    # 修改日志文件权限 -> 640
#    local LOG_FILE="/opt/mooncake/logs/xxx.log"
#	if [ ! -f "$LOG_FILE" ]; then
#		touch "$LOG_FILE"
#	fi
#	chmod 640 "$LOG_FILE"
}

function cleanup_sudoers_d() {
	echo "cleanup_sudoers_d Cleaning up."
    sudo rm -f /etc/sudoers.d/sudoers_paas
}

cleanup_sudoers_d
# todo 日志文件
# 转发信号 + 启动主进程；"$@" 即 K8s args: 提供的参数
echo "[entrypoint] exec: $*"
exec "$@"