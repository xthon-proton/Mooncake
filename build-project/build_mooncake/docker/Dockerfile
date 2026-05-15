# =============================================================================
# Dockerfile — Mooncake-Store-Server (mooncake_master)
#
# build context 约定（由 1_pull_artifact.sh 准备）：
#   <context>/
#     ├── Dockerfile
#     ├── entrypoint.sh
#     ├── bin/mooncake_master
#     └── lib/*.so      ← 阶段一收集打包的运行时 .so
# 即必须先 cd 到该目录再执行 docker build
# 构建预期目录
# /opt/
#  |- bin/
#      |- entrypoint.sh
#      `- mooncake_master
#  |- lib/*.so
#  |- logs/
#  `- certs/
# =============================================================================

ARG BASE_IMAGE=libforlayer:1.0.0
# 通过image_tag替换
FROM ${BASE_IMAGE}

# release | debug：debug 额外 EXPOSE 调测端口
#ARG BUILD_PROFILE=release

LABEL org.opencontainers.image.title="Mooncake-Store-Server" \
      org.opencontainers.image.description="Mooncake master service" \
      org.opencontainers.image.version="v0.3.10"

WORKDIR /opt/mooncake

# ---------- 拷贝二进制 + entrypoint + 运行时 .so ----------
COPY bin/mooncake_master /opt/mooncake/bin/mooncake_master
COPY entrypoint.sh       /opt/mooncake/bin/entrypoint.sh
COPY sudoers_paas        /opt/mooncake/sudoers_paas
COPY lib/ /opt/mooncake/lib/

# certs目录供挂载证书使用，证书文件按defaultMode: 256挂载
# ---------- GCC12 ABI 收口：先覆盖系统旧版，再 ldconfig ----------
# 必须在 ldconfig 之前覆盖；否则 ldconfig 缓存里仍指向 OS 老版本 libstdc++。
RUN mkdir -p /opt/mooncake/logs/ && \
    mkdir -p /opt/mooncake/certs && \
    cp /opt/mooncake/lib/libstdc++.so.6 /usr/lib64/libstdc++.so.6 && \
    cp /opt/mooncake/lib/libgcc_s.so.1  /usr/lib64/libgcc_s.so.1  && \
    echo "/opt/mooncake/lib" > /etc/ld.so.conf.d/mooncake.conf && \
    ldconfig && \
    chmod 640 /etc/sudoers && \
    chmod 550 -R /opt/mooncake/bin && \
    chmod 550 -R /opt/mooncake/lib && \
    chmod 750 /opt/mooncake/logs && \
    chmod 700 /opt/mooncake/certs && \
    mv /opt/mooncake/sudoers_paas /etc/sudoers.d/ && \
    chmod 440 /etc/sudoers && \
    chmod 440 /etc/sudoers.d/sudoers_paas && \
    chown -R paas:paas /opt/mooncake

# 让 loader 能找到私有 .so
ENV LD_LIBRARY_PATH=/opt/mooncake/lib:$LD_LIBRARY_PATH

# 诊断：确认缓存中 libstdc++ 只剩一条
RUN ldconfig -p | grep libstdc++ || true

# 构建期依赖完整性校验：缺失任何 .so 直接构建失败（带明细输出）
RUN missing="$(ldd /opt/mooncake/bin/mooncake_master | grep 'not found' || true)"; \
    if [ -n "$missing" ]; then \
        echo "===== Missing shared libs ====="; \
        echo "$missing"; \
        exit 1; \
    fi

# ---------- 端口（仅元数据；不影响实际监听） ----------
# 主端口：rpc / metrics / http-meta —— release/debug 都暴露
EXPOSE 50051 9001 8888

# 供镜像瘦身使用
ARG BASE_IMAGE_LABEL="base_image_label"
LABEL from=["${BASE_IMAGE_LABEL}"]
USER paas

# ---------- 入口 ----------
# 用 entrypoint.sh 做启动前的诊断 + exec 信号转发；K8s 通过 args: 覆盖参数。
ENTRYPOINT ["/opt/mooncake/bin/entrypoint.sh"]
CMD ["/opt/mooncake/bin/mooncake_master"]