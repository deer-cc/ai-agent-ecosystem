# 项目五：服务治理与高可用架构

## 一句话定位

> 守护进程 + 消息总线 + 看门狗，构建从监控到告警的完整服务治理体系

## 技术栈

Python · JSON · Windows 计划任务 · HTTP Server · 飞书推送

## 三层架构

```
┌─────────────────────────────────────────────────────────┐
│  Layer 3: 告警推送层 (dispatcher)                        │
│  :3800 · 去重·节流·重试·队列持久化·飞书推送               │
└────────────────────────┬────────────────────────────────┘
                         │ POST /dispatch
┌────────────────────────▼────────────────────────────────┐
│  Layer 2: 守护进程层 (guardian)                          │
│  :60s巡检 · 连续3次失败重启 · 日报推送 · 历史清理         │
└────────────────────────┬────────────────────────────────┘
                         │ 进程管理
┌────────────────────────▼────────────────────────────────┐
│  Layer 1: 被守护服务                                    │
│  web_server(:5173) · jarvis_main(:8080) · v9_server(:8082)│
│  desktop_bridge(:8990) · leaf_api(:8899) · dispatcher(:3800)│
└─────────────────────────────────────────────────────────┘
```

## guardian.py 核心逻辑

```python
def main():
    config = load_config()
    history = load_history()
    consecutive_failures = defaultdict(int)

    while True:
        for svc in config["services"]:
            ok, detail = check_service(svc)

            if ok:
                consecutive_failures[name] = 0
                states[name] = {"status": "running", ...}
            else:
                consecutive_failures[name] += 1
                if consecutive_failures[name] >= 3:
                    # 触发告警
                    send_feishu_alert(f"🔴 {name} 异常: {detail}")
                    # 自动重启
                    restart_service(svc)
                    save_history(history)

        time.sleep(60)
```

## dispatcher.js 核心能力

```javascript
// 去重：同一 target+type+content 5分钟内只发一次
function checkDedup(target, type, content) { ... }

// 节流：同一 service 的同一 error_key 5分钟内最多1条
function checkThrottle(service, error_key) { ... }

// 重试：失败后指数退避 3 次（5s/15s/30s）
async function sendWithRetry(message, retries = 0) { ... }

// 队列持久化：dispatcher_queue.json，重启后补发
function saveQueue() { ... }
```

## watchdog_cc_connect.py 核心能力

- 会话文件大小检测（阈值 2MB）
- cc-connect 进程存活检查
- feishu-bot 状态检测（已禁用，不再管理）
- MCP 服务健康检查

## 启动顺序（开机自启）

```
1. cc-connect.exe        — 飞书桥接（Windows Services）
2. leaf_api (:8899)      — 叶子 REST API
3. desktop-bridge (:8990)— 桌面控制
4. dispatcher (:3800)    — 告警推送
5. guardian              — 守护所有服务
```

## 配置文件

```json
// jarvis/guardian/config.json
{
  "check_interval_seconds": 60,
  "consecutive_failures_before_alert": 3,
  "alert_cooldown_minutes": 10,
  "services": [
    { "name": "web_server",   "port": 5173,  "enabled": true },
    { "name": "jarvis_main",  "port": 8080,  "enabled": true },
    { "name": "v9_server",    "port": 8082,  "enabled": true },
    { "name": "desktop_bridge","port": 8990, "enabled": true },
    { "name": "leaf_api",     "port": 8899,  "enabled": true }
  ]
}
```

## 与简历的结合

**项目描述（企业语言）：**
> 设计了三层服务治理架构：守护进程（健康巡检+自动重启）+ 消息总线（去重/节流/重试）
> + 看门狗（进程存活检测）。实现了 5 个服务的开机自启和异常自动恢复，
> 告警通过 dispatcher 推送到飞书，支持队列持久化和重启补发。

**面试亮点：**
- 微服务治理的完整实践（监控→告警→自愈）
- 消息总线的核心算法（去重/节流/指数退避重试）
- 配置驱动的服务管理（JSON 配置热更新）
- 进程竞态问题的系统性解决
