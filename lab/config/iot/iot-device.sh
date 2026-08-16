#!/bin/sh
# Nexus IoT Sensor Device — MQTT Publisher
# Simulates campus IoT (temperature, access control, power sensors)

echo "[*] Starting Nexus IoT Device + MQTT Broker..."

# Start MQTT broker in background
mosquitto -c /etc/mosquitto/mosquitto.conf &
sleep 2

echo "[+] MQTT Broker running on port 1883 (unauthenticated - misconfigured)"
echo "[+] WebSocket: port 9001"
echo "[!] Security Issue: MQTT broker has no authentication (CVE-style: IoT-NEXUS-001)"
echo ""

# Publish realistic IoT sensor data indefinitely
DEVICE_ID="nexus-iot-campus-01"
BROKER="localhost"

while true; do
    TEMP=$((20 + RANDOM % 15))
    HUMIDITY=$((40 + RANDOM % 30))
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Sensor telemetry — subscribable by anyone on the network
    mosquitto_pub -h "$BROKER" -t "nexus/campus/sensors/temperature" \
        -m "{\"device\":\"$DEVICE_ID\",\"temp_c\":$TEMP,\"ts\":\"$TIMESTAMP\"}" 2>/dev/null

    mosquitto_pub -h "$BROKER" -t "nexus/campus/sensors/humidity" \
        -m "{\"device\":\"$DEVICE_ID\",\"humidity\":$HUMIDITY,\"ts\":\"$TIMESTAMP\"}" 2>/dev/null

    # Access control events — leaks physical security info
    mosquitto_pub -h "$BROKER" -t "nexus/campus/access-control/door-events" \
        -m "{\"door\":\"ServerRoom-A\",\"user\":\"tahmed\",\"badge\":\"NGE-0042\",\"access\":\"GRANTED\",\"ts\":\"$TIMESTAMP\"}" 2>/dev/null

    # Critical: internal infrastructure topic (accessible without auth!)
    mosquitto_pub -h "$BROKER" -t "nexus/internal/infra/alerts" \
        -m "{\"source\":\"UPS-CoreDC-01\",\"status\":\"OK\",\"dc_ip\":\"10.0.3.0/24\",\"erp\":\"10.0.3.10:8000\",\"db\":\"10.0.3.20:5432\",\"ts\":\"$TIMESTAMP\"}" 2>/dev/null

    sleep 10
done
