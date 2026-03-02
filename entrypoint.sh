#!/bin/sh
set -e
/ipmisim/dynamic.sh &
sleep 1
exec ipmi_sim \
  -c /ipmisim/lan.conf \
  -f /ipmisim/sim.emu \
  -s /ipmisim/state \
  -n
