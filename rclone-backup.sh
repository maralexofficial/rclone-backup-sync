#!/bin/bash

ENV_FILE=".env"

if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
else
  echo "Env file not found: $ENV_FILE"
  exit 1
fi

echo "=== $(date '+%F %T') BACKUP SYNC JOB START ===" >> "$LOG_FILE"

rclone sync "$SRC" "$DEST/current" \
  --backup-dir "$ARCHIVE/$TS" \
  >> "$LOG_FILE" 2>&1

RC=$?

if [ $RC -eq 0 ]; then
  MSG="Backup Job auf ${STORAGE_BOX} erfolgreich: $(date '+%F %T')"
  PRIO="3"
  STATUS="SUCCESS"
else
  MSG="Backup Job FEHLER auf ${STORAGE_BOX}: $(date '+%F %T')"
  PRIO="5"
  STATUS="ERROR"
fi

echo "=== $(date '+%F %T') BACKUP SYNC JOB END ($STATUS) ===" >> "$LOG_FILE"

$NTFY DEFAULT "$TITLE_SYNC" "$MSG" --prio="$PRIO" --tags="$TAGS_SYNC"