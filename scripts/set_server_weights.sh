#!/bin/sh
TMP=$(tail -n 500 /tmp/times.txt 2>/dev/null) && echo "${TMP}" > /tmp/times.txt
sort -k 2 -n /tmp/times.txt \
    | awk -F " " -f /scripts/server_latencies.awk \
    | xargs -I {} sh -c "echo {} | nc -U /var/run/haproxy.sock > /dev/null"

exit $?