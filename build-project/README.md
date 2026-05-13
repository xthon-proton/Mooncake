# build-project — Mooncake `mooncake_master` 工程构建

本目录承载 **Mooncake v0.3.10 `mooncake_master`** 的两段式工程构建任务。
所有文件与 Mooncake 主仓源码完全解耦，**不修改 Mooncake 主仓任何源码**。

---

## 目录结构

```
build-project/
├── README.md                                ← 本文件
├── lib/
│   └── common.sh                            ← 公共函数库（两阶段共享：日志 / require_env / go 校验 / 默认路径派生）
├── pre_mooncake/                            ← 阶段一：编译并打包二进制制品
│   ├── manifest/
│   │   └── pre_mooncake.xml                 ← 工程任务的源码拉取清单
│   ├── ci/
│   │   └── pre_mooncake_arm.yml             ← 工程任务定义（PRE/BUILD/POST）
│   ├── build.sh                             ← 阶段入口（本地穿刺）
│   └── scripts/
│       ├── 1_preflight.sh                   ← 环境校验（gcc-12 / go 1.26.1 / yum）
│       ├── 2_build_deps.sh                  ← 6 个依赖按序编译并装入 /usr/local
│       ├── 3_build_mooncake.sh              ← cmake + make mooncake_master
│       ├── 4_collect_artifact.sh            ← collect_libs + 打 tar.gz
│       └── 5_push_artifact.sh               ← 推制品仓（mock）
└── build_mooncake/                          ← 阶段二：制 image + chart
    ├── manifest/
    │   └── build_mooncake.xml
    ├── ci/
    │   └── build_mooncake_arm.yml
    ├── build.sh
    ├── docker/
    │   ├── Dockerfile
    │   ├── entrypoint.sh
    │   └── .dockerignore
    ├── chart/
    │   └── mooncake_store_server/           ← helm chart 源
    │       ├── Chart.yaml
    │       ├── values.yaml
    │       └── templates/
    │           ├── _helpers.tpl
    │           ├── statefulset.yaml
    │           ├── service.yaml
    │           ├── service-headless.yaml
    │           └── service-account.yaml
    └── scripts/
        ├── 1_pull_artifact.sh               ← 拉阶段一制品并解压到 docker/build-context
        ├── 2_build_image.sh                 ← docker build → 7z 打包
        ├── 3_build_chart.sh                 ← helm package → 7z 打包
        └── 4_push_product.sh                ← 推 product repo（mock）
```

> 命名约定：脚本统一 `N_xxx.sh`（单位数字、单调递增），目录全部使用下划线
> （`pre_mooncake` / `build_mooncake` / `mooncake_store_server`）。
> 公共函数库挪到顶层 `build-project/lib/`，两阶段所有脚本均通过相同
> 的 `../../lib/common.sh` 相对路径引用，无需跨阶段穿目录。

---

## 制品 / 镜像 / chart 命名约定

| 类型 | 名称 |
|---|---|
| 阶段一 tar.gz | `mooncake-master_v0.3.10_euleros-aarch64_<git-sha8>.tar.gz` |
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

替换方式：阶段二 `ci/build_mooncake_arm.yml` 顶部 `env:` 段集中维护，**不要散落到脚本里**。

---

## 关键依赖版本（与澄清结果一致）

| 组件 | 版本 | 来源 |
|---|---|---|
| Mooncake | v0.3.10 (tag) | 主仓 |
| pybind11 | v0.3.4 (tag) | manifest 拉取，放置到 `Mooncake/extern/pybind11/` |
| yalantinglibs | v0.5.6 (tag) | manifest 拉取，预编译装 `/usr/local`（v0.3.10 未强制版本） |
| glog | v0.7.0 | 源码编译 |
| jsoncpp | 1.9.5 | 源码编译 |
| yaml-cpp | 0.7.0 | 源码编译 |
| gflags | v2.2.2 | 源码编译 |
| xxhash | v0.8.2 | 源码编译 |
| msgpack-c | c-6.0.0 | 源码编译 |
| etcd-cpp-apiv3 | v0.15.4 | **EulerOS yum -devel 包**（非源码） |
| cpprestsdk | v2.10.18 | **EulerOS yum -devel 包**（非源码） |
| go | **安装** 1.26.1 / **校验** ≥1.23.7 | 用于编译 `libetcd_wrapper.so` |
| gcc | 12.x | 强制 GCC12 ABI |

---

## 一键本地穿刺

