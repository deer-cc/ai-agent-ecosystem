# 项目四：本地 RAG 知识检索系统

## 一句话定位

> 基于 Obsidian 知识库 + 倒排索引的本地语义检索，不依赖外部 API

## 技术栈

Python · Obsidian · 倒排索引 · Markdown · JSON

## 系统架构

```
┌─────────────────────────────────────────────┐
│  D:\AI软件\叶子知识库\                        │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐       │
│  │00_Inbox │ │01_Projects│ │02_Areas │       │
│  │03_Areas │ │04_Resources││05_Daily│       │
│  └────┬────┘ └────┬────┘ └────┬────┘       │
│       └────────────┼────────────┘            │
│                    ▼                          │
│           search.js / search.py               │
│        (倒排索引 + 语义匹配)                   │
│                    ▼                          │
│           返回相关笔记 + 相似度评分             │
└─────────────────────────────────────────────┘
```

## 关键技术

### 1. 倒排索引

```python
# 核心数据结构
inverted_index = {
    "叶子": ["memory/叶子核心能力.md", "memory/叶子身份架构升级.md"],
    "MCP": ["memory/mcp-protocol-depth.md"],
    "飞书": ["memory/cc-connect-infrastructure.md", "memory/feishu-channel-restored.md"],
}

def search(query: str) -> List[Dict]:
    tokens = tokenize(query)
    results = []
    for token in tokens:
        if token in inverted_index:
            for doc_path in inverted_index[token]:
                score = compute_relevance(doc_path, query)
                results.append({"path": doc_path, "score": score})
    return sorted(results, key=lambda x: -x["score"])[:10]
```

### 2. H1-H4 硬规则

检索策略遵循层级优先原则：
- H1（标题）权重最高
- H2（章节）次之
- H3/H4（子节）辅助
- 元数据（frontmatter）参与评分

### 3. 意图识别矩阵

| 查询类型 | 触发关键词 | 检索策略 |
|:---------|:-----------|:---------|
| 知识查询 | "怎么"、"如何"、"是什么" | 精确匹配 + 倒排索引 |
| 项目查询 | "项目"、"进度"、"状态" | 文件路径过滤 + 状态解析 |
| 决策查询 | "为什么"、"记得吗" | 决策日志 + 方向变更记录 |
| 上下文查询 | "上次"、"之前"、"记得" | shared-context + 最近快照 |

## 数据集

- **知识库路径**：`D:\AI软件\叶子知识库\`
- **PARA 结构**：Projects / Areas / Resources / Archives
- **笔记数量**：74 条记忆索引，覆盖架构/工具/决策/历史
- **格式**：Markdown + YAML frontmatter

## 与简历的结合

**项目描述（企业语言）：**
> 构建了基于 Obsidian 的本地 RAG 知识库系统，实现了倒排索引 + 意图识别矩阵。
> 支持 H1-H4 层级权重检索，可处理知识查询/项目查询/决策查询/上下文查询四类意图。
> 系统完全本地运行，不依赖外部 API，保障数据隐私。

**面试亮点：**
- RAG 系统的本地化实现（无外部依赖）
- 倒排索引的数据结构设计
- 意图识别矩阵的工程化应用
- PARA 知识管理体系的实践
