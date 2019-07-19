#!/bin/bash

set -e

cd /etc/mcserver/locals

echo "eula=true" | tee eula.txt

java -jar \
    -Xms${XMS} -Xmx${XMX} ${JVM_PARAMS} \
    /var/mcserver/spigot.jar \
        --commands-settings /etc/mcserver/config/commands.yml \
        --plugins           /etc/mcserver/plugins \
        --spigot-settings   /etc/mcserver/config/spigot.yml \
        --world-container   /etc/mcserver/worlds \
        --bukkit-settings   /etc/mcserver/config/bukkit.yml