```bash
# 阶段一（在已有 gcc-12 / go 1.26.1 的 EulerOS aarch64 主机上）
export WORKSPACE=/tmp/wks-pre
mkdir -p $WORKSPACE && cd $WORKSPACE
# 工程任务会按 manifest 把源码放到 $WORKSPACE/src/...，本地穿刺时手工放置
bash <repo>/build-project/pre_mooncake/build.sh

# 阶段二
export WORKSPACE=/tmp/wks-img
mkdir -p $WORKSPACE && cd $WORKSPACE
export ARTIFACT_URL=https://artifact.example.com/mooncake/v0.3.10/aarch64/mooncake-master_v0.3.10_euleros-aarch64_<sha>.tar.gz
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
| `SRC_DIR` | ⚪ | 自动派生 | `${WORKSPACE}/src` | manifest 拉取根；外部已设置则不覆盖。 |
| `BUILD_DIR` | ⚪ | 自动派生 | `${WORKSPACE}/build` | out-of-tree cmake 构建目录根。 |
| `TMP_DIR` | ⚪ | 自动派生 | `${WORKSPACE}/tmp` | 打包临时目录。 |
| `DIST_DIR` | ⚪ | 自动派生 | `${WORKSPACE}/dist` | 最终制品输出目录。 |
| `MOONCAKE_VERSION` | ✅ | 两阶段 `ci/*.yml` env | `v0.3.10` | 主仓 tag；同时进入制品/镜像命名。 |

### 2. 阶段一 `pre_mooncake`

| 变量 | 必填 | 默认/示例 | 用在哪 / 作用 |
|---|:--:|---|---|
| `GO_INSTALL_VERSION` | ✅ | `1.26.1` | `1_preflight.sh` 提示性目标版本（不一致仅 WARN）。 |
| `GO_MIN_VERSION` | ✅ | `1.23.7` | `1_preflight.sh` + `common.sh::check_go_version` 强制下限。 |
| `GCC_TOOLCHAIN_PREFIX` | ✅ | `/usr/local/gcc-12` | `1_preflight.sh` / `2_build_deps.sh` / `3_build_mooncake.sh` / `4_collect_artifact.sh` 锁定 GCC12 ABI。 |
| `ARTIFACT_REPO_BASE` | ✅ | `https://artifact.example.com/mooncake` | `5_push_artifact.sh` 上传根路径（mock 占位符）。 |

### 3. 阶段二 `build_mooncake`

| 变量 | 必填 | 默认/示例 | 用在哪 / 作用 |
|---|:--:|---|---|
| `ARTIFACT_REPO_BASE` | ✅ | `https://artifact.example.com/mooncake` | `1_pull_artifact.sh` 下载根路径。 |
| `ARTIFACT_FILE` | ⚪ | 由工程任务注入或读取本地 `dist/.latest_artifact` | `1_pull_artifact.sh` 决定下载哪个 tar.gz。 |
| `BASE_IMAGE` | ✅ | `registry.example.com/base/euler2sp12arm:2.0.0.SPC13` | `2_build_image.sh` 传给 `docker build --build-arg`。 |
| `BUILD_PROFILE` | ✅ | `release` (`release`\|`debug`) | `2_build_image.sh` 传给 `docker build --build-arg`，决定是否暴露调测端口标签。 |
| `IMAGE_NAME` | ✅ | `mooncake-store-server` | `2_build_image.sh` docker tag 前缀。 |
| `IMAGE_TAG` | ✅ | `v0.1` | `2_build_image.sh` docker tag 主版本。 |
| `CHART_VERSION` | ✅ | `v0.1` | `3_build_chart.sh` (`helm package --version --app-version`) + `4_push_product.sh` 上传路径。 |
| `PRODUCT_REPO_BASE` | ✅ | `https://product.example.com/mooncake` | `4_push_product.sh` 产品仓根路径。 |
| `REPO_USER` / `REPO_TOKEN` | ⚪ | — | `5_push_artifact.sh` / `4_push_product.sh` 上传鉴权（mock 示例命令；上线前由制品仓客户端管理）。 |

> **校验时机**：每个脚本第一行非注释代码即 `set -euo pipefail`，紧跟 `source common.sh`，
> 然后 `require_env VAR…` 列出该脚本依赖的全部必填项。新增变量时请同步更新本表
> + 对应脚本的 `require_env` + `ci/*.yml` 的 `env:` 段，三处保持一致。
