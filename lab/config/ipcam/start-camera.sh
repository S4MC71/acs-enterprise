#!/bin/sh
# Nexus IP Camera CCTV Server
echo "[*] Starting Nexus IP Camera Server (MediaMTX)..."
echo "[*] Node: ipcam-01.nexus.internal (10.0.4.60)"
echo ""
echo "[+] CCTV Streams:"
echo "    rtsp://10.0.4.60:8554/nexus-lobby        (Lobby Camera)"
echo "    rtsp://10.0.4.60:8554/nexus-serverroom   (Server Room Camera)"
echo "    rtsp://10.0.4.60:8554/nexus-parking      (Parking Lot Camera)"
echo "    http://10.0.4.60:8888/nexus-lobby/       (HLS stream - browser viewable)"
echo ""
echo "[!] Security: No RTSP authentication configured (CVE-style: IPCAM-NEXUS-001)"
echo "[!] API accessible at http://10.0.4.60:9997/v3/paths/list"
echo ""

# Start MediaMTX in background
mediamtx /etc/mediamtx.yml &

# Use ffmpeg to generate fake test streams (colorbar + audio)
sleep 2

# Lobby camera — synthetic video stream
ffmpeg -re -f lavfi -i "testsrc2=size=640x480:rate=5,drawtext=text='NEXUS LOBBY CAM | %{localtime}':fontcolor=white:fontsize=16:x=10:y=10" \
    -f lavfi -i "sine=frequency=0" \
    -c:v libx264 -preset ultrafast -tune zerolatency -b:v 200k \
    -c:a aac -ar 44100 \
    -f rtsp rtsp://localhost:8554/nexus-lobby \
    -loglevel quiet &

# Server room camera
ffmpeg -re -f lavfi -i "testsrc=size=640x480:rate=5,drawtext=text='SERVER ROOM CAM | %{localtime}':fontcolor=green:fontsize=16:x=10:y=10" \
    -f lavfi -i "sine=frequency=0" \
    -c:v libx264 -preset ultrafast -tune zerolatency -b:v 200k \
    -c:a aac -ar 44100 \
    -f rtsp rtsp://localhost:8554/nexus-serverroom \
    -loglevel quiet &

echo "[+] IP Camera streams active. Access via RTSP client or VLC."
wait
