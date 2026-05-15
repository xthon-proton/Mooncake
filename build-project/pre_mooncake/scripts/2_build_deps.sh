#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2026-2026. All rights reserved.
# =============================================================================
# 2_build_deps.sh — 编译 6 个三方依赖到 /usr/local
#
# 顺序按"被依赖关系"排：
#     gflags → glog                                 （glog 依赖 gflags）
#     jsoncpp / yaml-cpp / xxhash / msgpack-c       （独立）
#     yalantinglibs                                  （header-only-ish；安装到 /usr/local）
#
# 每个依赖：build-out-of-tree（${BUILD_DIR}/<name>）+ make install。
# =============================================================================
set -euo pipefail
SCRIPT_NAME="2_build_deps"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/common.sh"

require_env SRC_DIR BUILD_DIR GCC_HOME_12_3
# 1_preflight.sh 中已声明
export PATH="${GCC_HOME_12_3}/bin:$PATH"
export LD_LIBRARY_PATH="${GCC_HOME_12_3}/lib64:/usr/local/lib:/usr/local/lib64:${LD_LIBRARY_PATH:-}"
export CC="${GCC_HOME_12_3}/bin/gcc"
export CXX="${GCC_HOME_12_3}/bin/g++"

JOBS="$(nproc)"
PREFIX=/usr/local

SUDO="sudo"
$SUDO -v || die "需要 root 权限执行 make，请检查 sudo 配置"

# ---- 通用 cmake 构建函数 ---------------------------------------------------
# 用法：cmake_build <name> <src_subdir_under_SRC_DIR> [extra cmake args...]
cmake_build() {
    local name="$1" sub="$2"; shift 2
    local src="${SRC_DIR}/${sub}"
    local bld="${BUILD_DIR}/${name}"
    [[ -d "$src" ]] || die "源码不存在：$src"
    log_info "==== 构建 ${name} (src=$src) ===="
    rm -rf "$bld" && mkdir -p "$bld"
    ( cd "$bld" && cmake "$src" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        "$@" )
    # 构建镜像执行时 make -j 10 可能被终止, 将 Parallel jobs 设置为2，解决C++编译中cc1plus进程被终止问题
    $SUDO env PATH="$PATH" cmake --build "$bld" -j 2
    $SUDO env PATH="$PATH" cmake --install "$bld"
}

# ---- 1. gflags ------------------------------------------------------------
cmake_build gflags deps/gflags \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_STATIC_LIBS=ON \
    -DINSTALL_HEADERS=ON \
    -DBUILD_TESTING=OFF

# ---- 2. glog v0.7.0 -------------------------------------------------------
cmake_build glog deps/glog \
    -DBUILD_SHARED_LIBS=ON \
    -DWITH_GFLAGS=ON \
    -DWITH_GTEST=OFF \
    -DBUILD_TESTING=OFF

# ---- 3. jsoncpp -----------------------------------------------------------
cmake_build jsoncpp deps/jsoncpp \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_STATIC_LIBS=ON \
    -DJSONCPP_WITH_TESTS=OFF \
    -DJSONCPP_WITH_POST_BUILD_UNITTEST=OFF

# ---- 4. yaml-cpp ----------------------------------------------------------
cmake_build yaml-cpp deps/yaml-cpp \
    -DYAML_BUILD_SHARED_LIBS=ON \
    -DYAML_CPP_BUILD_TESTS=OFF \
    -DYAML_CPP_BUILD_TOOLS=OFF

# ---- 5. xxhash ------------------------------------------------------------
# xxHash 仓 cmake 入口在 cmake_unofficial 子目录
cmake_build xxhash deps/xxHash/cmake_unofficial \
    -DBUILD_SHARED_LIBS=ON \
    -DXXHASH_BUILD_XXHSUM=OFF

# ---- 6. msgpack-c ---------------------------------------------------------
# manifest 拉取的 msgpack-c 仓库（C 库 + C++ 头）。EulerOS 基础镜像未提供，
# 必须源码编译。BUILD_CPP=ON 同时安装 C++ 头文件供 mooncake_master 使用。
cmake_build msgpack-c deps/msgpack-c \
    -DBUILD_SHARED_LIBS=ON \
    -DMSGPACK_BUILD_TESTS=OFF \
    -DMSGPACK_BUILD_EXAMPLES=OFF

# ---- 7. yalantinglibs（按 #1：v0.5.6） ------------------------------------
# 后续升级 -> v0.6.1，需要增加构建参数：-DYLT_ENABLE_SSL=ON
cmake_build yalantinglibs yalantinglibs \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_BENCHMARK=OFF \
    -DBUILD_UNIT_TESTS=OFF

$SUDO ldconfig "${PREFIX}/lib" "${PREFIX}/lib64" || true
log_info "三方依赖全部编译并安装完成"
