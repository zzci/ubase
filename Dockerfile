FROM ubuntu:20.04

WORKDIR /work

ENV PATH=$PATH:/build/bin:/work/bin

COPY --from=zzci/init / /

ADD rootfs /

RUN apt-get -y update &&  env DEBIAN_FRONTEND="noninteractive" \
    #
    # change apt source
    #sed -i 's@http://archive.ubuntu.com/ubuntu/@mirror://mirrors.ubuntu.com/mirrors.txt@'  /etc/apt/sources.list && \
    apt-get -y install --no-install-recommends \
    apt-utils ca-certificates vim-tiny iproute2 net-tools uuid-runtime \
    inetutils-telnet inetutils-ftp inetutils-ping curl wget whois netbase \
    jq tree zsh git unzip xz-utils zip sudo locales tmux gnupg openssh-server openssh-client && \
    #
    # locale-gen
    locale-gen en_US.UTF-8  && \
    #
    # setup timezone
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone && \
    #
    # fix sudo error
    echo "Set disable_coredump false" >> /etc/sudo.conf && \
    #
    # clean
    apt-get autoclean -y && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/* && \    
    #
    # fix dir permissions
    chmod -R 0755 /root /build && \
    #
    # build time
    date "+%Y-%m-%d %H:%M:%S" > /.build_time.log

CMD ["/start.sh"]
