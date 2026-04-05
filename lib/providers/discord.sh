#!/bin/bash

init_discord() {
  if [ -z "${DISCORD_WEBHOOK_URL:-}" ]; then
    error "DISCORD_WEBHOOK_URL not set"
    return 1
  fi

  command -v curl >/dev/null 2>&1 || {
    error "curl not found"
    return 1
  }

  info "Discord provider initialized"
}

discord_send() {
  local title="$1"
  local message="$2"
  local priority="$3"
  local tags="$4"
  local color=3066993

  if [ "$priority" -ge 5 ]; then
    color=15158332
  fi

  payload=$(cat <<EOF
{
  "embeds": [
    {
      "title": "$title",
      "description": "$message\n\nTags: $tags",
      "color": $color,
      "footer": {
        "text": "[RCLONE-BACKUP-SYNC] github.com/maralexofficial"
      }
    }
  ]
}
EOF
)

  curl -H "Content-Type: application/json" \
    -X POST \
    -d "$payload" \
    "$DISCORD_WEBHOOK_URL"
}