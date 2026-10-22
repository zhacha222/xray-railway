#!/bin/bash
# xray VLESS + WebSocket 服务端
# 由 Railway 环境变量驱动，TLS 由 Railway 边缘终止（*.up.railway.app 自带证书）
set -e

PORT="${PORT:-8080}"
UUID="${UUID:-}"
WSPATH="${WSPATH:-/ws}"

if [ -z "$UUID" ]; then
  echo "[entrypoint] UUID 未设置，生成临时 UUID"
  UUID="$(cat /proc/sys/kernel/random/uuid)"
fi

# WSPATH 规范化：确保以 / 开头
case "$WSPATH" in
  /*) ;;
  *) WSPATH="/$WSPATH" ;;
esac

echo "[entrypoint] listening on 0.0.0.0:${PORT}, path=${WSPATH}"

cat > /opt/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${PORT},
      "protocol": "vless",
      "settings": {
        "clients": [
          { "id": "${UUID}", "level": 0 }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "${WSPATH}" }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"],
        "routeOnly": false
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct" },
    { "protocol": "blackhole", "tag": "block" }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "ip": ["geoip:private"],
        "outboundTag": "block"
      },
      {
        "type": "field",
        "protocol": ["bittorrent"],
        "outboundTag": "block"
      }
    ]
  }
}
EOF

exec /opt/xray/xray run -config /opt/xray/config.json
