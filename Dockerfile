FROM python:3.7-stretch as build

WORKDIR /build/rcon

RUN git clone https://github.com/zekroTJA/rconclient \
      --branch master --depth 1 .
RUN python3 -m pip install -r requirements.txt &&\
    python3 -m pip install pyinstaller
RUN pyinstaller rconclient/main.py --onefile


FROM openjdk:11.0.3-jdk-stretch as final

LABEL maintainer="zekro <contact@zekro.de>" \
      version="1.0.0" \
      description="Minecraft spigot dockerized autobuilding latest version on startup"

COPY --from=build /build/rcon/dist/main /usr/bin/rconcli
RUN chmod +x /usr/bin/rconcli

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

WORKDIR /var/mcserver

ADD ./scripts ./scripts
ADD ./bin/rcon /usr/bin/rcon

RUN dos2unix ./scripts/*.sh /usr/bin/rcon
RUN chmod +x ./scripts/*.sh /usr/bin/rcon

EXPOSE 25565 25575

CMD ./scripts/build.sh &&\
    ./scripts/run.sh
