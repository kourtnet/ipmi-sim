#!/bin/bash

set -euo pipefail

LOG_DIR="/var/log/ipmi-sim"
LOG_FILE="${LOG_DIR}/student_commands.csv"

mkdir -p "${LOG_DIR}"

if [ ! -f "${LOG_FILE}" ]; then
  echo "epoch,human_time,command" >"${LOG_FILE}"
fi

EPOCH=$(date +%s)
HUMAN=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
CMD_STR="$*"

echo "${EPOCH},${HUMAN},${CMD_STR}" >>"${LOG_FILE}"

exec /usr/sbin/ipmitool.real "$@"
