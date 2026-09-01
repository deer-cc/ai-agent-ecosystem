# AI Agent Ecosystem

> 一套基于 Claude Code 的多 Agent 编排系统 —— 从个人 AI 助手到企业级 Agent 架构的实践
>
> 👤 作者：王文斌 · AI 应用工程师
> 📧 16684299101@163.com
> 💼 GitHub: https://github.com/deer-cc

---

## 一句话

> 独立构建了一套完整的 Multi-Agent LLM 应用系统，涵盖跨平台通信桥接、桌面自动化、本地 RAG 检索、高可用服务治理全链路，具备从协议设计到工程落地的完整 AI 应用开发能力。

## 技术栈

Python · Go · Node.js · TypeScript · MCP · WebSocket · Playwright · FastAPI · pyautogui

---

## 项目概览

本项目展示了一套完整的 **Multi-Agent LLM 应用系统**，包含 6 个核心模块：

| # | 模块 | 技术栈 | 亮点 |
|:--|:-----|:-------|:-----|
| 1 | **Agent 编排系统** | Python · JSON协议 | 规划/执行分离，15个原子Action，监护机制 |
| 2 | **cc-connect 消息桥接** | Go · WebSocket | 飞书/Telegram ↔ Claude Code 双向路由 |
| 3 | **桌面自动化 v2** | Python · Win32 API | 延迟 500ms→50ms，10个HTTP API |
| 4 | **本地 RAG 检索** | Python · 倒排索引 | 完全离线，74个知识节点 |
| 5 | **服务治理** | Python · 指数退避 | 三层架构，5服务全自动守护 |
| 6 | **闲鱼自动客服** | Node.js · LLM | 多轮对话，秒级响应 |
| 7 | **生产级 RAG 引擎 v2** | Python · ChromaDB · TF-IDF | 混合检索，592块/18755词 |

---

## 架构图

```
┌─────────────────────────────────────────────────────────────┐
│                    用户入口层                                │
│  飞书 / Telegram / Claude Code CLI / Web UI / 闲鱼          │
└────────────────────────────┬────────────────────────────────┘
                             │ cc-connect 桥接
┌────────────────────────────▼────────────────────────────────┐
│              Claude Code (大脑层)                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │  叶子    │  │  小鱼    │  │  阿秋    │  ... 领域专家     │
│  │ 规划/判断 │  │  内容    │  │  图片    │                  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘                  │
│       └──────────────┼──────────────┘                       │
│              统一协议分发 (leaf-tian-protocol)                │
└──────────────────────┼──────────────────────────────────────┘
                       │ MCP / HTTP / JSON
┌──────────────────────▼──────────────────────────────────────┐
│                执行层 (Tools & Services)                     │
│  desktop-bridge :8990  │  leaf_api :8899  │  dispatcher    │
│  Playwright MCP      │  Knowledge Search │  飞书推送      │
│  Native DevTools     │  File System      │  cron scheduler│
└─────────────────────────────────────────────────────────────┘
```

---

## 关键技术亮点

### 🧠 Multi-Agent 编排

- **叶子↔小天通信协议**：JSON 指令-回执机制，15个原子Action，11个错误码
- **三级安全边界**：🟢自动执行 / 🟡提前预告 / 🔴需要确认
- **监护系统**：连续100条无回执 或 单条超时30s → SIGTERM 强制终止
- **用户画像自适应**：基于历史决策记录自动调整沟通策略

### 🔗 跨平台通信

- **双通道设计**：WebSocket 长连接 + HTTP 主动推送
- **凭证独享**：解决多进程抢占同一飞书会话的竞态问题
- **Bot中继**：Claude Code ↔ Gemini 跨 Bot 对话
- **延迟 <200ms**，服务可用性 99%+

### 🖥️ 桌面自动化

- **原生 Win32 调用**：去除 PowerShell 中间层
- **10 倍性能提升**：500ms → 50ms
- **原生 UTF-8 中文输入**：解决 GBK 乱码问题
- **紧急停止**：鼠标移到左上角触发 FAILSAFE

### 📚 本地 RAG

- **完全离线**：零外部 API 依赖
- **倒排索引 + 层级权重**：H1-H4 权重评分
- **意图识别矩阵**：4类请求自动路由
- **延迟 <100ms**

### 🛡️ 服务治理

- **三层架构**：guardian（守护）+ dispatcher（消息总线）+ watchdog（看门狗）
- **指数退避重试**：5s / 15s / 30s
- **本地队列持久化**：服务重启后自动补发消息
- **开机自启**：5 个服务全自动守护

---

## 项目目录

| 文件 | 说明 |
|:-----|:-----|
| [ARCHITECTURE/architecture.md](ARCHITECTURE/architecture.md) | 5层架构总览 |
| [ARCHITECTURE/multi-agent.md](ARCHITECTURE/multi-agent.md) | 多 Agent 编排设计 |
| [PROTOCOLS/mcp.md](PROTOCOLS/mcp.md) | MCP 协议集成实践 |
| [PROTOCOLS/leaf-tian-protocol.md](PROTOCOLS/leaf-tian-protocol.md) | 叶子↔小天通信协议 |
| [PROJECTS/01-multi-agent-system.md](PROJECTS/01-multi-agent-system.md) | 项目1：多Agent系统 |
| [PROJECTS/02-cc-connect-bridge.md](PROJECTS/02-cc-connect-bridge.md) | 项目2：跨平台桥接 |
| [PROJECTS/03-desktop-automation.md](PROJECTS/03-desktop-automation.md) | 项目3：桌面自动化v2 |
| [PROJECTS/04-knowledge-base.md](PROJECTS/04-knowledge-base.md) | 项目4：本地RAG检索 |
| [PROJECTS/05-service-governance.md](PROJECTS/05-service-governance.md) | 项目5：服务治理 |
| [PROJECTS/06-rag-engine.md](PROJECTS/06-rag-engine.md) | 项目6：生产级RAG引擎 |
| [RESUME.md](RESUME.md) | 完整简历 |

---

## 环境要求

- Python 3.10+
- Node.js 18+
- Windows 10/11（部分 Linux/macOS 兼容）

---

## 联系

**王文斌** · AI 应用工程师  
📧 16684299101@163.com  
💼 https://github.com/deer-cc

---

*最后更新：2026-08-31*
