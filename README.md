# Multi Cloud Routing with HAProxy

This is an example project for geo routing HTTP traffic with HAProxy. It's designed to run on Fly's [Global Container Runtime](https://fly.io/docs/future/), but is easily deployed on any infrastructure that can run Docker Images and accept traffic globally.

The example config routes traffic across two regions with Google Cloud Run containers running, and Heroku apps in both Heroku regions (`us-east`, `eu-west`).

#### Important files

<dl>
  <dt><a href="https://github.com/superfly/multi-cloud-haproxy/blob/master/haproxy.cfg"><code>haproxy.cfg</code></a></dt>
  <dd>The HAProxy configuration file. This specifies upstream servers (look for the `backend upstream` section).</dd>
  <dt><a href="https://github.com/superfly/multi-cloud-haproxy/blob/master/scripts/check_server_https.sh"><code>scripts/check_server_https.sh</code></a></dt>
  <dd>CURL based script fo performing upstream health checks (see the `backend upstream` section of HAProxy config). This script writes the round trip time (`rtt`) for each request to `/tmp/times.txt`.</dd>
  <dt><a href="https://github.com/superfly/multi-cloud-haproxy/blob/master/scripts/set_server_weights.sh"><code>scripts/set_server_weights.sh</code></a></dt>
  <dd>AWK based script for consuming `/tmp/times.txt` from the health checks, then sending individual server weights to the HAProxy admin socket based on servers 90th percentile health check latency.</dd>
  <dt><a href="https://github.com/superfly/multi-cloud-haproxy/blob/master/scripts/server_latencies.awk"><code>scripts/server_latencies.aws</code></a></dt>
  <dd>An AWK script file for aggregating latencies and generating HAProxy socket commands for setting weights.</dd>
</dl>