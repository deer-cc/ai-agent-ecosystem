# AI Agent Ecosystem

> 一套基于 Claude Code 的多 Agent 编排系统 —— 从个人 AI 助手到企业级 Agent 架构的实践

## 项目概览

本项目展示了一套完整的 **Multi-Agent LLM 应用系统**，涵盖：

| 模块 | 技术栈 | 说明 |
|:-----|:-------|:-----|
| **核心引擎** | Claude Code + MCP | 多模型路由 + 工具调用 |
| **Agent 编排** | Python + JSON 协议 | 叶子（规划）→ 执行器（动作）分离 |
| **通信桥接** | cc-connect (Go) | 飞书/Telegram → LLM 跨平台消息路由 |
| **桌面自动化** | Python pyautogui | HTTP API + Win32 原生调用 |
| **知识检索** | Obsidian + 倒排索引 | RAG 本地知识库 |
| **服务治理** | guardian (Python) | 健康检查 + 自动重启 + 飞书告警 |

## 架构亮点

```
┌─────────────────────────────────────────────────────────────┐
│                    用户入口层                                │
│  飞书 / Telegram / Claude Code CLI / Web UI                 │
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

## 关键技术能力

- **MCP 协议深度运用**：Tools / Resources / Prompts / Sampling / Roots 五层能力
- **Multi-Agent 编排**：叶子（战略预判）→ 执行者（工具调用）分离架构
- **跨平台消息桥接**：cc-connect 实现飞书 ↔ Claude Code 双向通信
- **高可用服务治理**：guardian 守护进程 + 自动重启 + 告警推送
- **本地 RAG 检索**：Obsidian 知识库 + 倒排索引 + 语义搜索
- **桌面自动化**：Python 原生 Win32 调用，无 PowerShell 中间层

## 目录结构

```
github-portfolio/
├── README.md                  ← 你在这里
├── ARCHITECTURE/
│   ├── architecture.md        ← 系统架构总览
│   └── multi-agent.md         ← 多 Agent 编排设计
├── PROTOCOLS/
│   ├── mcp.md                 ← MCP 协议集成实践
│   └── leaf-tian-protocol.md  ← 叶子↔小天通信协议
├── PROJECTS/
│   ├── 01-multi-agent-system.md   ← 项目1：多Agent系统
│   ├── 02-cc-connect-bridge.md    ← 项目2：通信桥接
│   ├── 03-desktop-automation.md   ← 项目3：桌面自动化v2
│   ├── 04-knowledge-base.md       ← 项目4：本地RAG检索
│   └── 05-service-governance.md   ← 项目5：服务治理
└── demos/
    └── (演示脚本和截图)
```

## 环境要求

- Python 3.10+
- Node.js 18+
- Windows 10/11 (部分 Linux/macOS 兼容)

## 许可证

MIT
