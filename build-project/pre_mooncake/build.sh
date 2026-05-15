#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2026-2026. All rights reserved.
# =============================================================================
# 按 step 顺序逐个调用 scripts/*.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export STAGE_DIR="$SCRIPT_DIR"

# 格式化时间：毫秒转人类可读
format_duration() {
    local ms=$1
    if [ "$ms" -lt 1000 ]; then
        echo "${ms}ms"
    else
        local sec=$((ms / 1000))
        local rem_ms=$((ms % 1000))
        local min=$((sec / 60))
        local rem_sec=$((sec % 60))

        if [ "$min" -gt 0 ]; then
            printf "%dmin %dsec %dms\n" "$min" "$rem_sec" "$rem_ms"
        else
            printf "%dsec %dms\n" "$rem_sec" "$rem_ms"
        fi
    fi
}

# 增强型执行函数
# 使用方式: run_task "描述" 命令 参数1 参数2...
run_task() {
    local desc="$1"
    shift # 移除第一个参数，剩余部分为实际执行的命令

    echo "[START] $desc"

    # 获取纳秒级时间戳并转换为毫秒 (兼容性处理)
    # macOS 默认 date 不支持 %N，若在 Mac 上运行需安装 coreutils (gnudate)
    local start_ns=$(date +%s%N)

    # 直接执行命令数组，避免 eval 风险
    "$@"
    local exit_code=$?

    local end_ns=$(date +%s%N)

    # 计算耗时 (ms)
    # 处理部分系统不支持 %N 导致结果非数字的情况
    local duration_ms=0
    if [[ "$start_ns" =~ ^[0-9]+$ ]] && [[ "$end_ns" =~ ^[0-9]+$ ]]; then
        duration_ms=$(( (end_ns - start_ns) / 1000000 ))
    fi

    local time_str=$(format_duration $duration_ms)

    if [ $exit_code -eq 0 ]; then
        printf "[DONE] [%-12s] Success: %s\n" "$time_str" "$desc"
    else
        printf "[FAIL] [%-12s] Error(Code:%d): %s\n" "$time_str" "$exit_code" "$desc"
    fi
    echo "------------------------------------------------"
}

echo "=== 开始制品构建流程 ==="

# 1. 预检
run_task "环境预检 (Preflight)" bash "$SCRIPT_DIR/scripts/1_preflight.sh"

# 2. 构建依赖
run_task "构建依赖 (Build Deps)" bash "$SCRIPT_DIR/scripts/2_build_deps.sh"

# 3. 核心构建
run_task "构建 mooncake_master" bash "$SCRIPT_DIR/scripts/3_build_mooncake.sh"

# 4. 产物收集
run_task "收集产物与打包 (Collect Artifact)" bash "$SCRIPT_DIR/scripts/4_collect_artifact.sh"

echo "=== 制品构建结束 ==="

# todo test
image_build_script_path="$(cd "$STAGE_DIR"/../build_mooncake && pwd)"
run_task "=== 执行镜像构建流程 ===" bash "$image_build_script_path"/build.sh