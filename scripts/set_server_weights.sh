#!/bin/sh
echo 'show stat' | nc -U /var/run/haproxy.sock \
    | awk -F "," -f /scripts/server_latencies.awk \
    | xargs -I {} sh -c "echo {} | nc -U /var/run/haproxy.sock > /dev/null; echo {}"

exit $?