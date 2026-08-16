FROM alpine:3.19

RUN apk add --no-cache \
    bash \
    iptables \
    ip6tables \
    iproute2 \
    iputils \
    curl \
    net-tools \
    bind-tools \
    tcpdump

COPY start-firewall.sh /usr/local/bin/start-firewall.sh
RUN chmod +x /usr/local/bin/start-firewall.sh

CMD ["/usr/local/bin/start-firewall.sh"]
