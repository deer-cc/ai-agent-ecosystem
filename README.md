# AI Agent Ecosystem

> 一套基于 Claude Code 的双模式 Multi-Agent LLM 系统 —— 从个人 AI 助手到生产级 Agent 架构的实践
>
> 👤 作者：王文斌 · AI 应用工程师
> 📧 16684299101@163.com
> 💼 GitHub: https://github.com/deer-cc

---

## 一句话

> 独立构建了一套**双模式 Multi-Agent LLM 系统**——叶子（大脑/规划）与 Tian（手脚/执行）物理隔离，涵盖跨平台通信桥接、桌面自动化、本地 RAG 检索、用户画像自适应学习、高可用服务治理全链路，具备从协议设计到工程落地的完整 AI 应用开发能力。

## 技术栈

Python · Go · Node.js · TypeScript · MCP · WebSocket · Playwright · FastAPI · pyautogui · ChromaDB · TF-IDF

---

## 项目概览

本项目展示了一套完整的 **双模式 Multi-Agent LLM 系统**，包含 6 个核心模块：

| # | 模块 | 技术栈 | 亮点 |
|:--|:-----|:-------|:-----|
| 1 | **双模式 Agent 编排** | Python · JSON协议 · Claude Code Hooks | 思考/执行物理隔离，用户画像自适应学习 |
| 2 | **cc-connect 消息桥接** | Go · WebSocket | 飞书 ↔ Claude Code 双向路由，定时任务，Bot 中继 |
| 3 | **桌面自动化 v2** | Python · Win32 API | 延迟 500ms→50ms，10个HTTP API |
| 4 | **RAG 检索引擎 v2** | Python · ChromaDB · TF-IDF · 倒排索引 | 混合检索，592块/18755词，<50ms |
| 5 | **服务治理** | Python · 指数退避 | 三层架构，5服务全自动守护，零丢失补发 |
| 6 | **闲鱼自动客服** | Node.js · LLM | 多轮对话，秒级响应，自主运营 |

---

## 架构全貌

```
┌─────────────────────────────────────────────────────────────┐
│                    用户入口层                                │
│  飞书 / Telegram / Claude Code CLI / Web UI                 │
└────────────────────────────┬────────────────────────────────┘
                             │ cc-connect 桥接
┌────────────────────────────▼────────────────────────────────┐
│              Claude Code（叶子·大脑层）                       │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  双模式：思考规划(默认) ←→ 执行落地(确认后)            │    │
│  │  • 思考模式：Read/Glob/WebFetch 允许，Bash/Write 拒绝 │    │
│  │  • 执行模式：全部工具放行                              │    │
│  │  • 用户画像自动加载 + 进化学习                          │    │
│  └─────────────────────────────────────────────────────┘    │
│              统一协议分发 (leaf-tian-protocol)                │
└──────────────────────┬──────────────────────────────────────┘
                       │ MCP / HTTP / JSON
┌──────────────────────▼──────────────────────────────────────┐
│                执行层 (Tian + Tools & Services)              │
│  Tian Executor :9000  │  Desktop Bridge :8990  │  Leaf API :9889  │
│  dispatcher :3800    │  RAG Engine            │  Watchdog       │
│  飞书推送            │  cron scheduler        │  5服务守护      │
└─────────────────────────────────────────────────────────────┘
```

---

## 关键技术亮点

### 🧠 双模式 Agent 编排（v3 强化版）

- **叶子↔小天物理隔离**：思考模式禁用 Bash/Write/PowerShell（PreToolUse 钩子硬拦截），确认后切换到执行模式
- **15 个原子 Action**：read_file/list_dir/write_file/exec_command/http_get/http_post/get_process/kill_process/delete_file/read_memory/write_memory
- **11 个错误码**：PATH_PROTECTED / EXEC_TIMEOUT / ACTION_NOT_FOUND / MISSING_PARAM / PERMISSION_DENIED / NET_ERROR 等
- **监护系统**：连续 100 条无回执或单条超时 30s → SIGTERM 强制终止
- **用户画像进化**：`session_evolution.py` 扫描历史会话，自动提取沟通风格、决策偏好、行为模式
- **闭环学习**：新会话加载画像 → 交互 → 会话后自动学习 → 下次更懂你

### 🔗 跨平台通信桥接

- **cc-connect 桥接**：Go 二进制，支持飞书/Telegram/DingTalk/Slack/Discord/LINE
- **双通道设计**：WebSocket 长连接 + HTTP 主动推送
- **定时任务调度**：cron 周期任务 + timer 一次性提醒
- **Bot 中继**：Claude Code ↔ Gemini 跨 Bot 对话
- **附件传输**：图片/音频/视频/Excel 等文件双向传输（17 个媒体文件已验证）
- **延迟 <200ms**，服务可用性 99%+

### 🖥️ 桌面自动化 v2

- **原生 Win32 调用**：去除 PowerShell 中间层
- **10 倍性能提升**：500ms → 50ms
- **原生 UTF-8 中文输入**：解决 GBK 乱码问题
- **10 个 HTTP API**：截图/点击/双击/输入/按键/拖拽/滚动/窗口管理
- **紧急停止**：鼠标移到左上角触发 FAILSAFE

### 📚 生产级 RAG 引擎 v2

- **双路召回**：倒排索引关键词匹配（35%）+ TF-IDF 向量相似度（65%）
- **零依赖中文分词**：双字滑窗 + 英文单词提取，纯正则实现
- **ChromaDB 持久化**：592 个知识块，18,755 个关键词项
- **毫秒级热加载**：服务重启 <100ms 恢复
- **意图识别矩阵**：知识查询/项目查询/决策查询/上下文查询四类自动路由
- **完全离线**：零外部 API 依赖

### 🛡️ 服务治理

- **三层架构**：guardian（守护）+ dispatcher（消息总线）+ watchdog（看门狗）
- **指数退避重试**：5s / 15s / 30s
- **本地队列持久化**：服务重启后自动补发消息，零丢失
- **5 个服务全自动守护**：cc-connect → leaf_api → desktop-bridge → dispatcher → guardian
- **开机自启**：全部纳入系统启动流程

---

## 联系

**王文斌** · AI 应用工程师  
📧 16684299101@163.com  
💼 https://github.com/deer-cc

---

*最后更新：2026-09-03*
