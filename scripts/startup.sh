#!/bin/bash

set -e
source ./scripts/utils.sh

backup() {
  if output=$(./scripts/backup.sh "$1" 2>&1); then
    notify "$BACKUP_SUCCESS_SCRIPT" "$output"
  else
    notify "$BACKUP_FAILED_SCRIPT" "$output"
  fi
}

./scripts/information.sh
is_true "$PRE_START_BACKUP" && backup "pre" &
./scripts/build.sh
./scripts/run.sh
is_true "$POST_START_BACKUP" && backup "post"