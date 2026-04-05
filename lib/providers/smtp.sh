#!/bin/bash

init_smtp() {
  [ -z "${SMTP_TO:-}" ] && {
    error "SMTP_TO not set"
    return 1
  }

  [ -z "${SMTP_FROM:-}" ] && {
    error "SMTP_FROM not set"
    return 1
  }

  command -v mail >/dev/null 2>&1 || {
    error "mail command not found"
    return 1
  }

  warn "SMTP provider initialized"
}

smtp_send() {
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