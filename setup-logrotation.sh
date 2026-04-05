#!/bin/bash

source "./lib/console.sh"

LOGROTATE_BIN="$(command -v logrotate)"

if [ -z "$LOGROTATE_BIN" ]; then
    error "logrotate not found."
    exit 1
fi

ENV_FILE=".env"

if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
else
    error "Env file not found: $ENV_FILE"
    exit 1
fi

LOGROTATE_DIR="${HOME}/.config/logrotate"

CONFIG_FILE="${LOGROTATE_DIR}/logrotate.conf"
STATUS_FILE="${LOGROTATE_DIR}/status"

USER_NAME="$(whoami)"
success "Installing logrotate config for user: $USER_NAME"

if [ -d "$LOGROTATE_DIR" ]; then
    warn "Logrotate directory already exists: $LOGROTATE_DIR"

    if ! confirm "Continue and reuse directory?"; then
        info "Aborted by user"
        exit 1
    fi
fi

mkdir -p "$LOGROTATE_DIR"
success "Logrotate directory created: $LOGROTATE_DIR"

if [ -f "$CONFIG_FILE" ]; then
    warn "Logrotate config already exists: $CONFIG_FILE"

    if ! confirm "Overwrite existing config?"; then
        info "Skipping config creation"
    else
        CREATE_CONFIG=1
    fi
else
    CREATE_CONFIG=1
fi

if [ "${CREATE_CONFIG:-0}" -eq 1 ]; then
    cat >"$CONFIG_FILE" <<EOF
$LOG_DIR/*.log {
  daily
  rotate 7
  compress
  missingok
  notifempty
  copytruncate
}
EOF

    success "Created logrotate config: $CONFIG_FILE"
fi

success "Select logrotate schedule:"
info "1) Daily at 03:00 (default)"
info "2) Custom"

read -r -p "Choice [1]: " CHOICE
CHOICE="${CHOICE:-1}"

case "$CHOICE" in
1)
    CRON_SCHEDULE="0 3 * * *"
    ;;
2)
    read -r -p "Enter cron expression (e.g. '*/15 * * * *'): " CRON_SCHEDULE
    ;;
*)
    warn "Invalid choice, using default"
    CRON_SCHEDULE="0 3 * * *"
    ;;
esac

info "Using cron schedule: $CRON_SCHEDULE"

info "Running test logrotate..."
/usr/sbin/logrotate -s "$STATUS_FILE" "$CONFIG_FILE"

success "Done ✅"
