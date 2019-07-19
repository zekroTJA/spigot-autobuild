#!/bin/bash

ORIGIN=$PWD
WDIR=/tmp/build

set -e

mkdir $WDIR
cd $WDIR

curl https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar \
    --output ./BuildTools.jar

java -jar ./BuildTools.jar --rev $MC_VERSION

mv ./spigot-*.jar $ORIGIN/spigot.jar

cd $ORIGIN