# =============================================================================
# Dockerfile — Mooncake-Store-Server (mooncake_master)
#
# build context 约定（由 00_pull_artifact.sh 准备）：
#   <context>/
#     ├── Dockerfile
#     ├── entrypoint.sh
#     ├── bin/mooncake_master
#     └── lib/*.so      ← 阶段一收集打包的运行时 .so
# 即必须先 cd 到该目录再执行 docker build —— 这正是 [5] 里你疑问的点。
# =============================================================================

ARG BASE_IMAGE=euler2sp12arm:2.0.0.SPC13
FROM ${BASE_IMAGE}

# release | debug：debug 额外 EXPOSE 调测端口
ARG BUILD_PROFILE=release

LABEL org.opencontainers.image.title="Mooncake-Store-Server" \
      org.opencontainers.image.description="Mooncake master service (mooncake_master)" \
      org.opencontainers.image.source="https://github.com/kvcache-ai/Mooncake" \
      org.opencontainers.image.version="v0.3.10"

WORKDIR /opt/mooncake

# ---------- 拷贝二进制 + entrypoint ----------
COPY bin/mooncake_master /opt/mooncake/mooncake_master
COPY entrypoint.sh       /opt/mooncake/entrypoint.sh
RUN chmod +x /opt/mooncake/mooncake_master /opt/mooncake/entrypoint.sh

# ---------- 拷贝运行时 .so ----------
COPY lib/ /opt/mooncake/lib/

# ---------- GCC12 ABI 收口：先覆盖系统旧版，再 ldconfig ----------
# 必须在 ldconfig 之前覆盖；否则 ldconfig 缓存里仍指向 OS 老版本 libstdc++。
RUN cp /opt/mooncake/lib/libstdc++.so.6 /usr/lib64/libstdc++.so.6 && \
    cp /opt/mooncake/lib/libgcc_s.so.1  /usr/lib64/libgcc_s.so.1  && \
    echo "/opt/mooncake/lib" > /etc/ld.so.conf.d/mooncake.conf && \
    ldconfig

ENV LD_LIBRARY_PATH=/opt/mooncake/lib:$LD_LIBRARY_PATH

# 诊断：确认缓存中 libstdc++ 只剩一条
RUN ldconfig -p | grep libstdc++ || true

# 构建期依赖完整性校验：缺失任何 .so 直接构建失败（带明细输出）
RUN missing="$(ldd /opt/mooncake/mooncake_master | grep 'not found' || true)"; \
    if [ -n "$missing" ]; then \
        echo "===== Missing shared libs ====="; \
        echo "$missing"; \
        exit 1; \
    fi

RUN echo "build_profile=${BUILD_PROFILE}" > /opt/mooncake/.profile

# ---------- 端口（仅元数据；不影响实际监听） ----------
# 主端口：rpc / metrics / http-meta —— release/debug 都暴露
EXPOSE 50051 9001 8888

# 调测端口：50052 / 9002 / 8889
# 实现说明：Dockerfile 的 EXPOSE 指令是"声明式"的，纯元数据（供 docker
# inspect / docker run -P 使用），不能用 ARG/ENV 在指令级别条件化。
# 选择「都 EXPOSE，由 K8s/compose/run -p 决定是否真正映射」即可实现：
#   * release 镜像：构建 args BUILD_PROFILE=release，K8s chart 只在 Service
#     里映射 50051/9001/8888；
#   * debug 镜像：BUILD_PROFILE=debug，本地 `docker run -p 50052:50052 ...`
#     即可生效。
# 因此始终 EXPOSE 调测端口，而是否对外暴露由部署侧决定。
EXPOSE 50052 9002 8889
LABEL mooncake.debug.ports="50052,9002,8889" \
      mooncake.profile="${BUILD_PROFILE}"

# ---------- 入口 ----------
# 用 entrypoint.sh 做启动前的诊断 + exec 信号转发；K8s 通过 args: 覆盖参数。
ENTRYPOINT ["/opt/mooncake/entrypoint.sh"]
CMD ["/opt/mooncake/mooncake_master"]
