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

echo "=== $(date '+%F %T') CLEANUP JOB START (AGE=$AGE) ===" >> "$LOG_FILE"

rclone delete "$ARCHIVE" --min-age "$AGE" \
  >> "$LOG_FILE" 2>&1

RC=$?

if [ $RC -eq 0 ]; then
  MESSAGE="Cleanup Job auf ${STORAGE_BOX} erfolgreich: $(date '+%F %T') (AGE=$AGE)"
  PRIO="3"
  STATUS="SUCCESS"
else
  MESSAGE="Cleanup Job FEHLER auf ${STORAGE_BOX}: $(date '+%F %T') (AGE=$AGE)"
  PRIO="5"
  STATUS="ERROR"
fi

echo "=== $(date '+%F %T') CLEANUP JOB END ($STATUS) ===" >> "$LOG_FILE"

$NTFY DEFAULT "$TITLE_CLEANUP" "$MESSAGE" --prio="$PRIO" --tags="$TAGS_CLEANUP"
