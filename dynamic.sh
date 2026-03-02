#!/bin/sh

POLL_DIR="/tmp/ipmi"
INTERVAL="${DYNAMIC_INTERVAL:-5}"

mkdir -p "$POLL_DIR"

# стартовые значения
CPU=30
SYS=25
PER=20
FAN1=25
FAN2=27
V12=115
V5=48
V33=32
VCORE=120

while true; do
  # простая «пила» вместо RANDOM

  CPU=$((CPU + 1))
  [ "$CPU" -gt 70 ] && CPU=30
  SYS=$((SYS + 1))
  [ "$SYS" -gt 55 ] && SYS=25
  PER=$((PER + 1))
  [ "$PER" -gt 50 ] && PER=20

  FAN1=$((FAN1 + 1))
  [ "$FAN1" -gt 35 ] && FAN1=25
  FAN2=$((FAN2 + 1))
  [ "$FAN2" -gt 37 ] && FAN2=27

  V12=$((V12 + 1))
  [ "$V12" -gt 125 ] && V12=115
  V5=$((V5 + 1))
  [ "$V5" -gt 52 ] && V5=48
  V33=$((V33 + 1))
  [ "$V33" -gt 34 ] && V33=32
  VCORE=$((VCORE + 1))
  [ "$VCORE" -gt 140 ] && VCORE=120

  printf '0x%02X\n' "$CPU" >"$POLL_DIR/cpu_temp.ipm"
  printf '0x%02X\n' "$SYS" >"$POLL_DIR/sys_temp.ipm"
  printf '0x%02X\n' "$PER" >"$POLL_DIR/per_temp.ipm"
  printf '0x%02X\n' "$FAN1" >"$POLL_DIR/fan1.ipm"
  printf '0x%02X\n' "$FAN2" >"$POLL_DIR/fan2.ipm"
  printf '0x%02X\n' "$V12" >"$POLL_DIR/v12.ipm"
  printf '0x%02X\n' "$V5" >"$POLL_DIR/v5.ipm"
  printf '0x%02X\n' "$V33" >"$POLL_DIR/v33.ipm"
  printf '0x%02X\n' "$VCORE" >"$POLL_DIR/vcore.ipm"

  sleep "$INTERVAL"
done
