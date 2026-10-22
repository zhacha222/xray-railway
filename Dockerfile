FROM alpine:3.20

ARG XRAY_VERSION=v26.3.27
RUN apk add --no-cache curl unzip ca-certificates bash \
 && ARCH=$(uname -m) \
 && case "$ARCH" in \
      x86_64)  XZ="64"  ;; \
      aarch64) XZ="arm64-v8a" ;; \
      *) echo "unsupported arch $ARCH"; exit 1 ;; \
    esac \
 && ( curl -fsSL -o /tmp/xray.zip \
        "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-${XZ}.zip" \
      || curl -fsSL -o /tmp/xray.zip \
        "https://gh-proxy.com/https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-${XZ}.zip" ) \
 && mkdir -p /opt/xray \
 && unzip -o /tmp/xray.zip -d /opt/xray \
 && rm -f /tmp/xray.zip \
 && chmod +x /opt/xray/xray \
 && /opt/xray/xray version

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Railway 通过 PORT 环境变量注入监听端口，并做 TLS 终止
ENV XRAY_PORT=8080
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
