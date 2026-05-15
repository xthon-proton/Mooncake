#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2026-2026. All rights reserved.
# =============================================================================
# pre_mooncake/scripts/lib/common.sh
#
# 阶段一全部脚本（00_..40_*.sh）以及阶段二 build-mooncake-image/scripts/* 通过
#     source "$(dirname "$0")/lib/common.sh"
# 引入的公共函数库。包含：
#   * 日志：log_info / log_warn / log_error / die
#   * 环境校验：require_env  （多个变量名，任一未定义/为空则 die）
#   * Go 版本校验：check_go_version  （`go env GOVERSION` vs $GO_MIN_VERSION）
#   * 默认派生路径：SRC_DIR / BUILD_DIR / TMP_DIR / DIST_DIR （由 WORKSPACE 派生）
#
# 设计约定：
#   * 本文件被 source，不直接执行；不要在这里调用 `set -e` —— 留给上层脚本控制。
#   * 只读取、不修改调用方已设置的变量；只有未设置时才填充派生默认值。
#   * 所有函数对 `set -u` 友好（默认参数用 ${VAR:-...}）。
# =============================================================================

# ---- 防止重复 source -------------------------------------------------------
if [[ -n "${__MOONCAKE_COMMON_SH_LOADED:-}" ]]; then
    return 0
fi
__MOONCAKE_COMMON_SH_LOADED=1

# ---- 颜色（仅在 stderr 是 tty 时启用） ------------------------------------
if [[ -t 2 ]]; then
    __C_RESET=$'\033[0m'
    __C_INFO=$'\033[0;32m'   # green
    __C_WARN=$'\033[0;33m'   # yellow
    __C_ERR=$'\033[0;31m'    # red
else
    __C_RESET=""; __C_INFO=""; __C_WARN=""; __C_ERR=""
fi

# ---- 日志 ------------------------------------------------------------------
# 所有日志走 stderr，避免污染脚本 stdout（便于被 $(...) 捕获）。
_log() {
    local level="$1" color="$2"; shift 2
    local ts; ts="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
    printf '%s[%s] [%s] [%s]%s %s\n' \
        "$color" "$ts" "${SCRIPT_NAME:-mooncake}" "$level" "$__C_RESET" "$*" >&2
}
log_info()  { _log INFO  "$__C_INFO" "$@"; }
log_warn()  { _log WARN  "$__C_WARN" "$@"; }
log_error() { _log ERROR "$__C_ERR"  "$@"; }

# die <msg> —— 输出错误并以 1 退出
die() {
    log_error "$*"
    exit 1
}

# ---- require_env <VAR1> [<VAR2> ...] --------------------------------------
# 任一变量未定义或为空字符串 → die。配合 `set -u` 提供更友好的错误信息：
# `set -u` 触发的是 "unbound variable"；require_env 给出明确的"哪个变量缺失"。
require_env() {
    local missing=()
    local v
    for v in "$@"; do
        # 用间接展开 + :- 默认值，避免在 set -u 下因变量未定义而炸。
        if [[ -z "${!v:-}" ]]; then
            missing+=("$v")
        fi
    done
    if (( ${#missing[@]} > 0 )); then
        die "缺少必需环境变量：${missing[*]}"
    fi
}

# ---- check_go_version ------------------------------------------------------
# 校验 `go env GOVERSION`（形如 go1.26.1）>= $GO_MIN_VERSION（形如 1.23.7）。
# 用 sort -V 做 semver-ish 比较；不符合则 die。
check_go_version() {
    require_env GO_MIN_VERSION
    command -v go >/dev/null 2>&1 || die "go 未安装或不在 PATH 中"

    local raw current min
    raw="$(go env GOVERSION 2>/dev/null || true)"
    [[ -n "$raw" ]] || die "go env GOVERSION 输出为空"
    current="${raw#go}"          # 去掉前缀 "go"
    min="${GO_MIN_VERSION#go}"   # 容忍用户写成 go1.23.7

    # sort -V：取两者排序后的最小值；若最小值 == min，说明 current >= min。
    local lowest
    lowest="$(printf '%s\n%s\n' "$current" "$min" | sort -V | head -n1)"
    if [[ "$lowest" != "$min" ]]; then
        die "go 版本过低：当前 $current < 要求 >= $min"
    fi
    log_info "go 版本检查通过：当前 $current >= 要求 $min"
}

print_dirs() {
      log_info "=== 构建目录配置 ==="
      log_info "SRC_DIR:   ${SRC_DIR:-<未设置>}"
      log_info "BUILD_DIR: ${BUILD_DIR:-<未设置>}"
      log_info "TMP_DIR:   ${TMP_DIR:-<未设置>}"
      log_info "DIST_DIR:  ${DIST_DIR:-<未设置>}"
      log_info "==================="
}

# ---- 派生路径默认值 --------------------------------------------------------
# WORKSPACE 必须由调用方（CI env / 本地 export）提供；其余路径若未提供则按
# 约定派生，统一所有脚本的目录布局：
#     $WORKSPACE/
#       ├── src/        manifest 拉取根（pre_mooncake.xml 中 path="src/<name>"）
#       ├── build/      out-of-tree cmake 构建目录根
#       ├── tmp/        打包临时目录
#       └── dist/       最终制品输出目录
if [[ -n "${WORKSPACE:-}" ]]; then
    : "${SRC_DIR:=${WORKSPACE}/mooncake_artifact/src}"
    : "${BUILD_DIR:=${WORKSPACE}/mooncake_artifact/build}"
    : "${TMP_DIR:=${WORKSPACE}/tmp}"
    : "${DIST_DIR:=${WORKSPACE}/dist}"
    mkdir -p "$BUILD_DIR" "$TMP_DIR" "$DIST_DIR"
    export SRC_DIR BUILD_DIR TMP_DIR DIST_DIR
fi

print_dirs