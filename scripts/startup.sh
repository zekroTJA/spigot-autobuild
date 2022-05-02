#!/bin/bash

set -e
source ./scripts/utils.sh

./scripts/information.sh
is_true "$PRE_START_BACKUP" && ./scripts/backup.sh "pre"
./scripts/build.sh
./scripts/run.sh
is_true "$POST_START_BACKUP" && ./scripts/backup.sh "post"