#!/usr/bin/env bash
# =============================================================================
# entrypoint.sh — 容器启动入口
#
# 为什么需要它（你 [5] 里问到的点）：
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
echo "[entrypoint] profile : $(cat /opt/mooncake/.profile 2>/dev/null || echo unknown)"
echo "[entrypoint] uname   : $(uname -a)"
echo "[entrypoint] LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}"

# 1) 启动期依赖自检（与构建期同样的逻辑，防止运行时挂载覆盖了 lib/）
missing="$(ldd /opt/mooncake/mooncake_master 2>/dev/null | grep 'not found' || true)"
if [ -n "$missing" ]; then
    echo "[entrypoint][FATAL] missing shared libs:"
    echo "$missing" | sed 's/^/    /'
    exit 1
fi

# 2) 打印关键 .so 版本（仅前两条，避免噪声）
ldconfig -p | grep -E 'libstdc\+\+|libgcc_s' | head -n 2 || true

# 3) 转发信号 + 启动主进程；"$@" 即 K8s args: 提供的参数
echo "[entrypoint] exec: $*"
exec "$@"
