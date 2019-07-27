#!/bin/bash

ORIGIN=$PWD
WDIR=/tmp/build

set -e

SPIGOT_REF=$(curl https://hub.spigotmc.org/versions/latest.json | jq -r '.refs.Spigot')

ls -lisah

[ -f spigot_ref.txt ] &&\
    [ "$(cat spigot_ref.txt)" == "$SPIGOT_REF" ] &&\
    exit 0

echo $SPIGOT_REF > spigot_ref.txt

mkdir $WDIR || true
cd $WDIR

curl https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar \
    --output ./BuildTools.jar

java -jar ./BuildTools.jar --rev $MC_VERSION

mv ./spigot-*.jar $ORIGIN/spigot.jar

cd $ORIGIN

rm -r -f $WDIR
