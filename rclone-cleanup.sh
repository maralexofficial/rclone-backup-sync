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

info "Cleanup job started"

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
  MSG="Cleanup job on ${STORAGE_BOX} (age=$AGE) successful."
  PRIO="3"
  success "$MSG"
else
  MSG="Cleanup job on ${STORAGE_BOX} (age=$AGE) FAILED."
  PRIO="5"
  error "$MSG"
fi

notify "$TITLE_CLEANUP" "$MSG" "$PRIO" "$TAGS_CLEANUP"
