FROM ubuntu:22.04

WORKDIR /work

ENV PATH=$PATH:/build/bin:/build/bin/busybox:/work/bin \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

COPY --from=zzci/init / /

ARG JUST_VERSION=1.47.1
ARG TARGETARCH

RUN apt-get -y update && env DEBIAN_FRONTEND="noninteractive" \
    apt-get -y install --no-install-recommends \
    apt-utils ca-certificates apt-transport-https uuid-runtime \
    psmisc curl file less iptables dnsutils gnupg \
    jq tree sudo locales tmux openssh-client unzip && \
    #
    # locale
    locale-gen en_US.UTF-8 && \
    #
    # default shell
    rm -rf /bin/sh && ln -s /bin/bash /bin/sh && \
    #
    # fix sudo error
    echo "Set disable_coredump false" >> /etc/sudo.conf && \
    #
    # install just
    JUST_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "x86_64") && \
    curl -fsSL "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-${JUST_ARCH}-unknown-linux-musl.tar.gz" \
    | tar -xzf - -C /usr/local/bin just && \
    chmod +x /usr/local/bin/just && \
    #
    # clean
    apt-get autoclean -y && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    #
    # build time
    date "+%Y-%m-%d %H:%M:%S" > /.build_time.log

ADD rootfs /

RUN chmod 0755 /root /build

CMD ["/start.sh"]
