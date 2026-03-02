#!/bin/sh
set -e

# Start dynamic sensor value generator in background
/ipmisim/dynamic.sh &

# Give poll files a moment to initialize
sleep 1

# Start ipmi_sim in foreground
exec ipmi_sim \
    -c /ipmisim/lan.conf \
    -f /ipmisim/sim.emu \
    -s /ipmisim/state \
    -n
