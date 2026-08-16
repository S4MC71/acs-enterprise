FROM alpine:3.19

RUN apk add --no-cache \
    bash \
    iptables \
    ip6tables \
    iproute2 \
    iputils \
    curl \
    net-tools \
    bind-tools

COPY start-router.sh /usr/local/bin/start-router.sh
RUN chmod +x /usr/local/bin/start-router.sh

CMD ["/usr/local/bin/start-router.sh"]
