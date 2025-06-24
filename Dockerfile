FROM ubuntu:22.04

WORKDIR /work

ENV PATH=$PATH:/build/bin:/build/bin/busybox:/work/bin

COPY --from=zzci/init / /

RUN apt-get -y update &&  env DEBIAN_FRONTEND="noninteractive" \
    #
    # some utils
    apt-get -y install --no-install-recommends \
    apt-utils ca-certificates apt-transport-https uuid-runtime \
    psmisc curl file less iptables dnsutils gnupg \
    jq tree sudo locales tmux openssh-client; \
    #
    # locale-gen
    locale-gen en_US.UTF-8; \
    #
    # setup timezone
    ln -sf /usr/share/zoneinfo/Asia/Singapore /etc/localtime; \
    echo 'Asia/Singapore' > /etc/timezone; \
    #
    # fix sudo error
    echo "Set disable_coredump false" >> /etc/sudo.conf; \
    #
    # clean
    apt-get autoclean -y && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/* ; \    
    #
    # build time
    date "+%Y-%m-%d %H:%M:%S" > /.build_time.log

ADD rootfs /

RUN chmod 0755 /root /build

CMD ["/start.sh"]
