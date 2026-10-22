# xray-railway

极简 xray-core 镜像，用于在 Railway 上部署 **VLESS + WebSocket + TLS** 节点。

## 工作原理

- 基于 `alpine` + 官方 [XTLS/Xray-core](https://github.com/XTLS/Xray-core) release 静态二进制
- 容器内监听 Railway 注入的 `PORT`，暴露 **VLESS over WebSocket**
- **TLS 由 Railway 边缘自动终止**：`*.up.railway.app` 自带有效证书，无需自签
- 配置完全由环境变量驱动，无需改代码即可多节点部署

## 环境变量

| 变量 | 必填 | 说明 |
| :--- | :--- | :--- |
| `PORT` | 否 | Railway 自动注入，容器监听端口（默认 `8080`） |
| `UUID` | 是 | VLESS 用户 UUID |
| `WSPATH` | 否 | WebSocket 路径（默认 `/ws`） |

## 部署要点

1. 在 Railway 项目里新建 service，源选本仓库
2. 设置 `UUID`（和可选 `WSPATH`）
3. 生成域名（Settings → Networking → Generate Domain）
4. 客户端配置：
   - 地址：`<生成的域名>`
   - 端口：`443`
   - 协议：`vless`
   - 传输：`ws`
   - 路径：`$WSPATH`
   - TLS：开（SNI 同域名）

## 安全策略

- 阻断 `geoip:private`（防内网探测/SSRF 中转）
- 阻断 BitTorrent 协议
