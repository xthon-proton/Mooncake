#!/usr/bin/env bash
# =============================================================================
# 10_build_deps.sh — 编译 7 个三方依赖到 /usr/local
#
# 顺序按"被依赖关系"排：
#     gflags → glog            （glog 依赖 gflags）
#     jsoncpp / yaml-cpp / xxhash / cpprestsdk         （独立）
#     etcd-cpp-apiv3           （依赖 cpprestsdk + protobuf + grpc）
#     yalantinglibs            （header-only-ish；安装到 /usr/local）
#
# 每个依赖：build-out-of-tree（${BUILD_DIR}/<name>）+ make install。
# =============================================================================
set -euo pipefail
SCRIPT_NAME="10_build_deps"
source "$(dirname "$0")/lib/common.sh"

require_env SRC_DIR BUILD_DIR GCC_TOOLCHAIN_PREFIX
export PATH="${GCC_TOOLCHAIN_PREFIX}/bin:$PATH"
export LD_LIBRARY_PATH="${GCC_TOOLCHAIN_PREFIX}/lib64:${LD_LIBRARY_PATH:-}"
export CC="${GCC_TOOLCHAIN_PREFIX}/bin/gcc"
export CXX="${GCC_TOOLCHAIN_PREFIX}/bin/g++"

JOBS="$(nproc)"
PREFIX=/usr/local

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
    cmake --build "$bld" -j "$JOBS"
    cmake --install "$bld"
}

# ---- 1. gflags ------------------------------------------------------------
cmake_build gflags deps/gflags \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_STATIC_LIBS=OFF \
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
    -DJSONCPP_WITH_TESTS=OFF \
    -DJSONCPP_WITH_POST_BUILD_UNITTEST=OFF

# ---- 4. yaml-cpp ----------------------------------------------------------
cmake_build yaml-cpp deps/yaml-cpp \
    -DYAML_BUILD_SHARED_LIBS=ON \
    -DYAML_CPP_BUILD_TESTS=OFF \
    -DYAML_CPP_BUILD_TOOLS=OFF

# ---- 5. xxhash ------------------------------------------------------------
# xxHash 仓 cmake 入口在 cmake_unofficial 子目录
cmake_build xxhash deps/xxhash/cmake_unofficial \
    -DBUILD_SHARED_LIBS=ON \
    -DXXHASH_BUILD_XXHSUM=OFF

# ---- 6. cpprestsdk --------------------------------------------------------
cmake_build cpprestsdk deps/cpprestsdk \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTS=OFF \
    -DBUILD_SAMPLES=OFF \
    -DCPPREST_EXCLUDE_WEBSOCKETS=ON \
    -DCPPREST_EXCLUDE_COMPRESSION=OFF

# ---- 7. etcd-cpp-apiv3 ----------------------------------------------------
ldconfig "${PREFIX}/lib" "${PREFIX}/lib64" || true
cmake_build etcd-cpp-apiv3 deps/etcd-cpp-apiv3 \
    -DBUILD_ETCD_CORE_ONLY=OFF \
    -DBUILD_ETCD_TESTS=OFF

# ---- 8. yalantinglibs（按 #1：v0.5.6） ------------------------------------
cmake_build yalantinglibs yalantinglibs \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_BENCHMARK=OFF \
    -DBUILD_UNIT_TESTS=OFF

ldconfig "${PREFIX}/lib" "${PREFIX}/lib64" || true
log_info "三方依赖全部编译并安装完成"
