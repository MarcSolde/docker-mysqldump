#!/bin/bash

set -e

CRON_SCHEDULE=${CRON_SCHEDULE:-0 0 * * *}

if [[ "$1" == 'no-cron' ]]; then
    exec /backup.sh
else
    LOGFIFO='/var/log/cron.fifo'
    if [[ ! -e "$LOGFIFO" ]]; then
        mkfifo "$LOGFIFO"
    fi
    CRON_ENV="MYSQL_ROOT_PASSWORD='$MYSQL_ROOT_PASSWORD'"
    CRON_ENV="$CRON_ENV\nMYSQL_HOST='$MYSQL_HOST'"
    CRON_ENV="$CRON_ENV\nMYSQL_PORT='$MYSQL_PORT'"
    CRON_ENV="$CRON_ENV\nBACKUP_EXPIRE_DAYS='$BACKUP_EXPIRE_DAYS'"
    CRON_ENV="$CRON_ENV\nBACKUP_FILE_NAME='$BACKUP_FILE_NAME'"
    # CRON_ENV="$CRON_ENV\nMONGO_DB_NAMES='$MONGO_DB_NAMES'"
    # CRON_ENV="$CRON_ENV\nMONGO_USERNAME='$MONGO_USERNAME'"
    # CRON_ENV="$CRON_ENV\nMONGO_PASSWORD='$MONGO_PASSWORD'"
    echo -e "$CRON_ENV\n$CRON_SCHEDULE /backup.sh > $LOGFIFO 2>&1" | crontab -
    crontab -l
    cron
    tail -f "$LOGFIFO"
fi
