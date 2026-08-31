# 项目二：cc-connect 跨平台消息桥接

## 一句话定位

> 将 Claude Code 桥接到飞书/Telegram，实现跨 IM 平台的 AI 助手访问

## 技术栈

Go · WebSocket · JSON-RPC · Windows Services · 定时调度

## 核心架构

```
用户(飞书/Telegram)
      │
      ▼ WebSocket
cc-connect.exe (Go, PID 19488)
      │
      ├─→ Claude Code (stdio子进程)
      │     └─→ Skill执行 → 文件系统/MCP/API
      │
      ├─→ 定时任务 (cron/scheduler)
      │     └─→ 日报/提醒/数据抓取
      │
      └─→ Bot中继 (relay)
            └─→ 与其他Bot对话(Gemini等)
```

## 关键设计

### 1. 双通道分离

| 通道 | 用途 | 端口/方式 |
|:-----|:-----|:---------|
| **飞书 WebSocket** | 消息收发 | cc-connect 独享，凭证 `cli_aa9684ae2738dbc9` |
| **HTTP API** | 主动推送 | `localhost:3800` (dispatcher) |
| **CLI** | 本地交互 | Claude Code terminal |

### 2. 会话管理

```
sessions/ClaudeCode_xxx.json
├── sessions: {飞书会话, Telegram会话}
├── active_session: 当前活跃会话
├── user_sessions: 用户级会话映射
└── context: 跨会话共享上下文
```

### 3. 调度系统

- **cron**: 标准 5 段式 cron 表达式，支持周期任务
- **timer**: 一次性延迟触发，自动删除
- 两种模式均支持 `--exec`（直接命令）或 `--prompt`（让LLM处理）

### 4. 跨设备上下文桥

`D:\AI软件\.shared-context.json` — 终端与飞书双向读写共享状态：
```json
{
  "last_session_update": "2026-08-30T20:09:00",
  "pending": "",
  "active_session": "",
  "recent_activity": []
}
```

## 遇到的问题与解决

| 问题 | 根因 | 解决方案 |
|:-----|:-----|:---------|
| 飞书 bot 抢会话 | cc-connect 和 feishu-bot 共用同一凭证 | 删除 feishu-bot，cc-connect 独享 |
| watchdog 拉锯战 | watchdog 每15分钟杀 bot 又重启 cc-connect | FEISHU_BOT_ALLOWED=False，只杀不重启 |
| monitor.bat 循环重启 | monitor.bat 每分钟检查3789端口 | 已禁用 monitor.bat |
| 启动文件夹残留 | FeishuBot.lnk 开机自启 | 已删除 |

## 成果数据

- **支持平台**：飞书、Telegram
- **会话持久化**：JSON 文件，支持重启恢复
- **调度任务**：cron + timer 双模式
- **Bot中继**：支持跨Bot对话（如 Gemini relay）
- **消息类型**：文本 / 图片 / 文件 / 语音（TTS）

## 与简历的结合

**项目描述（企业语言）：**
> 构建了一套跨 IM 平台的 LLM 通信桥接系统（cc-connect），
> 实现了飞书/Telegram 与 Claude Code 的双向消息路由。
> 系统支持 WebSocket 长连接、HTTP 主动推送、定时任务调度、
> 跨Bot中继通信，解决了多进程抢占会话信道的稳定性问题。

**面试亮点：**
- 跨平台消息路由架构设计
- 进程竞态问题的诊断与修复
- WebSocket 长连接 + HTTP 短连接的混合通信模式
- 定时任务系统的调度设计
