FROM openjdk:11.0.3-jdk-stretch

LABEL maintainer="zekro <contact@zekro.de>"
LABEL version="1.0.0"
LABEL description="Minecraft spigot dockerized autobuilding latest version on startup"

### VARIABLES ###################################

ENV MC_VERSION="latest"
ENV XMS="1G"
ENV XMX="2G"
ENV JVM_PARAMS=""

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

WORKDIR /var/mcserver

ADD ./scripts ./scripts

RUN dos2unix ./scripts/*.sh
RUN chmod +x ./scripts/*.sh

EXPOSE 25565 25575

CMD ./scripts/build.sh &&\
    ./scripts/run.sh