ARG JDK_VERSION="17"
ARG RUST_VERSION_TAG="1-buster"
ARG GOLANG_VERSION_TAG="1.18-stretch"

# --- BUILD HEALTHCHECK TOOL STAGE -----------------------------------------------------------------

FROM golang:${GOLANG_VERSION_TAG} AS healthcheck-build
WORKDIR /build

RUN apt-get install git
RUN git clone https://github.com/evolvedpacks/healthcheck --branch master --depth 1 .
RUN go build -v -o healthcheck ./cmd/healthcheck/main.go

# --- BUILD RCON CLIENT ----------------------------------------------------------------------------

FROM rust:${RUST_VERSION_TAG} AS build
WORKDIR /build/rcon

RUN git clone https://github.com/zekroTJA/rconcli \
    --branch main --depth 1 .
RUN cargo build --release 

# --- FINAL IMAGE STAGE ----------------------------------------------------------------------------

FROM openjdk:${JDK_VERSION}-jdk-bullseye AS final

LABEL maintainer="zekro <contact@zekro.de>" \
    version="2.1.0" \
    description="Minecraft spigot dockerized autobuilding latest version on startup"

COPY --from=build /build/rcon/target/release/rconcli /usr/bin/rconcli
RUN chmod +x /usr/bin/rconcli

COPY --from=healthcheck-build /build/healthcheck /usr/bin/healthcheck
# 90 Retries * 10s -> 15 Minutes Startup Time Assumption
HEALTHCHECK --interval=10s --timeout=10s --retries=90 \
    CMD /usr/bin/healthcheck -addr localhost:25565 -validateResponse

ENV MC_VERSION="latest" \
    XMS="1G" \
    XMX="2G" \
    JVM_PARAMS="-XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseNUMA -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:+UseVectorCmov -XX:+PerfDisableSharedMem -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:ThreadPriorityPolicy=1 -XX:AllocatePrefetchStyle=3  -XX:+UseG1GC -XX:MaxGCPauseMillis=37 -XX:+PerfDisableSharedMem -XX:G1HeapRegionSize=16M -XX:G1NewSizePercent=23 -XX:G1ReservePercent=20 -XX:SurvivorRatio=32 -XX:G1MixedGCCountTarget=3 -XX:G1HeapWastePercent=20 -XX:InitiatingHeapOccupancyPercent=10 -XX:G1RSetUpdatingPauseTimePercent=0 -XX:MaxTenuringThreshold=1 -XX:G1SATBBufferEnqueueingThresholdPercent=30 -XX:G1ConcMarkStepDurationMillis=5.0 -XX:G1ConcRSHotCardLimit=16 -XX:G1ConcRefinementServiceIntervalMillis=150 -XX:GCTimeRatio=99 -XX:+UseLargePages -XX:LargePageSizeInBytes=2m" \
    BUILD_CACHING="true"

ENV PRE_START_BACKUP="true"
ENV POST_START_BACKUP="true"
ENV BACKUP_FILE_FORMAT="+%Y-%m-%d-%H-%M-%S"
ENV MAX_AGE_BACKUP_FILES="30d"
ENV BACKUP_TARGET="minecraft:/"
ENV NOTICE=""

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
