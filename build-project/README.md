# build-project — Mooncake `mooncake_master` 工程构建

本目录承载 **Mooncake v0.3.10 `mooncake_master`** 的两段式工程构建任务。
所有文件与 Mooncake 主仓源码完全解耦，**不修改 Mooncake 主仓任何源码**。

---

## 目录结构

```
build-project/
├── README.md                                ← 本文件
├── lib/
│   └── common.sh                            ← 跨阶段唯一公共函数库（日志 / require_env / check_go_version / 路径派生 / init_build_image_params）
├── pre_mooncake/                            ← 阶段一：编译并打包二进制制品（含 .so 文件）
│   ├── manifest/
│   │   └── pre_mooncake.xml                 ← 工程任务源码拉取清单（主仓 + pybind11 + yalantinglibs + 6 个三方依赖）
│   ├── ci/
│   │   └── pre_mooncake_arm.yml             ← 工程任务定义（PRE/BUILD/POST），env: 段集中维护所有入参
│   ├── build.sh                             ← 阶段一入口（按序调用 scripts/1~5）
│   └── scripts/
│       ├── 1_preflight.sh                   ← 环境校验（yum 依赖安装 / GCC12 可用性 / go >= GO_MIN_VERSION）
│       ├── 2_build_deps.sh                  ← 6 个三方依赖按序源码编译并 install 至 /usr/local
│       ├── 3_build_mooncake.sh              ← pybind11 放置 + go mod replace + cmake + make mooncake_master + make install
│       ├── 4_collect_artifact.sh            ← ldd 收集运行时 .so + 强制覆盖 GCC12 libstdc++/libgcc_s + 补 libetcd_wrapper.so/libasio.so + 生成 MANIFEST.txt + 打 tar.gz
│       └── 5_push_artifact.sh               ← 推制品仓（mock 占位符）
└── build_mooncake/                          ← 阶段二：制 image + chart（由工程任务/DSPTool 调用并注入变量）
    ├── build.sh                             ← 阶段二入口（按序调用 scripts/1~4）
    ├── docker/
    │   ├── Dockerfile                       ← 镜像定义；WORKDIR /opt/mooncake；GCC12 ABI 收口 + ldconfig + ldd 完整性校验
    │   ├── entrypoint.sh                    ← 容器启动入口；诊断 + exec 信号转发；K8s 通过 args: 覆盖参数
    │   ├── sudoers_paas                     ← paas 用户 sudo 权限配置，由 Dockerfile 安装至 /etc/sudoers.d/
    │   └── .dockerignore                    ← docker build 上下文排除规则
    ├── lib/
    │   └── save_image_slim.sh               ← 基于基础镜像对应用镜像瘦身并保存 tar 包
    ├── chart/
    │   └── mooncake_store_server/           ← Helm Chart 源
    │       ├── Chart.yaml                   ← Chart 元信息（name/version/appVersion）
    │       ├── values.yaml                  ← 默认值（镜像/副本数/资源/端口/etcd 等）
    │       └── templates/
    │           ├── _helpers.tpl             ← 公共模板助手函数
    │           ├── statefulset.yaml         ← StatefulSet（HA 多副本 mooncake_master）
    │           ├── service.yaml             ← ClusterIP Service（RPC/metrics/http-meta 端口）
    │           ├── service-headless.yaml    ← Headless Service（StatefulSet Pod 稳定 DNS）
    │           └── service-account.yaml     ← ServiceAccount
    └── scripts/
        ├── 1_pull_artifact.sh               ← conan 拉取阶段一 tar.gz → 解压 → 组装 ${WORKSPACE}/build-context/
        ├── 2_build_image.sh                 ← docker build → save_image_slim 瘦身 → 7z 打包
        ├── 3_build_chart.sh                 ← helm package → 7z 打包
        └── 4_push_product.sh                ← 推 product repo（mock 占位符）
```

> 命名约定：脚本统一 `N_xxx.sh`（单位数字、单调递增），目录全部使用下划线
> （`pre_mooncake` / `build_mooncake` / `mooncake_store_server`）。
> 公共函数库位于顶层 `build-project/lib/common.sh`，两阶段所有脚本均通过
> `../../lib/common.sh` 相对路径引用，无需跨阶段穿目录。

---

## 构建机 WORKSPACE 目录结构

> 下列结构由 `common.sh` 路径派生约定 + 各脚本运行后共同形成；
> `$WORKSPACE` 由 CI 工程任务或本地 `export` 注入。

### 阶段一（pre_mooncake）构建机目录

