# syntax=docker/dockerfile:1.7
FROM ubuntu:22.04

WORKDIR /work

ENV PATH=$PATH:/build/bin:/build/bin/busybox:/work/bin \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

COPY --from=zzci/init / /

ARG JUST_VERSION=1.47.1
ARG TARGETARCH

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-utils ca-certificates uuid-runtime \
        psmisc procps curl wget file less iptables iproute2 dnsutils gnupg \
        jq tree sudo locales tmux openssh-client unzip git && \
    #
    # locale
    locale-gen en_US.UTF-8 && \
    #
    # default shell
    ln -sf bash /bin/sh && \
    #
    # install just
    JUST_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "x86_64") && \
    curl -fsSL "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-${JUST_ARCH}-unknown-linux-musl.tar.gz" \
    | tar -xzf - -C /usr/local/bin just && \
    chmod +x /usr/local/bin/just && \
    #
    # build time
    date "+%Y-%m-%d %H:%M:%S" > /.build_time.log

COPY --chmod=0755 rootfs /

CMD ["/start.sh"]
