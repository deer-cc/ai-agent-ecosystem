# 项目六：手机↔智能体通讯桥

## 一句话定位

> 跨设备上下文桥：终端 ↔ 飞书，实现消息主动推送 + 会话状态共享

## 技术栈

Python · JSON文件 · cc-connect · 飞书WebSocket

## 架构设计

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│    手机飞书      │ ←──────→ │   cc-connect     │ ←──────→ │    Claude Code  │
│   (你/用户)     │   WS    │   (飞书桥接层)    │   stdio │   (小天/叶子)   │
└────────┬────────┘         └────────┬─────────┘         └────────┬────────┘
         │                           │                            │
         │                           │                            │
         ▼                           ▼                            ▼
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│  Dispatcher     │         │  .shared-context │         │  guardian/     │
│  (:3800)        │ ←──────→ │  .json           │ ←──────→ │  night-intel   │
│  REST API推送   │         │  双向状态文件     │         │  各子系统       │
└─────────────────┘         └──────────────────┘         └─────────────────┘
```

## 核心机制：A+B 双层通讯

### A. 主动推送（cc-connect send）

```powershell
# 语法
cc-connect send -p "ClaudeCode" -m "消息内容"
cc-connect send -p "ClaudeCode" --file "文件路径" -m "简要说明"
```

**触发场景：**
- 耗时任务完成通知
- 异常告警（guardian服务发现异常）
- 日报/周报推送（night-intel每日情报）
- 跨设备交接（手机端发起，PC端完成）

**重要约束：**
> `send` 仅在飞书有活跃 WebSocket 会话时成功。如果用户当前没在和机器人对话，推送会失败——等用户下次发消息时，B方案的共享状态文件已包含错过的信息。

### B. 跨设备上下文桥（shared-context.json）

**文件位置：** `D:\AI软件\.shared-context.json`

```json
{
  "last_session_update": "2026-09-01T15:22:00",
  "pending": "",
  "active_session": "s11",
  "active_task": "",
  "recent_activity": ["RAG项目讨论", "飞书推送配置"],
  "last_session_checklist": {
    "completed_at": "2026-09-01T09:00:04",
    "stale_memories": 22,
    "doctrine_age_days": 17
  }
}
```

**读写协议：**
- **终端侧（我）**：每次会话结束时更新 last_session_update、recent_activity、pending
- **手机侧（用户）**：每次飞书消息进来时读取 last_session_update，判断是否需要注入上下文

**推送+桥的组合逻辑：**
```
1. 终端有重要变更 → 写 .shared-context.json
2. 如果飞书有活跃会话 → dispatcher推送摘要
3. 无论推送是否送达 → 下次飞书消息都会读到桥文件中的上下文
```

## Dispatcher 集成

Dispatcher (:3800) 作为统一推送出口，复用飞书 REST API（不抢 cc-connect WebSocket 会话）：

```json
// POST /dispatch
{
  "type": "text|card|image|file",
  "target": "ou_xxx",           // 飞书open_id
  "content": "消息内容",
  "service": "guardian|night-intel|leaf_api",
  "error_key": "alert_name"      // 用于去重节流
}
```

**能力：**
- 去重：同一 target+type+content 5分钟内只发一次
- 节流：同一 service 的同一 error_key 5分钟内最多1条
- 重试：失败后指数退避 3次（5s/15s/30s）
- 队列持久化：dispatcher_queue.json，重启后补发

## 已接入的推送源

| 来源 | 类型 | 触发条件 | 频率 |
|:-----|:----:|:---------|:-----|
| **guardian** | alert | 服务连续3次健康检查失败 | 按需 |
| **night-intel** | card | 每日凌晨2点自动运行 | 每日1次 |
| **leaf_api** | text | 周报/复盘完成 | 按需 |

## 与简历的结合

**项目描述（企业语言）：**
> 设计了跨设备通讯桥接系统，实现终端↔飞书的双向消息路由。采用"主动推送+共享状态文件"双层架构，保证消息不丢失、上下文不中断。基于 cc-connect 的 REST API 推送通道替代 WebSocket 直连，避免多进程抢占会话信道的竞态问题。

**面试亮点：**
- 双层通讯架构设计（实时推送 + 异步状态同步）
- 飞书凭证独享与多进程竞态问题的解决
- 消息去重/节流/重试算法的工程化实现

## 常见问题

### Q1: cc-connect send 和 dispatcher 有什么区别？

| 维度 | cc-connect send | dispatcher |
|:-----|:----------------|:-----------|
| 通信方式 | WebSocket（双向） | REST API（单向HTTP） |
| 依赖 | 需要活跃会话 | 不需要 |
| 凭证 | 复用 cc-connect | 独立 app_access_token |
| 适用场景 | 即时交互回复 | 后台任务推送 |
| 推荐用法 | 用户提问时的实时回复 | 守护告警/日报/定时推送 |

### Q2: 如何测试推送通道？

```powershell
# 1. 检查dispatcher健康
Invoke-WebRequest http://localhost:3800/health

# 2. 发送测试消息
$body = '{"type":"text","target":"ou_xxx","content":"测试消息","service":"test"}'
Invoke-WebRequest -Uri http://localhost:3800/dispatch -Method POST -Body $body

# 3. 查看日志
Get-Content D:\AI软件\feishu-bot\dispatcher.log -Tail 5
```

### Q3: 推送失败怎么办？

```
症状：飞书收不到消息
排查步骤：
1. 检查 dispatcher 是否运行：netstat -ano | findstr :3800
2. 检查 .env 凭证是否正确：cat D:\AI软件\feishu-bot\.env
3. 检查飞书应用权限：飞书开发者后台 → 权限管理
4. 查看 dispatcher.log 错误详情
```

---

*项目状态：已完成 | 更新时间：2026-09-01*