```
$WORKSPACE/
├── mooncake_artifact/
│   └── src/                                 ← SRC_DIR（manifest 拉取根，路径由工程任务 xml 中 path= 决定）
│       ├── Mooncake/                        ← 主仓源码（tag v0.3.10）
│       │   ├── build/                       ← cmake in-source 构建目录（3_build_mooncake.sh 生成）
│       │   └── extern/pybind11/             ← pybind11 放置目标（3_build_mooncake.sh 拷入）
│       ├── pybind11/                        ← pybind11 v3.0.4 源码
│       ├── yalantinglibs/                   ← yalantinglibs 0.5.6 源码（预编译装入 /usr/local）
│       ├── godeps/                          ← go 内部私有依赖（cbb_adapt / KmsGoSdk / etcd/*）
│       │   ├── cbb_adapt/
│       │   ├── KmsGoSdk/
│       │   └── etcd/
│       │       ├── api/
│       │       ├── client/pkg/
│       │       └── client/v3/
│       └── deps/                            ← 6 个三方 C++ 依赖源码
│           ├── gflags/
│           ├── glog/
│           ├── jsoncpp/
│           ├── yaml-cpp/
│           ├── msgpack-c/
│           └── xxHash/
├── tmp/                                     ← TMP_DIR（打包临时目录）
│   └── mooncake/                            ← 制品收集根（4_collect_artifact.sh 生成）
│       ├── bin/
│       │   └── mooncake_master              ← 从 /usr/local/bin/ 拷入
│       ├── lib/
│       │   ├── libstdc++.so.6               ← GCC12 版本（强制覆盖系统老版）
│       │   ├── libgcc_s.so.1                ← GCC12 版本
│       │   ├── libetcd_wrapper.so           ← 单独补入（dlopen 加载，ldd 不可见）
│       │   ├── libasio.so                   ← 单独补入（自编译）
│       │   └── *.so                         ← ldd 收集的其余运行时依赖
│       └── MANIFEST.txt                     ← 构建元信息（git sha / 版本 / 时间 / 文件清单）
├── dist/                                    ← DIST_DIR（最终制品输出）
│   ├── mooncake-store-server_v0.3.10_EulerOS_Aarch64_<sha8>.tar.gz
│   └── .latest_artifact                     ← 记录最新制品文件名，供阶段二 conan 拉取
└── ( /usr/local/bin/mooncake_master )       ← make install 安装目标（系统路径，非 WORKSPACE 下）
```

### 阶段二（build_mooncake）构建机目录

```
$WORKSPACE/
├── tmp/                                     ← TMP_DIR
│   ├── artifact/                            ← conan 下载的制品暂存目录
│   │   └── mooncake/
│   │       └── mooncake-store-server_v0.3.10_EulerOS_Aarch64_<sha8>.tar.gz
│   └── extract/                             ← tar 解压临时目录
│       └── mooncake/
│           ├── bin/mooncake_master
│           ├── lib/*.so
│           └── MANIFEST.txt
├── build-context/                           ← docker build 上下文（1_pull_artifact.sh 组装）
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── sudoers_paas
│   ├── .dockerignore
│   ├── bin/
│   │   └── mooncake_master
│   └── lib/
│       └── *.so
└── dist/                                    ← DIST_DIR（最终产物输出）
    ├── V0.1_Images_EulerOS-Aarch64_Docker-MooncakeStoreServer-Any.7z   ← 镜像 7z
    └── V0.1_Chart_Any_Docker-MooncakeStoreServer-Any.7z                ← Chart 7z
```

---

## 容器内目录结构

> 由 `Dockerfile` 的 `COPY` + `RUN` 指令生成；运行用户为 `paas`。

```
/opt/mooncake/                               ← WORKDIR
├── bin/
│   ├── mooncake_master                      ← 主程序（chmod 550，owner paas:paas）
│   └── entrypoint.sh                        ← 容器入口（chmod 550）
├── lib/                                     ← 运行时 .so（chmod 550）
│   ├── libstdc++.so.6                       ← GCC12，已 cp 覆盖至 /usr/lib64/ 并 ldconfig
│   ├── libgcc_s.so.1                        ← GCC12，已 cp 覆盖至 /usr/lib64/ 并 ldconfig
│   ├── libetcd_wrapper.so
│   ├── libasio.so
│   └── *.so
├── logs/                                    ← 日志挂载目录（chmod 750）
└── certs/                                   ← 证书挂载目录（chmod 700，按 defaultMode: 256 挂载）

/etc/ld.so.conf.d/mooncake.conf              ← 写入 /opt/mooncake/lib，ldconfig 后生效
/etc/sudoers.d/sudoers_paas                  ← paas 用户 sudo 规则（chmod 440）

ENV LD_LIBRARY_PATH=/opt/mooncake/lib:$LD_LIBRARY_PATH
EXPOSE 50051                                 ← gRPC RPC 端口
EXPOSE 9001                                  ← Prometheus metrics 端口
EXPOSE 8888                                  ← HTTP metadata server 端口
ENTRYPOINT ["/opt/mooncake/bin/entrypoint.sh"]
CMD        ["/opt/mooncake/bin/mooncake_master"]
```

