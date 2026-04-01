#!/bin/bash

LOG_FILE="${LOG_FILE:-/var/log/ipmi-sim/student_commands.csv}"
VERDICT_FILE="${VERDICT_FILE:-/var/log/ipmi-sim/verdict.txt}"

CHOICE="$(grep '^choice=' "${VERDICT_FILE}" | head -n1 | cut -d'=' -f2 || echo "")"
if [ "${CHOICE}" = "1" ]; then
  VERDICT_SCORE=1
else
  VERDICT_SCORE=0
fi

CMD_LIST="$(tail -n +2 "${LOG_FILE}")"

if echo "${CMD_LIST}" | grep -qi "power reset"; then
  N_SCORE=1
else
  HAS_OFF=0
  HAS_ON=0
  if echo "${CMD_LIST}" | grep -qi "power off"; then
    HAS_OFF=1
  fi
  if echo "${CMD_LIST}" | grep -qi "power on"; then
    HAS_ON=1
  fi
  if [ "${HAS_OFF}" -eq 1 ] && [ "${HAS_ON}" -eq 1 ]; then
    N_SCORE=1
  else
    N_SCORE=0
  fi
fi

DIAG_COUNT="$(echo "${CMD_LIST}" | grep -Ei "sel list|sdr list|sensor reading" | wc -l | tr -d ' ')"

if [ "${DIAG_COUNT}" -eq 0 ]; then
  EXTRA_SCORE=0
elif [ "${DIAG_COUNT}" -le 2 ]; then
  EXTRA_SCORE=0.5
elif [ "${DIAG_COUNT}" -le 8 ]; then
  EXTRA_SCORE=1
else
  EXTRA_SCORE=0.5
fi

# final = 0.4*VERDICT + 0.4*N + 0.2*EXTRA
FINAL_SCORE=$(awk -v v="${VERDICT_SCORE}" -v n="${N_SCORE}" -v e="${EXTRA_SCORE}" 'BEGIN { printf "%.2f", 0.4*v + 0.4*n + 0.2*e }')

echo "VERDICT_SCORE=${VERDICT_SCORE}"
echo "N_SCORE=${N_SCORE}"
echo "EXTRA_SCORE=${EXTRA_SCORE}"
echo "FINAL_SCORE=${FINAL_SCORE}"
