# Minecraft Spigot Dockerized - [AUTOBUILD VERSION]  🐳 💎

<a href="https://hub.docker.com/r/zekro/spigot-autobuild"><img alt="Docker Cloud Automated build" height="30" src="https://img.shields.io/docker/cloud/automated/zekro/spigot-autobuild.svg?color=cyan&logo=docker&logoColor=cyan&style=for-the-badge"></a>&nbsp;
<img height="30" src="https://forthebadge.com/images/badges/built-with-grammas-recipe.svg" />

## How Does It Work?

In contrast to [spigot-dockerized](https://github.com/zekroTJA/spigot-dockerized), where the pre-built spigot binary is already compiled on image built, this image downloads the latest BuildToos from spigot's Jenkins server and build the latest version of spigot directly on startup. Because building the `spigot.jar` can take up to several minutes *(depending on system resources ofc)*, each start of the server may take significantly longer than a normal dry start.

## How To Use

You can pull the image from [dockerhub](https://hub.docker.com/r/zekro/spigot-autobuild) or [build it yourself](#build-it-yourself).  
The `latest` image is also always the master branch and uses the latest LTS JDK version by default.
Choose the [right version](#version-selection) for your minecraft version.
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
    -e BUILD_CACHING=true \
    -e XMS=2G \
    -e XMX=4G \
    -d \
    spigot-autobuild:latest
```

Or, if you are using docker-compose:

```yml
version: '3'

services:
  #...

# Comment out for automatic backups. See section backup
#secrets:
#  minecraftrclone:
#    file: rclone.conf

  spigot:
    image: 'zekro/spigot-autobuild:latest'
    restart: always
    environment:
      - 'MC_VERSION=1.14.3'
      - 'BUILD_CACHING=true'
      - 'XMS=2G'
      - 'XMX=4G'
      - 'NOTICE=Personal note for this minecraft server'
    ports:
      - '25565:25565'
      - '25575:25575'
    volumes:
      - './spigot/config:/etc/mcserver/config'
      - './spigot/plugins:/etc/mcserver/plugins'
      - './spigot/worlds:/etc/mcserver/worlds'
      - './spigot/locals:/etc/mcserver/locals'
#    secrets: # Comment out for automatic backups. See section backup
#      - source: minecraftrclone
#        target: rcloneconfig
```

## Version Selection
### Docker Hub Tags
To build a Minecraft version that requires the JDK-8, the build argument `JDK_VERSION: 8` must be used. This Version is also available as a image on Docker Hub under `spigot-autobuild:jdk8`.

The version 1.16 is not available, but all other patch versions from the 1.16 are available. So `1.16.1`, `1.16.2`, `1.16.3`...  
Version `1.17` (not `1.17.X`) is only executable with Java 16 (no LTS).
### JDK-8
- 1.9
- 1.10
- 1.11
- 1.12
- 1.13
- 1.14
- 1.15
- 1.16(.1)


### JDK-11
- 1.13
- 1.14
- 1.15
- 1.16(.1)

### JDK-16
- 1.17
- 1.17.1

### JDK-17
- 1.17.1

## Build Caching?

Defaultly, `BUILD_CACHING` is enabled which builds the `spigot.jar` on first startup and saves the commit hash of this build in a save file inside the container. Next time you start the container, the saved hash will be compared with the has of the latest available version. Only if they differ, a new build will be started. Else, the previously built `spigot.jar` inside the container will be used.

## Build It Yourself

Build the image yourself by cloning this repository and build the image with `docker build`:

```
$ git clone https://github.com/zekroTJA/spigot-autobuild --branch master --depth 1
$ cd spigot-autobuild
$ docker build . -t zekro/spigot-autobuild:latest
```

## RCON CLI

Included in the Docker image is an RCON cli which can be used from insde the container to control the server without attaching to the servers stdin.

To use RCON, you need to set following values in the `server.properties`:
```cfg
enable-rcon=true
rcon.password=7mxQ8Br2QBsFFn2n
rcon.port=25575
```

Then, you can use the RCON cli like follwoing:

```
$ docker exec <container> rcon <server_command>
```

As you can see, you do not need to pass the password or port of the RCON connection. The tool automatically recognizes the location of the `server.properties` file and takes the password and address configuration from there.

Alternatively, when you really want to use the raw cli with no prepared presets, use the following command:
```
$ docker exec <container> rconcli -a loalhost:25575 -p <rcon_password> <server_command>
```

If you are further interested in the usage and details of the RCON cli, take a look [**here of the Github project**](https://github.com/zekroTJA/rconclient).

## Backup

Backups can be created automatically before a server start.
For this, a Docker secret must be stored in /run/secrets/rcloneconfig.  
rclone is used. The default target is `minecraft:/`  
Rclone offers a number of very [different destinations](https://rclone.org/overview/). In this example, an S3 endpoint with a specific subdirectory is used.

Example config:

```txt
[contabo]
type = s3
provider = Other
env_auth = false
access_key_id = access_key
secret_access_key = secret_key
endpoint = https://eu2.contabostorage.com/

[minecraft]
type = alias
remote = contabo:/minecraft-server
```

This configuration must now be loaded into the container as a secret.
Target file is ``/run/secrets/rcloneconfig``.
If the target file is found, the backup starts each container start.

### Envs for Backup Settings

For exact details please refer to ``backup.sh``.

- ``BACKUP_FILE_FORMAT``:
This can be used to specify the backup timestamp.
It uses the date command line tool to interpret the placeholder varibales (``date ${BACKUP_FILE_FORMAT}``).  
- ``BACKUP_TARGET``: Rclone backup target name
- ``MAX_AGE_BACKUP_FILES``:
Specify the maximum length of time a backup file should be kept. One backup file is always kept.
- ``POST_START_BACKUP``: Enable backup after server stop
- ``PRE_START_BACKUP``: Enable pre start backup  
- ``BACKUP_SUCCESS_SCRIPT``: Will be executed when the backup creation was successful.
- ``BACKUP_FAILED_SCRIPT``: Will be executed when the backup creation has failed.

An example for a `BACKUP_FAILED_SCRIPT` could look as following.
```
curl -u "user:password" -d "$MESSAGE" "https://ntfy.example.com/minecraft_backups?title=Backup%Failed"
```

The `$MESSAGE` environment variable will contain the stdout and stderr from the backup script.

### Why pre and post backups

The pre backups are necessary because the post backups are only executed when the Minecraft server shuts down by itself, for example by a ``/stop`` command. A Docker stop or Docker kill does not execute the backup anymore

---

© 2019 Ringo Hoffmann (zekro Development)  
Corvered by the MIT Licence.
