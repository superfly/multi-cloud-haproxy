#!/bin/sh

output=`curl -s -o /dev/null -w "%{http_code}-%{time_starttransfer}" https://$HAPROXY_SERVER_NAME:$HAPROXY_SERVER_PORT --resolve $HAPROXY_SERVER_NAME:443:$HAPROXY_SERVER_ADDR`
code=${output%-*}
ttl=${output#*-}

if [ "$code" == "200" ]; then
  echo "$HAPROXY_PROXY_NAME $HAPROXY_SERVER_NAME $ttl" >> /tmp/times.txt
  exit 0
else
  echo "error: https://$HAPROXY_SERVER_NAME:$HAPROXY_SERVER_PORT -> $code"
  exit 1
fi

# NOT_USED NOT_USED 34.240.41.237 443
# HAPROXY_SERVER_PORT=443
# HAPROXY_SERVER_NAME=flyio-helloworld-eu.herokuapp.com
# SHLVL=1
# HAPROXY_SERVER_ID=3
# HAPROXY_SERVER_MAXCONN=0
# HAPROXY_SERVER_CURCONN=0
# PATH=/usr/bin:/bin
# HAPROXY_PROXY_ADDR=
# HAPROXY_PROXY_PORT=
# HAPROXY_PROXY_NAME=upstream
# PWD=/
# HAPROXY_PROXY_ID=3
# HAPROXY_SERVER_ADDR=34.240.41.237