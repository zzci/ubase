FROM ubuntu:20.04

WORKDIR /work

ENV PATH=$PATH:/build/bin:/work/bin

RUN apt-get -y update && env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends apt-utils ca-certificates && \
    sed -i 's@http://archive.ubuntu.com/ubuntu/@mirror://mirrors.ubuntu.com/mirrors.txt@'  /etc/apt/sources.list && \
    apt-get -y update && env DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
    vim-tiny iproute2 net-tools iputils-ping uuid-runtime \
    curl wget jq tree zsh git unzip xz-utils zip sudo locales gnupg openssh-server openssh-client && \
    # locale-gen
    locale-gen en_US.UTF-8  && \
    # setup timezone
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone && \
    # fix sudo error
    echo "Set disable_coredump false" >> /etc/sudo.conf && \
    # clean
    apt-get autoclean -y && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && \
    #
    # build time
    date +%s > /build_time.log

COPY --from=zzci/init / /
ADD rootfs /

CMD ["/start.sh"]
