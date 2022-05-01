#!/bin/bash

WDIR=/tmp/backup

set -e

source ./scripts/utils.sh

if [ -f /run/secrets/rcloneconfig ]; then
    if [ -f /etc/mcserver/config/bukkit.yml ]; then
        printf "\n[${CYAN} INFO ${RESET}] Starting backup\n"
        mkdir -p "$WDIR"

        FILENAME="$1-$(date ${BACKUP_FILE_FORMAT}).zip"

        # Start zipping server
        zip -9rq "${WDIR}/$FILENAME" "/etc/mcserver/"

        # Rclone move
        printf "\n[${CYAN} INFO ${RESET}] Start uploading of backup $FILENAME\n"
        rclone --config /run/secrets/rcloneconfig move "${WDIR}/$FILENAME" minecraft:/ -v &&
            rclone --config /run/secrets/rcloneconfig --min-age $MAX_AGE_BACKUP_FILES delete minecraft:/ -v

        # Delete WDIR
        rm -rf "$WDIR"
        printf "\n[${CYAN} INFO ${RESET}] Finished backup\n"
    else
        printf "\n[${CYAN} INFO ${RESET}] Minecraft server is not initialized\n"
    fi

else
    printf "\n[${CYAN} INFO ${RESET}] Backup is disabled\n"
fi

exit 0
