#!/bin/bash

send_notification() {
  local title="$1"
  local message="$2"
  local priority="$3"
  local tags="$4"

  local subject="${SMTP_SUBJECT_PREFIX} $title"

  echo "$message" | mail \
    -s "$subject" \
    -r "$SMTP_FROM" \
    "$SMTP_TO"
}