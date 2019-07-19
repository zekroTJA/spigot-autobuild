# Minecraft Spigot Dockerized - [AUTOBUILD VERSION]  🐳 💎

<a href="https://hub.docker.com/r/zekro/spigot-autobuild"><img alt="Docker Cloud Automated build" height="30" src="https://img.shields.io/docker/cloud/automated/zekro/spigot-autobuild.svg?color=cyan&logo=docker&logoColor=cyan&style=for-the-badge"></a>&nbsp;
<img height="30" src="https://forthebadge.com/images/badges/built-with-grammas-recipe.svg" />

## How Does It Work?

In contrast to [spigot-dockerized](https://github.com/zekroTJA/spigot-dockerized), where the pre-built spigot binary is already compiled on image built, this image downloads the latest BuildToos from spigot's Jenkins server and build the latest version of spigot directly on startup. Because building the `spigot.jar` can take up to several minutes *(depending on system resources ofc)*, each start of the server may take significantly longer than a normal dry start.

## How To Use

You can pull the image from [dockerhub](https://hub.docker.com/r/zekro/spigot-autobuild) or [build it yourself](#build-it-yourself).

```
$ docker pull zekro/spigot-autobuild:latest
```

Then, run the image mounting below container directories to your host system for persistent data, bind the ports and set preferences with environment variables: 

```
$ docker run \
    -p 25565:25565 -p 25575:25575 \
    -v /home/mc/config:/etc/mcserver/config \
    -v /home/mc/plugins:/etc/mcserver/plugins \
    -v /home/mc/worlds:/etc/mcserver/worlds \
    -v /home/mc/locals:/etc/mcserver/locals \
    -e MC_VERSION=1.14.3 \
    -e XMS=2G \
    -e XMX=4G \
    -d \
    spigot-dockerized:1.13.2
```

Or, if you are using docker-compose:

```yml
version: '3'

services:
  #...
  spigot:
    image: 'zekro/spigot-autobuild:latest'
    restart: always
    environment:
      - 'MC_VERSION=1.14.3'
      - 'XMS=2G'
      - 'XMX=4G'
    ports:
      - '25565:25565'
      - '25575:25575'
    volumes:
      - './spigot/config:/etc/mcserver/config'
      - './spigot/plugins:/etc/mcserver/plugins'
      - './spigot/worlds:/etc/mcserver/worlds'
      - './spigot/locals:/etc/mcserver/locals'

```

## Build It Yourself

Build the image yourself by cloning this repository and build the image with `docker build`:

```
$ git clone https://github.com/zekroTJA/spigot-autobuild --branch master --depth 1
$ cd spigot-autobuild
$ docker build . -t zekro/spigot-autobuild:latest
```
