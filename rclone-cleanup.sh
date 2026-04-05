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

echo "=== $(date '+%F %T') CLEANUP JOB START (AGE=$AGE) ===" >> "$LOG_FILE"

rclone delete "$ARCHIVE" --min-age "$AGE" \
  --progress \
  >> "$LOG_FILE" 2>&1

RC=$?

if [ $RC -eq 0 ]; then
  MESSAGE="Cleanup job successful on ${STORAGE_BOX}: $(date '+%F %T') (AGE=$AGE)"
  PRIO="3"
  STATUS="SUCCESS"
else
  MESSAGE="Cleanup job FAILED on ${STORAGE_BOX}: $(date '+%F %T') (AGE=$AGE)"
  PRIO="5"
  STATUS="ERROR"
fi

echo "=== $(date '+%F %T') CLEANUP JOB END ($STATUS) ===" >> "$LOG_FILE"

notify "$TITLE_CLEANUP" "$MESSAGE" "$PRIO" "$TAGS_CLEANUP"