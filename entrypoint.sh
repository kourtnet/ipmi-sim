#!/bin/bash
set -e
exec ipmi_sim \
  -c /ipmisim/lan.conf \
  -f /ipmisim/sim.emu \
  -s /ipmisim/state \
  -n
