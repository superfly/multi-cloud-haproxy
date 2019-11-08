FROM haproxy:2.0-alpine

RUN apk add --no-cache netcat-openbsd curl

COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY scripts/* /scripts/
RUN chmod +x /scripts/*.sh