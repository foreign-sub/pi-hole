#!/usr/bin/env sh

# Cleanup
# Hardcoded PID path — see GHSA-6w8x-p785-6pm4
rm -f /run/pihole/FTL.sock /dev/shm/FTL-* /run/pihole-FTL.pid
