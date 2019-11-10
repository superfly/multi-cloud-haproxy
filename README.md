# Multi Cloud Routing with HAProxy

This is an example HAProxy configuration for geo routing HTTP traffic across cloud providers. It's designed to run on the [fly.io Global Container Runtime](https://fly.io/docs/future/), but is easily deployed on any infrastructure that can run Docker Images and accept traffic globally.

## How it works

This is a simple HAProxy configuration with a single `upstream` backend with endpoints in different cloud regions specified as servers. It uses an external script for server health checks, and records the latency of each health check request. Every few seconds, it calculates the 90th percentile latency for each server, picks the fastest, and sets it to the highest prioity in HAProxy.

The example config uses a simple Docker container deployed to a few different cloud provider regions. It could be easily adapted to balance across FaaS endpoints, or distribute TCP connections.

```haproxy
## google cloud run container in us-central
server helloworld-i7p6d4rcpq-uc.a.run.app helloworld-i7p6d4rcpq-uc.a.run.app:443 check ssl check-ssl verify none weight 0

## google cloud run container in europe
server helloworld-i7p6d4rcpq-ew.a.run.app helloworld-i7p6d4rcpq-ew.a.run.app:443 check ssl check-ssl verify none weight 0

## heroku dyno in europe
server flyio-helloworld-eu.herokuapp.com flyio-helloworld-eu.herokuapp.com:443 check ssl check-ssl verify none weight 0

## heroku dyno in viginia
server flyio-helloworld.herokuapp.com flyio-helloworld.herokuapp.com:443 check ssl check-ssl verify none weight 0
```

Latency calculations are done with AWK + shell script (`scripts/set_server_weights.sh`), and run periodically with a "fake" HAProxy backend with an external health check setup. HAProxy servers support integer based weights between zero and 256 for distributing traffic, so the fastest available endpoint gets a weight of 256, the next fastest gets a weight of 1 (to use as a backup), and the remainder gets weights of 0 (effectively disabling them).


#### Important files

<dl>
  <dt><a href="https://github.com/superfly/multi-cloud-haproxy/blob/master/haproxy.cfg"><code>haproxy.cfg</code></a></dt>
  <dd>The HAProxy configuration file. This specifies upstream servers (look for the `backend upstream` section).</dd>
  <dt><a href="https://github.com/superfly/multi-cloud-haproxy/blob/master/scripts/check_server_https.sh"><code>scripts/check_server_https.sh</code></a></dt>
  <dd>CURL based script for performing upstream health checks (see the `backend upstream` section of HAProxy config). This script writes the round trip time (`rtt`) for each request to `/tmp/times.txt`.</dd>
  <dt><a href="https://github.com/superfly/multi-cloud-haproxy/blob/master/scripts/set_server_weights.sh"><code>scripts/set_server_weights.sh</code></a></dt>
  <dd>AWK based script for consuming `/tmp/times.txt` from the health checks, then sending individual server weights to the HAProxy admin socket based on servers 90th percentile health check latency.</dd>
  <dt><a href="https://github.com/superfly/multi-cloud-haproxy/blob/master/scripts/server_latencies.awk"><code>scripts/server_latencies.aws</code></a></dt>
  <dd>An AWK script file for aggregating latencies and generating HAProxy socket commands for setting weights.</dd>
</dl>

### The Docker Image

This uses the base HAProxy Alpine image with, and adds `netcat-openbsd` for communicating with the HAProxy socket. The whole image weighs in at `22.8MB` which makes it pretty great for running at the edge.

### Run it locally

If you have Docker installed, you can run the example locally. There's a shortcut script that's helpful for development, run `./run_local.sh` to destroy the existing container (if any), build the image, and launch a new container. Once it's running try these URLs:

* http://localhost:9000 for HAProxy stats, check out the server weights
* http://localhost:8080 to hit the app
