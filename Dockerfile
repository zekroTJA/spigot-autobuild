ARG JDK_VERSION="17"
ARG PYTHON_VERSION_TAG="3.7-stretch"

FROM python:${PYTHON_VERSION_TAG} as build

WORKDIR /build/rcon

RUN git clone https://github.com/zekroTJA/rconclient \
      --branch master --depth 1 .
RUN python3 -m pip install -r requirements.txt &&\
    python3 -m pip install pyinstaller
RUN pyinstaller rconclient/main.py --onefile

FROM openjdk:${JDK_VERSION}-jdk-bullseye AS final

LABEL maintainer="zekro <contact@zekro.de>" \
      version="2.0.0" \
      description="Minecraft spigot dockerized autobuilding latest version on startup"

COPY --from=build /build/rcon/dist/main /usr/bin/rconcli
RUN chmod +x /usr/bin/rconcli

### VARIABLES ###################################

ENV MC_VERSION="latest" \
    XMS="1G" \
    XMX="2G" \
    JVM_PARAMS="" \
    BUILD_CACHING="true"

ENV PRE_START_BACKUP="true"
ENV POST_START_BACKUP="true"
ENV BACKUP_FILE_FORMAT="+%Y-%m-%d-%H-%M-%S"
ENV MAX_AGE_BACKUP_FILES="30d"

#################################################

RUN apt-get update -y &&\
    apt-get install -y \
      curl \
      git \
      dos2unix \
      jq \
      zip \ 
      rclone

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

CMD ./scripts/startup.sh
