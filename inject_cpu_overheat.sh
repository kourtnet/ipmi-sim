#!/bin/bash

CPU_FILE="/tmp/ipmi/cpu_temp.ipm"
FAULT_VALUE="95"

echo "${FAULT_VALUE}" >"${CPU_FILE}"
