#!/bin/bash

load_provider() {
  case "$NOTIFY_TYPE" in
    ntfy)
      source "$(dirname "$0")/providers/ntfy.sh"
      ;;
    smtp)
      source "$(dirname "$0")/providers/smtp.sh"
      ;;
    discord)
      source "$(dirname "$0")/providers/discord.sh"
      ;;
    *)
      echo "Unknown NOTIFY_TYPE: $NOTIFY_TYPE" >&2
      return 1
      ;;
  esac
}

notify() {
  local title="$1"
  local message="$2"
  local priority="$3"
  local tags="$4"

  if [ -z "${NOTIFY_PROVIDER_LOADED:-}" ]; then
    if ! load_provider; then
      echo "Failed to load notification provider" >> "$LOG_FILE"
      return 1
    fi
    NOTIFY_PROVIDER_LOADED=1
  fi

  send_notification "$title" "$message" "$priority" "$tags"
}