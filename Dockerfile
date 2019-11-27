FROM openjdk:11.0.3-jdk-stretch

LABEL maintainer="zekro <contact@zekro.de>"
LABEL version="1.0.0"
LABEL description="Minecraft spigot dockerized autobuilding latest version on startup"

### VARIABLES ###################################

ENV MC_VERSION="latest" \
    XMS="1G" \
    XMX="2G" \
    JVM_PARAMS="" \
    BUILD_CACHING="true"

#################################################

RUN apt-get update -y &&\
    apt-get install -y \
      curl \
      git \
      dos2unix \
      jq

RUN mkdir -p /var/mcserver &&\
    mkdir -p /etc/mcserver/worlds &&\
    mkdir -p /etc/mcserver/plugins &&\
    mkdir -p /etc/mcserver/config &&\
    mkdir -p /etc/mcserver/locals


WORKDIR /tmp/rcon-cli-install
RUN curl -Lo rcon-cli.tgz \
      https://github.com/itzg/rcon-cli/releases/download/1.4.7/rcon-cli_1.4.7_linux_amd64.tar.gz &&\
    tar -xzf rcon-cli.tgz &&\
    cp rcon-cli /usr/bin/rcon &&\
    chmod +x /usr/bin/rcon &&\
    rm -rf ./*


WORKDIR /var/mcserver

ADD ./scripts ./scripts

RUN dos2unix ./scripts/*.sh
RUN chmod +x ./scripts/*.sh

EXPOSE 25565 25575

CMD ./scripts/build.sh &&\
    ./scripts/run.sh
