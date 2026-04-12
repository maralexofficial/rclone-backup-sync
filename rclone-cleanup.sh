#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/console.sh"

ENV_FILE=".env"

if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
else
  error "Env file not found: $ENV_FILE"
  exit 1
fi

source "$SCRIPT_DIR/lib/notifications.sh"

info "$(date '+%F %T') Cleanup job started"

rclone delete "$ARCHIVE" --min-age "$AGE" \
  --progress 2>&1 | while IFS= read -r line; do
    if [[ "$line" == *"ERROR"* ]]; then
      error "$line"
    elif [[ "$line" == *"WARN"* ]]; then
      warn "$line"
    else
      info "$line"
    fi
  done

RC=${PIPESTATUS[0]}

if [ $RC -eq 0 ]; then
  MESSAGE="Cleanup job successful on ${STORAGE_BOX}: $(date '+%F %T') (AGE=$AGE)"
  PRIO="3"
  STATUS="SUCCESS"
  success "$MSG"
else
  MESSAGE="Cleanup job FAILED on ${STORAGE_BOX}: $(date '+%F %T') (AGE=$AGE)"
  PRIO="5"
  STATUS="ERROR"
  error "$MSG"
fi

notify "$TITLE_CLEANUP" "$MESSAGE" "$PRIO" "$TAGS_CLEANUP"