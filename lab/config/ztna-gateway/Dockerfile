FROM alpine:3.19

RUN apk add --no-cache \
    bash \
    wireguard-tools \
    iptables \
    iproute2 \
    iputils \
    curl \
    net-tools \
    nginx

COPY start-ztna.sh /usr/local/bin/start-ztna.sh
COPY ztna-nginx.conf /etc/nginx/nginx.conf
RUN chmod +x /usr/local/bin/start-ztna.sh

EXPOSE 51820/udp 8443

CMD ["/usr/local/bin/start-ztna.sh"]
