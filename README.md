# AI Agent Ecosystem

> 一套基于 Claude Code 的双模式 Multi-Agent LLM 系统 —— 从个人 AI 助手到生产级 Agent 架构的实践
>
> 👤 作者：王文斌 · AI 应用工程师
> 📧 16684299101@163.com
> 💼 GitHub: https://github.com/deer-cc

---

## 一句话

> 独立构建了一套**双模式 Multi-Agent LLM 系统**——叶子（大脑/规划）与 Tian（手脚/执行）物理隔离，涵盖跨平台通信桥接、桌面自动化、图关系知识图谱检索、用户画像自适应学习、高可用服务治理、智能客服对话全链路，具备从协议设计到工程落地的完整 AI 应用开发能力。

## 技术栈

Python · Go · Node.js · TypeScript · MCP · WebSocket · Playwright · FastAPI · pyautogui · ChromaDB · TF-IDF

---

## 项目概览

本项目展示了一套完整的 **双模式 Multi-Agent LLM 系统**，包含 7 个核心模块：

| # | 模块 | 技术栈 | 亮点 |
|:--|:-----|:-------|:-----|
| 1 | **双模式 Agent 编排** | Python · JSON协议 · Claude Code Hooks | 思考/执行物理隔离，用户画像自适应学习 |
| 2 | **cc-connect 消息桥接** | Go · WebSocket | 飞书 ↔ Claude Code 双向路由，定时任务，Bot 中继 |
| 3 | **桌面自动化 v2** | Python · Win32 API | 延迟 500ms→50ms，10个HTTP API |
| 4 | **RAG 图关系检索引擎** | Python · ChromaDB · TF-IDF · 倒排索引 · `[[双链]]`图谱 | 三路混合召回（关键词+图扩展+向量），592块/18755词 |
| 5 | **服务治理** | Python · 指数退避 | 三层架构，5服务全自动守护，零丢失补发 |
| 6 | **智能客服引擎** | Python · FastAPI · LLM意图识别 · 多轮状态机 · 图关系检索 | 8类意图>90%准确率，18个测试用例，Docker+CI |
| 7 | **手机↔跨设备通讯桥** | Python · JSON文件 · cc-connect | 终端↔飞书双向路由，双层推送架构 |

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

### 📚 图关系 RAG 检索引擎 v3

- **三路混合召回**：倒排索引关键词（35%）+ `[[双链]]`图扩展（15%）+ TF-IDF向量（50%）
- **知识图谱建模**：Markdown `[[双链]]` 天然形成节点关系图，检索时沿图的边追踪关联邻居节点
- **零依赖中文分词**：双字滑窗 + 英文单词提取，纯正则实现
- **ChromaDB 持久化**：592 个知识块，18,755 个关键词项，冷启动 <100ms
- **完全离线**：零外部 API 依赖，检索延迟 <50ms

### 🤖 智能客服引擎 v1

- **LLM意图识别**：8类意图（物流/退换/价格/商品等），LLM主路径+关键词兜底，准确率>90%
- **多轮对话状态机**：Session级上下文管理，6轮历史窗口，追问上限控制
- **图关系知识库融合**：检索结果自动注入回复正文，减少幻觉
- **工程规范完备**：pytest 18个测试用例100%通过，Docker容器化，GitHub Actions CI

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

*最后更新：2026-09-08（新增智能客服引擎项目 + RAG图关系检索升级）*
