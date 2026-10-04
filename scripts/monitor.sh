#!/usr/bin/env bash
set -euo pipefail

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
    exit 1
}

cleanup() {
    log "Received shutdown signal..."
    exit 0
}
trap cleanup SIGTERM SIGINT

SERVICE="${1:-}"
if [[ -z "$SERVICE" ]]; then
    error "Usage: $0 <service-name>"
fi
log "Checking service: $SERVICE"

STATUS=$(systemctl is-active "$SERVICE" 2>/dev/null || true)
if [[ "$STATUS" == "active" ]]; then
    log "$SERVICE is running"
else
    log "$SERVICE is not running, status: $STATUS"
    log "Last 10 log lines:"
    journalctl -u "$SERVICE" -n 10 --no-pager 2>/dev/null || log "No logs available"
fi

if [[ -r /var/log/syslog ]]; then
    ERRORS=$(grep -icE 'error|fail' /var/log/syslog || true)
    log "Errors in syslog: $ERRORS"
else
    log "Syslog not readable (run with sudo)"
fi
