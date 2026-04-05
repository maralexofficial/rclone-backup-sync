#!/bin/bash

init_ntfy() {
  if [ -z "${NTFY:-}" ]; then
    NTFY="/usr/bin/ntfy-send"
    warn "NTFY not set. Using default: $NTFY"
  fi

  if [ ! -x "$NTFY" ]; then
    error "NTFY binary not executable: $NTFY"
    return 1
  fi

  info "NTFY provider initialized"
}

ntfy_send() {
  local title="$1"
  local message="$2"
  local priority="$3"
  local tags="$4"

  "$NTFY" DEFAULT "$title" "$message" \
    --prio="$priority" \
    --tags="$tags"
}