FROM alpine:3.19

RUN apk add --no-cache bash curl iproute2

# Download mediamtx — use specific known-good release for reproducibility
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi && \
    wget -q "https://github.com/bluenviron/mediamtx/releases/download/v1.9.3/mediamtx_v1.9.3_linux_${ARCH}.tar.gz" \
        -O /tmp/mediamtx.tar.gz && \
    tar -xzf /tmp/mediamtx.tar.gz -C /usr/local/bin mediamtx && \
    rm /tmp/mediamtx.tar.gz && \
    chmod +x /usr/local/bin/mediamtx

# Install ffmpeg for test stream generation (available in Alpine)
RUN apk add --no-cache ffmpeg

COPY mediamtx.yml /etc/mediamtx.yml
COPY start-camera.sh /usr/local/bin/start-camera.sh
RUN chmod +x /usr/local/bin/start-camera.sh

# RTSP 8554, HLS 8888, API 9997
EXPOSE 8554 8888 9997

CMD ["/usr/local/bin/start-camera.sh"]
