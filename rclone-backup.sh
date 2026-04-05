#!/bin/bash

source "./lib/console.sh"
source "./lib/notifications.sh"

ENV_FILE=".env"

if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
else
  error "Env file not found: $ENV_FILE"
  exit 1
fi

echo "=== $(date '+%F %T') BACKUP SYNC JOB START ===" >> "$LOG_FILE"

rclone sync "$SRC" "$DEST/current" \
  --backup-dir "$ARCHIVE/$TS" \
  --progress \
  >> "$LOG_FILE" 2>&1

RC=$?

if [ $RC -eq 0 ]; then
  MSG="Backup job on ${STORAGE_BOX} successful: $(date '+%F %T')"
  PRIO="3"
  STATUS="SUCCESS"
else
  MSG="Backup job on ${STORAGE_BOX} FAILED: $(date '+%F %T')"
  PRIO="5"
  STATUS="ERROR"
fi

echo "=== $(date '+%F %T') BACKUP SYNC JOB END ($STATUS) ===" >> "$LOG_FILE"

notify "$TITLE_SYNC" "$MSG" "$PRIO" "$TAGS_SYNC"