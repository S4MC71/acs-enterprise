FROM alpine:3.19

RUN apk add --no-cache bash iptables iproute2 iputils curl net-tools

COPY start-cloud-gw.sh /usr/local/bin/start-cloud-gw.sh
RUN chmod +x /usr/local/bin/start-cloud-gw.sh

CMD ["/usr/local/bin/start-cloud-gw.sh"]
