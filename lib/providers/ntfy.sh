#!/bin/bash

send_notification() {
  local title="$1"
  local message="$2"
  local priority="$3"
  local tags="$4"

  "$NTFY" DEFAULT "$title" "$message" \
    --prio="$priority" \
    --tags="$tags"
}