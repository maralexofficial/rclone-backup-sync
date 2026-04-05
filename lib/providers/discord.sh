#!/bin/bash

send_notification() {
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
      "description": "$message\n\nTags: $tags"
      "color": $color,
      "footer": {
        "text": "[RCLONE-BACKUP-SYNC] github.com/maralexofficial"
      }
    }
  ]
}
EOF
)

  curl -s -H "Content-Type: application/json" \
       -X POST \
       -d "$payload" \
       "$DISCORD_WEBHOOK_URL" > /dev/null
}