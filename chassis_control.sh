#!/bin/bash

STATE_FILE="/tmp/ipmi/chassis_state"
CPU_FILE="/tmp/ipmi/cpu_temp.ipm"

CMD="$2"
ACTION="$3"

if [ ! -f "$STATE_FILE" ]; then
  echo "on" >"$STATE_FILE"
fi

STATE="$(cat "$STATE_FILE" 2>/dev/null || echo on)"

if [ "$CMD" = "set" ]; then
  case "$ACTION" in
  off)
    echo "off" >"$STATE_FILE"
    echo "Chassis Power Control: Down/Off"
    if [ -f "$CPU_FILE" ]; then
      echo "45" >"$CPU_FILE"
    fi
    exit 0
    ;;
  on)
    echo "on" >"$STATE_FILE"
    echo "Chassis Power Control: Up/On"
    exit 0
    ;;
  reset)
    echo "on" >"$STATE_FILE"
    echo "Chassis Power Control: Reset"
    if [ -f "$CPU_FILE" ]; then
      echo "45" >"$CPU_FILE"
    fi
    exit 0
    ;;
  cycle)
    echo "on" >"$STATE_FILE"
    echo "Chassis Power Control: Cycle"
    exit 0
    ;;
  esac
fi

exit 0
