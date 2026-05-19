#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2026-2026. All rights reserved.
# =============================================================================
# 4_collect_artifact.sh — 收集运行时 .so + 二进制并打 tar.gz
#
# 优化：
#   1. 路径全部基于 ${WORKSPACE}/tmp/mooncake/{bin,lib}，可重入；
#   2. 缺失检查升级：缺失时输出每条 missing 的具体行；
#   3. 显式拷贝 GCC12 的 libstdc++.so.6 / libgcc_s.so.1（即便 ldd 已带），
#      防止 ldd 报系统老版本路径而漏掉 GCC12 版本；
#   4. 单独补 dlopen 加载的 libetcd_wrapper.so；
#   5. 生成 MANIFEST.txt（git sha + 依赖版本 + 构建时间）一并打包。
# =============================================================================
set -euo pipefail
SCRIPT_NAME="4_collect_artifact"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/common.sh"

init_build_image_params

SUDO="sudo"
$SUDO -v || die "需要 root 权限执行采集.so文件, mooncake_master的操作，请检查 sudo 配置"

: "${MOONCAKE_VERSION:=v0.3.10}"

require_env WORKSPACE MOONCAKE_VERSION GCC_HOME_12_3 SRC_DIR

export LD_LIBRARY_PATH="${GCC_HOME_12_3}/lib64:/usr/local/lib:/usr/local/lib64:${LD_LIBRARY_PATH:-}"

PKG_ROOT="${TMP_DIR}/mooncake"
BIN_DIR="${PKG_ROOT}/bin"
LIB_DIR="${PKG_ROOT}/lib"
mkdir -p "$BIN_DIR" "$LIB_DIR"

BINARY=/usr/local/bin/mooncake_master
[[ -x "$BINARY" ]] || die "$BINARY 不存在"

# ---- 1) 拷贝二进制 --------------------------------------------------------
# make install 使用 sudo 执行, 所以 cp 也需要 sudo 执行
$SUDO cp -L "$BINARY" "$BIN_DIR/"
log_info "已拷贝二进制：$BIN_DIR/mooncake_master"

# ---- 2) ldd 收集（排除核心系统库 + 动态链接器）----------------------------
EXCLUDE_PATTERN='/lib[^/]*/lib(c|m|dl|rt|pthread|resolv|util|nss_[a-z]+)\.'
EXCLUDE_LINKER='/ld-linux|/ld-musl'

$SUDO env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ldd "$BINARY" \
    | awk '/=>/ && $3 ~ /^\// {print $3}' \
    | grep -Ev "${EXCLUDE_PATTERN}|${EXCLUDE_LINKER}" \
    | sort -u \
    | xargs -I{} $SUDO cp -L {} "$LIB_DIR/"
log_info "已收集 ldd 可见的运行时 .so"

# ---- 3) 强制覆盖 GCC12 的 libstdc++ / libgcc_s ----------------------------
# 即便 ldd 已带过来，也要"覆盖"为 GCC12 路径下的版本（避免 ldd 解析到 OS 老版）。
$SUDO cp -Lv "${GCC_HOME_12_3}/lib64/libstdc++.so.6" "$LIB_DIR/"
$SUDO cp -Lv "${GCC_HOME_12_3}/lib64/libgcc_s.so.1"  "$LIB_DIR/"

# ---- 4) 单独补 dlopen 加载的 libetcd_wrapper.so 与 自编译的 libasio.so ---------------------------
ETCD_WRAPPER=/usr/local/lib/libetcd_wrapper.so
[[ -f "$ETCD_WRAPPER" ]] || die "$ETCD_WRAPPER 不存在"
$SUDO cp -L "$ETCD_WRAPPER" "$LIB_DIR/"

LIBASIO=/usr/local/lib/libasio.so
[[ -f "$LIBASIO" ]] || die "$LIBASIO 不存在"
$SUDO cp -L "$LIBASIO" "$LIB_DIR/"

# ---- 5) 缺失检查（含明细） ------------------------------------------------
log_info "=== 收集清单 ==="
ls -lh "$LIB_DIR/"

log_info "=== 缺失检查（模拟 Runtime: LD_LIBRARY_PATH=$LIB_DIR/）==="
missing="$(LD_LIBRARY_PATH="$LIB_DIR" $SUDO env PATH="$PATH"  LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ldd "$BIN_DIR/mooncake_master" | grep "not found" || true)"
if [[ -n "$missing" ]]; then
    log_error "缺失以下动态库："
    printf '%s\n' "$missing" | sed 's/^/    /' >&2
    die "运行时依赖不完整"
fi
log_info "无缺失"

# ---- 6) MANIFEST.txt -------------------------------------------------------
MOONCAKE_SHA="$(git -C "${SRC_DIR}/Mooncake" rev-parse --short=8 HEAD 2>/dev/null || echo unknown)"
cat > "${PKG_ROOT}/MANIFEST.txt" <<EOF
mooncake_master 制品清单
========================
build_time     : $(date -u +'%Y-%m-%dT%H:%M:%SZ')
mooncake       : ${MOONCAKE_VERSION} (sha=${MOONCAKE_SHA})
gcc_toolchain  : $(${GCC_HOME_12_3}/bin/gcc --version | head -n1)
go_version     : $(go env GOVERSION 2>/dev/null || echo unknown)
arch           : $(uname -m)
os             : $(. /etc/os-release && echo "${PRETTY_NAME:-unknown}")
Files:
$(cd "$PKG_ROOT" && find . -type f | sort)
EOF
log_info "MANIFEST.txt 已生成"

# ---- 7) 打 tar.gz ---------------------------------------------------------
ARTIFACT="mooncake-store-server_${MOONCAKE_VERSION}_${OS_TYPE}_${ARCH_STR}_${MOONCAKE_SHA}.tar.gz"
tar -C "$TMP_DIR" -czf "${DIST_DIR}/${ARTIFACT}" mooncake/
log_info "制品已生成：${DIST_DIR}/${ARTIFACT}"
ls -lh "${DIST_DIR}/${ARTIFACT}"

# 把制品名写入文件
echo "${ARTIFACT}" > "${DIST_DIR}/.latest_artifact"