---

## 制品 / 镜像 / Chart 命名约定

| 类型 | 名称 |
|---|---|
| 阶段一 tar.gz | `mooncake-store-server_v0.3.10_EulerOS_Aarch64_<git-sha8>.tar.gz` |
| 镜像 7z | `V0.1_Images_EulerOS-Aarch64_Docker-MooncakeStoreServer-Any.7z` |
| Chart 7z | `V0.1_Chart_Any_Docker-MooncakeStoreServer-Any.7z` |
| Docker tag | `mooncake-store-server:v0.1`、`:v0.1-<git-sha8>`、`:latest` |
| K8s 服务名 | `Mooncake-Store-Server`（chart `name: mooncake_store_server`） |

---

## Mock 占位符（上线前替换）

| 占位符 | 含义 |
|---|---|
| `https://artifact.example.com/mooncake/<version>/<arch>/` | 阶段一制品仓上传/下载根路径 |
| `registry.example.com/base/euler2sp12arm:2.0.0.SPC13` | 基础镜像仓地址 |
| `https://product.example.com/mooncake/` | 产品（image + chart）仓上传根路径 |

替换方式：两阶段 `ci/*.yml` 顶部 `env:` 段集中维护，**不要散落到脚本里**。

---

## 关键依赖版本

| 组件 | 版本 | 来源 |
|---|---|---|
| Mooncake | v0.3.10 (tag) | manifest 主仓 |
| pybind11 | v3.0.4 (tag) | manifest 拉取，由 `3_build_mooncake.sh` 放置到 `Mooncake/extern/pybind11/` |
| yalantinglibs | 0.5.6 (tag) | manifest 拉取，预编译装 `/usr/local` |
| glog | v0.7.0 | 源码编译 → `/usr/local` |
| jsoncpp | 1.9.5 | 源码编译 → `/usr/local` |
| yaml-cpp | yaml-cpp-0.7.0 | 源码编译 → `/usr/local` |
| gflags | v2.2.2 | 源码编译 → `/usr/local` |
| xxhash | v0.8.3 | 源码编译 → `/usr/local` |
| msgpack-c | cpp-7.0.0 | 源码编译 → `/usr/local` |
| etcd-cpp-apiv3 | v0.15.4 | **EulerOS yum -devel 包**（非源码） |
| cpprestsdk | v2.10.18 | **EulerOS yum -devel 包**（非源码） |
| go | **安装** 1.26.1 / **校验** ≥ 1.23.7 | 用于编译 `libetcd_wrapper.so` |
| gcc | 12.x（`GCC_HOME_12_3`） | 强制 GCC12 ABI；`libstdc++.so.6` / `libgcc_s.so.1` 一并打包进镜像 |

---

## 一键本地穿刺

```bash
# 阶段一（在已有 gcc-12 / go >= 1.23.7 的 EulerOS aarch64 构建机上）
export WORKSPACE=/tmp/wks-pre
export GCC_HOME_12_3=/usr/local/gcc-12
export GO_MIN_VERSION=1.23.7
export MOONCAKE_VERSION=v0.3.10
export cmc_type=ARM
mkdir -p $WORKSPACE && cd $WORKSPACE
# 工程任务会按 manifest 把源码拉取到 $WORKSPACE/mooncake_artifact/src/，本地穿刺时手工放置
bash <repo>/build-project/pre_mooncake/build.sh

# 阶段二（在能访问制品仓及 Docker daemon 的构建机上）
export WORKSPACE=/tmp/wks-img
export MOONCAKE_VERSION=v0.3.10
export cmc_type=ARM
mkdir -p $WORKSPACE && cd $WORKSPACE
bash <repo>/build-project/build_mooncake/build.sh
```

---

## 外部入参 / 必须入参 / 关键参数总览

