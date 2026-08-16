FROM alpine:3.19

RUN apk add --no-cache \
    rsyslog \
    bash \
    curl \
    iproute2 \
    grep \
    less \
    logrotate

# Create syslog directory structure
RUN mkdir -p /var/log/nexus-syslog /var/log/nexus-alerts

# Rsyslog configuration
COPY rsyslog.conf /etc/rsyslog.conf

# Generate synthetic realistic syslog entries on startup
COPY seed-syslog.sh /usr/local/bin/seed-syslog.sh
RUN chmod +x /usr/local/bin/seed-syslog.sh

EXPOSE 514/udp 514/tcp

CMD ["/usr/local/bin/seed-syslog.sh"]
