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

COPY start-isp2.sh /usr/local/bin/start-isp2.sh
RUN chmod +x /usr/local/bin/start-isp2.sh

CMD ["/usr/local/bin/start-isp2.sh"]
