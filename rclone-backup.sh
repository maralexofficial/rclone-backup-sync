#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set -euo pipefail

source "$SCRIPT_DIR/lib/console.sh"

ENV_FILE="$SCRIPT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
else
  error "Env file not found: $ENV_FILE"
  exit 1
fi

source "$SCRIPT_DIR/lib/notifications.sh"

info "$(date '+%F %T') Backup sync job started"

rclone sync "$SRC" "$DEST/current" \
  --backup-dir "$ARCHIVE/$TS" \
  --progress 2>&1 | while IFS= read -r line; do
    if [[ "$line" == *"ERROR"* ]]; then
      error "$line"
    elif [[ "$line" == *"WARN"* ]]; then
      warn "$line"
    fi
  done

RC=${PIPESTATUS[0]}

if [ $RC -eq 0 ]; then
  MSG="Backup sync job on ${STORAGE_BOX} successful: $(date '+%F %T')"
  PRIO="3"
  STATUS="SUCCESS"
  success "$MSG"
else
  MSG="Backup sync job on ${STORAGE_BOX} FAILED: $(date '+%F %T')"
  PRIO="5"
  STATUS="ERROR"
  error "$MSG"
fi

notify "$TITLE_SYNC" "$MSG" "$PRIO" "$TAGS_SYNC"