#!/bin/bash

ORIGIN=$PWD
WDIR=/tmp/build

set -e

source ./scripts/utils.sh

is_true "$BUILD_CACHING" && {
    printf "\n[${CYAN} INFO ${RESET}] BUILD CACHING IS ACTIVATED\n\n"

    SPIGOT_REF=$(curl https://hub.spigotmc.org/versions/${MC_VERSION}.json | jq -r '.refs.Spigot')

    [ -f spigot_ref.txt ] &&\
        [ "$(cat spigot_ref.txt)" == "$SPIGOT_REF" ] && {
            printf "\n[${CYAN} INFO ${RESET}] VERSION UP TO DATE (${PURPLE}${SPIGOT_REF}${RESET}) - USING CACHED BUILD\n\n"
            exit 0
        }
    
    echo $SPIGOT_REF > spigot_ref.txt

    printf "\n[${CYAN} INFO ${RESET}] CACHED BUILD OUTDATED - BUILDING LATEST VERSION\n\n"
}

mkdir $WDIR || true
cd $WDIR

curl https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar \
    --output ./BuildTools.jar

java -jar ./BuildTools.jar --rev $MC_VERSION

mv ./spigot-*.jar $ORIGIN/spigot.jar

cd $ORIGIN

rm -r -f $WDIR
