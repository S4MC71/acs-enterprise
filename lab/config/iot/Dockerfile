FROM alpine:3.19

RUN apk add --no-cache bash curl iproute2 mosquitto mosquitto-clients

# Mosquitto MQTT broker config (open/unauthenticated — intentional for IoT lab)
COPY mosquitto.conf /etc/mosquitto/mosquitto.conf

# IoT device simulation script
COPY iot-device.sh /usr/local/bin/iot-device.sh
RUN chmod +x /usr/local/bin/iot-device.sh

EXPOSE 1883 9001

CMD ["/usr/local/bin/iot-device.sh"]
