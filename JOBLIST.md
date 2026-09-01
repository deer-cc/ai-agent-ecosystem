# 投递行动清单 — AI应用工程师

## 一、投递前的准备（10分钟）

### 1. 注册/登录招聘平台

| 平台 | 优先级 | 链接 |
|:-----|:------:|:-----|
| **Boss直聘** | ⭐⭐⭐ | https://www.zhipin.com |
| **拉勾网** | ⭐⭐⭐ | https://www.lagou.com |
| **脉脉** | ⭐⭐ | https://maimai.cn |
| **智联招聘** | ⭐ | https://www.zhaopin.com |

### 2. 准备简历

- **在线版**：用 [RESUME.md](github-portfolio/RESUME.md) 内容填到招聘平台
- **PDF版**：打开 http://127.0.0.1:8083/resume.html → Ctrl+P → 另存为PDF
- **作品集**：https://github.com/deer-cc/ai-agent-ecosystem
- **RAG项目**：https://github.com/deer-cc/jarvis-rag（新建，需你手动创建+push）

### 3. GitHub仓库状态

| 仓库 | 状态 | 操作 |
|:-----|:----:|:-----|
| ai-agent-ecosystem | ✅ 已推 | 无需操作 |
| jarvis-rag | ⏳ 已commit | **需你手动创建repo+push** |

**jarvis-rag 推送步骤：**
```powershell
# 1. 在GitHub创建新仓库：deer-cc/jarvis-rag
# 2. 然后执行：
cd D:\AI软件\jarvis
git remote add origin https://github.com/deer-cc/jarvis-rag.git
git push -u origin main
```

---

## 二、搜索关键词

在Boss直聘/拉勾搜索以下关键词组合：

**主攻：**
- AI应用工程师
- Agent开发工程师
- 大模型应用工程师
- LLM工程师

**辅助：**
- AI自动化工程师
- MCP开发工程师
- AI工具链工程师

**地点筛选：** 杭州（你在杭州）

---

## 三、投递话术（复制到打招呼框）

```
您好，我对贵司AI应用工程师岗位很感兴趣。

我独立构建了一套多Agent LLM应用系统，包含：
- Multi-Agent编排（叶子↔小天协议，15个原子Action）
- 跨平台通信桥接（飞书/Telegram ↔ Claude Code）
- 生产级RAG检索引擎（TF-IDF混合检索，592知识块）
- 桌面自动化服务（10倍性能优化）
- 三层服务治理架构

GitHub作品集：github.com/deer-cc/ai-agent-ecosystem
RAG项目：github.com/deer-cc/jarvis-rag

2026届计算机应用技术专业应届生，有完整工程落地经验。
附件是我的简历，期待有机会聊聊。
```

---

## 四、投递计划

| 日期 | 目标 | 动作 |
|:-----|:----:|:-----|
| 今天 | 5家 | 注册平台 + 准备简历 + 投5家 |
| 明天 | 10家 | 继续投 + 等回复 |
| 后天 | 10家 | 查漏补缺 + 面试准备 |
| 本周 | 25+家 | 全部投完，开始面试 |

**投递技巧：**
- 每投一家，记录公司名+岗位+链接+投递时间
- 收到面试 → 立刻复习对应项目的讲解
- 被拒 → 问原因，改简历，继续投

---

## 五、面试速查卡（一页A4）

打印或截图保存，面试前快速过一遍：

### 自我介绍（30秒）
> 我叫王文斌，信阳职业技术学院计算机应用技术专业，2026届应届生。
> 独立构建了一套多Agent LLM应用系统，从协议设计到服务治理全链路落地。
> 有MCP工具链、跨平台桥接、桌面自动化、本地RAG的工程经验。
> GitHub上有完整代码和文档。

### 7个项目一句话

| # | 项目 | 核心亮点 |
|:--|:-----|:---------|
| 1 | Multi-Agent编排 | 规划/执行分离，15个Action，监护机制 |
| 2 | cc-connect桥接 | 飞书/Telegram双通道，延迟<200ms |
| 3 | 桌面自动化v2 | 500ms→50ms（10倍），10个HTTP API |
| 4 | 本地RAG | 倒排索引+意图识别，零外部API |
| 5 | 服务治理 | 三层架构，5服务全自动守护 |
| 6 | 闲鱼自动客服 | LLM意图识别，秒级响应 |
| 7 | RAG引擎v2 | TF-IDF混合检索，SSE流式，Docker部署 |

### 高频问题

**Q: 最大的技术挑战是什么？**
> cc-connect的飞书凭证竞态问题——多进程抢同一token互相踢下线。
> 用Go做单实例网关+session key隔离解决。让我理解了分布式系统的状态管理。

**Q: 为什么用TF-IDF不用Embedding？**
> 三个原因：HuggingFace被墙无法下载模型；TF-IDF速度更快（<1ms vs 50ms+）；
> 对中文专业术语关键词匹配反而比语义检索更精确。工程务实选择。

**Q: 没有正式工作经验怎么证明能力？**
> 我的Jarvis生态是跑在服务器24/7的真实系统，不是demo。
> 有完整架构文档、协议规范、服务治理、监控告警。
> GitHub上所有代码和文档都公开可查。

---

*创建时间：2026-09-01*
