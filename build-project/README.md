# build-project — Mooncake `mooncake_master` 工程构建

本目录承载 **Mooncake v0.3.10 `mooncake_master`** 的两段式工程构建任务。
所有文件与 Mooncake 主仓源码完全解耦，**不修改 Mooncake 主仓任何源码**。

---

## 目录结构

```
build-project/
├── README.md                                ← 本文件
├── pre-mooncake/                            ← 阶段一：编译并打包二进制制品
│   ├── manifest/
│   │   └── pre_mooncake.xml                 ← 工程任务的源码拉取清单
│   ├── ci/
│   │   └── pre_mooncake_arm.yml             ← 工程任务定义（PRE/BUILD/POST）
│   ├── build.sh                             ← 阶段入口
│   └── scripts/
│       ├── lib/common.sh                    ← 公共：日志 / 版本比较 / go 校验
│       ├── 00_preflight.sh                  ← 环境校验（gcc-12 / go 1.26.1 / yum）
│       ├── 10_build_deps.sh                 ← 7 个依赖按序编译并装入 /usr/local
│       ├── 20_build_mooncake.sh             ← cmake + make mooncake_master
│       ├── 30_collect_artifact.sh           ← collect_libs + 打 tar.gz
│       └── 40_push_artifact.sh              ← 推制品仓（mock）
└── build-mooncake-image/                    ← 阶段二：制 image + chart
    ├── manifest/
    │   └── build_mooncake_image.xml
    ├── ci/
    │   └── build_mooncake_image_arm.yml
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
        ├── 00_pull_artifact.sh              ← 拉阶段一制品并解压到 docker/build-context
        ├── 10_build_image.sh                ← docker build → 7z 打包
        ├── 20_build_chart.sh                ← helm package → 7z 打包
        └── 30_push_product.sh               ← 推 product repo（mock）
```

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

替换方式：阶段二 `ci/build_mooncake_image_arm.yml` 顶部 `env:` 段集中维护，**不要散落到脚本里**。

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
| etcd-cpp-apiv3 | v0.15.4 | 源码编译 |
| cpprestsdk | v2.10.18 | 源码编译 |
| go | **安装** 1.26.1 / **校验** ≥1.23.7 | 用于编译 `libetcd_wrapper.so` |
| gcc | 12.x | 强制 GCC12 ABI |

---

## 一键本地穿刺

```bash
# 阶段一（在已有 gcc-12 / go 1.26.1 的 EulerOS aarch64 主机上）
export WORKSPACE=/tmp/wks-pre
mkdir -p $WORKSPACE && cd $WORKSPACE
# 工程任务会按 manifest 把源码放到 $WORKSPACE/src/...，本地穿刺时手工放置
bash <repo>/build-project/pre-mooncake/build.sh

# 阶段二
export WORKSPACE=/tmp/wks-img
mkdir -p $WORKSPACE && cd $WORKSPACE
export ARTIFACT_URL=https://artifact.example.com/mooncake/v0.3.10/aarch64/mooncake-master_v0.3.10_euleros-aarch64_<sha>.tar.gz
bash <repo>/build-project/build-mooncake-image/build.sh
```
