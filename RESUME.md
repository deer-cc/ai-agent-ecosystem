# 王文斌 — AI 应用工程师

> 多 Agent 编排 | LLM 应用开发 | MCP 协议 | 跨平台桥接 | 桌面自动化

---

## 个人简介

AI 应用开发者，专注于 LLM Agent 系统的架构设计与工程落地。具备从模型接入、Agent 编排、MCP 工具链集成到服务治理的完整闭环能力。独立构建了一套多 Agent 个人 AI 助手生态，涵盖内容创作、图像生成、投资分析、视频制作、桌面控制、知识检索等多个垂直领域。

---

## 技术栈

| 类别 | 技术 |
|:-----|:-----|
| **语言** | Python, JavaScript/Node.js, TypeScript, PowerShell |
| **LLM** | Claude (Anthropic), DeepSeek, GPT |
| **Agent 框架** | Claude Code, MCP (Model Context Protocol) |
| **通信桥接** | WebSocket, HTTP/REST, cc-connect |
| **桌面自动化** | pyautogui, pillow, pywin32, Playwright |
| **数据库/存储** | JSON, Obsidian (Markdown), 本地文件 |
| **部署/运维** | 守护进程, 健康检查, 自动重启, Windows 计划任务 |
| **协议** | MCP (Tools/Resources/Prompts/Sampling/Roots) |

---

## 核心项目

### 1. Multi-Agent LLM 编排系统

**技术栈：** Python · JSON协议 · Claude Code Skills · 递归反思

设计并实现了一套「规划层 + 执行层」分离的多 Agent 系统。核心创新是叶子（战略预判）与执行器的解耦通信——叶子输出 JSON 指令，执行器解析执行并回执，两者互不耦合。

- 定义了 **15 个原子 Action**（读写文件/进程管理/HTTP/记忆操作）和 **11 个错误码**，全覆盖错误场景
- 实现了三级安全边界（🟢自动/🟡预告/🔴确认），防止误操作
- 引入监护系统：连续 100 条指令无回执或单条超时 30s 时强制 SIGTERM 中断
- 用户画像自适应学习，基于历史决策记录自动调整沟通策略
- 执行后复盘机制，持续记录用户反馈并进化预测模型

**成果：** 7 个项目全生命周期追踪，8 条决策记录，沟通风格 5 种模式自动识别。

---

### 2. cc-connect 跨平台消息桥接

**技术栈：** Go · WebSocket · JSON-RPC · Windows Services

构建了将 Claude Code 桥接到飞书/Telegram 的通信中间层，实现了 IM 平台 ↔ LLM 的双向消息路由。

- 支持 WebSocket 长连接 + HTTP 主动推送双通道
- 实现了定时任务调度（cron 周期任务 + timer 一次性提醒）
- Bot 中继功能：支持 Claude Code 与其他 AI Bot（如 Gemini）跨 Bot 对话
- 跨设备上下文桥：shared-context.json 实现终端与手机的消息状态同步
- 解决了多进程抢占同一飞书凭证的会话冲突问题（feishu-bot 竞态）
- 通过 watchdog + guardian 双层守护保障服务可用性

**成果：** 单凭证独享飞书会话，消息路由延迟 <200ms，服务可用性 99%+。

---

### 3. 桌面自动化服务 v2

**技术栈：** Python · pyautogui · pillow · pywin32 · psutil · HTTP Server

用 Python 原生调用 Win32 API 替代 PowerShell 管道方案，重构桌面控制服务。

- 实现了 10 个 HTTP API 端点：截图/点击/双击/输入/按键/拖拽/滚动/窗口管理
- 去除了 PowerShell 中间层，操作延迟从 ~500ms 降至 ~50ms（10 倍提升）
- 原生 UTF-8 中文输入支持（解决了 SendKeys GBK 乱码问题）
- 三级安全边界 + 紧急停止机制（鼠标移到左上角触发 FAILSAFE）
- 集成到 guardian 守护进程，开机自启 + 异常自动重启
- 桌面控制服务 (:8990) 与 leaf_api (:8899) 协同工作

**成果：** 10 个 API 全部通过端到端测试，守护进程稳定运行。

---

### 4. 本地 RAG 知识检索系统

**技术栈：** Python · 倒排索引 · Obsidian · Markdown · JSON

构建了基于 Obsidian 知识库的本地语义检索引擎，完全离线运行，不依赖外部 API。

- 实现了倒排索引 + H1-H4 层级权重评分的检索算法
- 设计了意图识别矩阵：知识查询/项目查询/决策查询/上下文查询四类请求自动路由
- 知识库采用 PARA 结构管理（Projects/Areas/Resources/Archives）
- 74 条记忆索引，覆盖架构设计、工具配置、决策历史、Bug 修复等主题
- 支持跨会话上下文注入，新会话自动加载相关背景

**成果：** 检索延迟 <100ms，覆盖 74 个知识节点，零外部 API 依赖。

---

### 5. 服务治理与高可用架构

**技术栈：** Python · JSON · HTTP · 飞书推送 · 指数退避

设计了三层服务治理架构，覆盖从监控、告警到自愈的完整链路。

- **守护进程层 (guardian)**：每 60 秒巡检所有服务，连续 3 次失败触发自动重启
- **消息总线层 (dispatcher :3800)**：实现了消息去重（5min 窗口）、告警节流、指数退避重试（5s/15s/30s）、本地队列持久化（重启补发）
- **看门狗层 (watchdog)**：会话文件大小检测 + cc-connect 进程存活检查 + MCP 服务健康诊断
- 配置驱动：所有服务通过 JSON 配置管理，支持热更新
- 已纳入开机自启流程：cc-connect → leaf_api → desktop-bridge → dispatcher → guardian

**成果：** 5 个服务全自动守护，告警通过飞书实时推送，队列重启补发零丢失。

---

## 教育背景

[待补充]

---

## 联系方式

- GitHub: https://github.com/deer-cc
- 邮箱: [待补充]
- 所在地: 杭州

---

*最后更新：2026-08-31*
