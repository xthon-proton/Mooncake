#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2026-2026. All rights reserved.
# =============================================================================
# 3_build_mooncake.sh — 编译 mooncake_master
#
# 步骤：
#   1) 把 manifest 拉下来的 pybind11 源码"放置"到 Mooncake/extern/pybind11/
#      —— 注意不要嵌套成 .../pybind11/pybind11/
#   2) cmake 配置（与 穿刺时的 完全一致）。
#   3) make mooncake_master + make install。
#   4) 校验产物 + ldd 缺失检查。
# =============================================================================
set -euo pipefail
SCRIPT_NAME="3_build_mooncake"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/common.sh"

require_env SRC_DIR BUILD_DIR GCC_HOME_12_3

export PATH="${GCC_HOME_12_3}/bin:$PATH"
export LD_LIBRARY_PATH="${GCC_HOME_12_3}/lib64:/usr/local/lib:/usr/local/lib64:${LD_LIBRARY_PATH:-}"
export CC="${GCC_HOME_12_3}/bin/gcc"
export CXX="${GCC_HOME_12_3}/bin/g++"
export GOPROXY=https://cmc.centralrepo.rnd.huawei.com/artifactory/go-central-repo/,https://cmc.centralrepo.rnd.huawei.com/artifactory/product_go/

SUDO="sudo"
$SUDO -v || die "需要 root 权限执行 make，请检查 sudo 配置"

MOONCAKE_SRC="${SRC_DIR}/Mooncake"
PYBIND_SRC="${SRC_DIR}/pybind11"
[[ -d "$MOONCAKE_SRC" ]] || die "Mooncake 源码不存在：$MOONCAKE_SRC"
[[ -d "$PYBIND_SRC"   ]] || die "pybind11 源码不存在：$PYBIND_SRC"

# ---- 1) 放置 pybind11 ------------------------------------------------------
PYBIND_DEST="${MOONCAKE_SRC}/extern/pybind11"
log_info "放置 pybind11 → ${PYBIND_DEST}"
# 关键：先彻底清空目标目录（哪怕 .git submodule 元数据残留），再 cp，
# 防止形成 extern/pybind11/pybind11/ 嵌套。
rm -rf "$PYBIND_DEST"
mkdir -p "$PYBIND_DEST"
# 用 . / 形式避免拷贝出 ".../pybind11/pybind11/"
cp -a "${PYBIND_SRC}/." "${PYBIND_DEST}/"
[[ -f "${PYBIND_DEST}/CMakeLists.txt" ]] \
    || die "pybind11 放置后 CMakeLists.txt 缺失；请检查 manifest 拉取 dest 是否正确（可能嵌套）"
log_info "pybind11 放置 OK：$(ls "$PYBIND_DEST" | head -n5 | tr '\n' ' ')..."

# ---- 2) cmake -------------------------------------------------------------
MK_BUILD="${MOONCAKE_SRC}/build"
log_info "清理旧构建目录：$MK_BUILD"
# todo 如果cmake使用sudo执行，则产物为root属主, rm时需要提权
rm -rf "$MK_BUILD"
mkdir -p "$MK_BUILD"
cd "$MK_BUILD"

# 严格按 穿刺 的 cmake 选项
# todo 还需要考虑 -DWITH_EP是否影响大EP场景下，master与mooncake_client的互通？
# 忽略部分警告
cmake .. \
    -DWITH_STORE=ON \
    -DSTORE_USE_ETCD=ON \
    -DWITH_TE=ON \
    -DUSE_HTTP=ON \
    -DUSE_TCP=ON \
    -DBUILD_UNIT_TESTS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DWITH_P2P_STORE=OFF \
    -DWITH_EP=OFF \
	-DCMAKE_CXX_FLAGS="-Wno-maybe-uninitialized -Wno-reorder" \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo

# ---- 3) make + install ----------------------------------------------------
# 构建镜像执行时 make -j 10 可能被终止, 将 Parallel jobs 设置为2，解决C++编译中cc1plus进程被终止问题
$SUDO env PATH="$PATH" GOPROXY="$GOPROXY" LD_LIBRARY_PATH="LD_LIBRARY_PATH" make mooncake_master -j2
# 涉及 go 的使用, 则需要保留环境变量, 否则会报 command not found
$SUDO env PATH="$PATH" GOPROXY="$GOPROXY" LD_LIBRARY_PATH="LD_LIBRARY_PATH" make install

# ---- 4) 校验 --------------------------------------------------------------
BIN=/usr/local/bin/mooncake_master
[[ -x "$BIN" ]] || die "$BIN 不存在或不可执行"
log_info "二进制 OK：$(ls -lh "$BIN")"

log_info "ldd 输出："
ldd "$BIN" || true

if ldd "$BIN" | grep -q "not found"; then
    log_error "存在缺失的动态库依赖："
    ldd "$BIN" | grep "not found" >&2
    die "依赖未满足，构建失败"
fi

# 自编译产物快照
ls -lh "${MK_BUILD}/mooncake-common/etcd/libetcd_wrapper.so" || die "libetcd_wrapper.so 缺失"
ls -lh "${MK_BUILD}/mooncake-asio/libasio.so"               || die "libasio.so 缺失"

log_info "mooncake_master 构建完成"
