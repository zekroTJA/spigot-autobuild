#!/bin/bash

WDIR=/etc/mcserver

set -e
echo "# Server Information

| Key | Value |
| --- | ---   |
| Minecraft Version | ${MC_VERSION} |
| Java Version | ${JAVA_VERSION} |
| JVM Params | ${JVM_PARAMS}|
| Java Xms | ${XMS} |
| Java Xmx | ${XMX} |

## Notice

$NOTICE

---
Autogenerated $(date)" > "$WDIR/information.md"