下列变量由 **工程任务 `ci/*.yml` 的 `env:` 段** 或 **本地穿刺时手工 `export`** 注入；
所有脚本启动时通过 `require_env` 强校验「必填」项，缺失即 `die`。
请优先在两份 `ci/*.yml` 中维护它们，**不要把变量值散落到脚本里**。

### 1. 全局 / 跨阶段共享

| 变量 | 必填 | 注入位置 | 默认/示例 | 说明 |
|---|:--:|---|---|---|
| `WORKSPACE` | ✅ | shell `export` / 工程任务环境 | `/tmp/wks-pre` | 所有派生路径的根；`common.sh` 在此之下自动派生 `SRC_DIR/BUILD_DIR/TMP_DIR/DIST_DIR` 并 `mkdir -p`。 |
| `SRC_DIR` | ⚪ | 自动派生 | `${WORKSPACE}/mooncake_artifact/src` | manifest 拉取根；外部已设置则不覆盖。 |
| `BUILD_DIR` | ⚪ | 自动派生 | `${WORKSPACE}/mooncake_artifact/build` | 保留路径，cmake 实际在 `${SRC_DIR}/Mooncake/build` 内构建。 |
| `TMP_DIR` | ⚪ | 自动派生 | `${WORKSPACE}/tmp` | 打包临时目录。 |
| `DIST_DIR` | ⚪ | 自动派生 | `${WORKSPACE}/dist` | 最终制品输出目录。 |
| `MOONCAKE_VERSION` | ✅ | 两阶段 `ci/*.yml` env | `v0.3.10` | 主仓 tag；同时进入制品/镜像命名。 |
| `cmc_type` | ✅ | 工程任务环境 | `ARM` / `X86` / `SUSE` | `common.sh::init_build_image_params` 据此推导 OS_TYPE / ARCH_STR / IMAGE_LABEL 等。 |

### 2. 阶段一 `pre_mooncake`

| 变量 | 必填 | 默认/示例 | 用在哪 / 作用 |
|---|:--:|---|---|
| `GCC_HOME_12_3` | ✅ | `/usr/local/gcc-12` | `1_preflight.sh` / `2_build_deps.sh` / `3_build_mooncake.sh` / `4_collect_artifact.sh` 全程锁定 GCC12 ABI；`${GCC_HOME_12_3}/bin/gcc` 必须可执行。 |
| `GO_MIN_VERSION` | ✅ | `1.23.7` | `1_preflight.sh` + `common.sh::check_go_version` 强制下限校验。 |
| `ARTIFACT_REPO_BASE` | ✅ | `https://artifact.example.com/mooncake` | `5_push_artifact.sh` 上传根路径（mock 占位符）。 |

### 3. 阶段二 `build_mooncake`

| 变量 | 必填 | 默认/示例 | 用在哪 / 作用 |
|---|:--:|---|---|
| `ENV_PIPELINE_TASKNAME` | ✅ | `mooncake_package_arm` | `1_pull_artifact.sh` 拼接 conan 配置路径。 |
| `ENV_SERVICE_NAME` | ✅ | `mooncake` | `1_pull_artifact.sh` 拼接 conan 配置路径。 |
| `BASE_IMAGE` | ✅ | `registry.example.com/base/euler2sp12arm:2.0.0.SPC13` | `2_build_image.sh` 传给 `docker build --build-arg BASE_IMAGE=`。 |
| `BUILD_PROFILE` | ✅ | `release`（`release`\|`debug`） | `2_build_image.sh` 传给 `docker build --build-arg`，决定调测标签。 |
| `IMAGE_NAME` | ✅ | `mooncake-store-server` | `2_build_image.sh` docker tag 前缀。 |
| `IMAGE_TAG` | ✅ | `v0.1` | `2_build_image.sh` docker tag 主版本�� |
| `CHART_VERSION` | ✅ | `v0.1` | `3_build_chart.sh`（`helm package --version --app-version`）+ `4_push_product.sh` 上传路径。 |
| `PRODUCT_REPO_BASE` | ✅ | `https://product.example.com/mooncake` | `4_push_product.sh` 产品仓根路径。 |
| `REPO_USER` / `REPO_TOKEN` | ⚪ | — | `5_push_artifact.sh` / `4_push_product.sh` 上传鉴权（mock 示例；上线前由制品仓客户端管理）。 |

> **校验时机**：每个脚本第一行非注释代码即 `set -euo pipefail`，紧跟 `source common.sh`，
> 然后 `require_env VAR…` 列出该脚本依赖的全部必填项。新增变量时请同步更新本表
> + 对应脚本的 `require_env` + `ci/*.yml` 的 `env:` 段，三处保持一致。
