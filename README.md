# 王文斌 · 项目文档集

> 这里放的是项目**过程文档**：架构思路、排障记录、评估方法。
> **能跑的代码在 [cckefu](https://github.com/deer-cc/cckefu)。**
>
> 求职方向：AI 应用交付工程师（FDE）/ 大模型平台实施 / AI 应用开发 / 技术助理
> 📧 16684299101@163.com

---

## 有代码、可运行的仓库

| 项目 | 仓库 | 说明 |
|:--|:--|:--|
| 智能客服引擎 | **[cckefu](https://github.com/deer-cc/cckefu)** | Python · FastAPI · 意图识别 · RAG 检索 · 多轮对话<br>68 个测试全绿 / Docker / GitHub Actions / 内嵌演示页 |

---

## 本仓库记录了什么

做过的项目在过程中留下的文档——**不是产品代码，是"怎么想、怎么试、怎么修"的记录**。

| 文档 | 内容 | 状态 |
|:--|:--|:--|
| `PROJECTS/07-customer-service-engine.md` | 智能客服引擎的设计与排障记录 | ✅ 代码见 cckefu |
| `PROJECTS/06-rag-engine.md`<br>`PROJECTS/RAG知识检索系统.md` | 本地 RAG 检索引擎：TF-IDF + 图扩展 + 向量三路召回，592 块 | ✅ 自用 |
| `PROJECTS/06-phone-bridge.md` | 手机 ↔ 终端消息桥接 | ✅ 自用 |
| `PROJECTS/02-cc-connect-bridge.md` | 消息桥接的接入与配置 | ✅ 使用第三方 Go 工具 |
| `PROJECTS/05-service-governance.md` | 多服务守护与消息补发 | ✅ 自用 |
| `PROJECTS/04-knowledge-base.md` | 知识库结构与检索设计 | ✅ 自用 |
| `PROJECTS/03-desktop-automation.md` | 桌面自动化——**自研方案的过程记录** | ⚠️ 已弃用，改用现成 MCP 工具 |
| `archive/` | 早期设计（含已废弃的"双模式"架构） | 🗄️ 存档，不代表现状 |

> **说明**：本仓库早期文档中提到的"双模式 Multi-Agent 系统""桌面自动化 v2 性能优化"等设计，
> 后续已被更简单的方案替代（单一 Agent + 成熟 MCP 工具）。相关文档移入 `archive/` 保留过程，
> **技术上以本 README 的现状表为准**。

---

## 技术栈（实际用过的）

**熟练**：Python（FastAPI / pytest）· Git · Docker · Windows 环境排查 · MCP 协议 · Linux / WSL 服务部署

**用过**：Node.js · ChromaDB · TF-IDF 与倒排索引 · Playwright MCP · Go 工具（cc-connect，第三方，仅使用）

---

## 我在这些项目里收获的方法

1. **先看日志再动手**——不靠重启碰运气。闪退先查进程，服务起不来先看启动日志，接口不通先分清楚是鉴权还是网络。
2. **改之前先备份，改完必须验证**——尤其是配置和构建产物，改错要能退回去。
3. **能直接用成熟方案就不自己造**——桌面自动化自研了一版，维护成本高于收益，后来换成了现成的 MCP 服务，一次配置替代大量代码。
4. **数字要有出处**——评估集、脚本、复跑命令都留着，被追问时能当场复现。

---

## 联系

**王文斌** · 2026 届 · 现居武汉
📧 16684299101@163.com
💼 https://github.com/deer-cc

---

*最后更新：2026-10-28（清理过时内容：移除已废弃的双模式架构描述与未实际使用的技术栈标注，数字与现状对齐）*
