# 本地 RAG 知识检索系统 — 完整技术文档

> 基于 Obsidian + 倒排索引的离线语义检索引擎
> 适用于：金融/医疗/政府等数据不能外传的敏感场景

---

## 一、项目概述

### 核心能力

- **完全离线**：零外部 API 依赖，不上传任何数据
- **倒排索引 + 层级权重**：H1-H4 Markdown 标题权重评分
- **意图识别矩阵**：四类查询自动路由
- **跨会话注入**：新会话自动加载相关上下文

### 技术栈

| 层 | 技术 | 说明 |
|:---|:-----|:-----|
| 存储 | Obsidian (Markdown) | 74条记忆索引，PARA结构 |
| 索引 | Python 倒排索引 | 关键词→文档映射 |
| 权重 | H1-H4 层级评分 | 标题位置决定权重 |
| 路由 | 意图识别矩阵 | 4类查询自动分类 |
| 注入 | shared-context.json | 跨会话上下文保持 |

---

## 二、架构设计

```
用户查询
    │
    ▼
┌──────────────────┐
│  意图识别层       │  分类：知识/项目/决策/上下文
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  倒排索引检索     │  关键词匹配 → 候选集
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  层级权重排序     │  H1=4分 H2=3 H3=2 H4=1
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  结果融合输出     │  Top-5 笔记内容
└──────────────────┘
         │
         ▼
    跨会话注入
```

### 权重计算逻辑

```python
def compute_weight(doc_path, query):
    """
    H1（文档标题）:    权重 4.0
    H2（章节标题）:    权重 3.0
    H3（子节标题）:    权重 2.0
    H4（小节标题）:    权重 1.0
    正文内容:         权重 0.5
    """
    # 读取 Markdown 文档
    content = read_markdown(doc_path)
    
    # 构建倒排索引
    index = build_inverted_index(content)
    
    # 计算每个文档的得分
    score = 0
    for token in tokenize(query):
        if token in index:
            for doc_id, positions in index[token].items():
                for pos in positions:
                    level = get_heading_level(content, pos)
                    score += LEVEL_WEIGHT[level]
    
    return score
```

### 意图识别矩阵

| 查询特征词 | 类型 | 检索策略 |
|:----------|:----:|:---------|
| "怎么"、"如何"、"是什么" | 知识查询 | 精确关键词匹配 |
| "项目"、"进度"、"状态" | 项目查询 | 路径过滤 + 状态解析 |
| "为什么"、"记得吗" | 决策查询 | decision-log 扫描 |
| "上次"、"之前"、"记得" | 上下文查询 | shared-context + 最近快照 |

---

## 三、常见问题和解决方案

### 问题1：中文路径编码问题

**现象：** 文件路径含中文时，PowerShell/Python 读取报错
```
FileNotFoundError: [Errno 2] No such file or directory: 'D:\\AI\\软件\\...'
```

**根因：** Windows PowerShell 默认 GBK 编码，与 UTF-8 冲突
**解决：**
```python
# 方案A：使用短路径（8.3格式）
import os
short_path = os.path.shortname(full_path)  # D:\AI软1\...

# 方案B：设置环境变量
os.environ['PYTHONIOENCODING'] = 'utf-8'

# 方案C：使用绝对路径变量
BASE_DIR = Path(r'D:\AI软件')  # raw string + 绝对路径
```

### 问题2：检索结果太少

**现象：** 74条记忆索引，很多查询返回空结果
**根因：** 关键词太具体，索引粒度不够
**解决：**
```python
# 1. 添加同义词库
SYNONYMS = {
    "AI": ["人工智能", "大模型", "LLM"],
    "副业": ["兼职", "赚钱", "变现"],
}

# 2. 模糊匹配
import difflib
def fuzzy_match(query, keywords, threshold=0.7):
    return [k for k in keywords if difflib.ratio(query, k) > threshold]

# 3. 扩展索引维度
# 不仅索引标题，也索引 frontmatter 中的标签
```

### 问题3：跨会话记忆丢失

**现象：** 新会话启动后，不知道上次聊到哪了
**解决：**
```json
// .shared-context.json 结构
{
  "last_session_update": "2026-09-01T15:22:00",
  "pending": "",
  "recent_activity": ["RAG项目讨论", "飞书推送配置"],
  "context_snapshots": {
    "active_session": "s11",
    "last_topic": "求职准备"
  }
}
```

### 问题4：重排序效果差

**现象：** 最相关的文档排不到前面
**解决：**
```python
# 引入 BM25 替代简单权重
from rank_bm25 import BM25Okapi

def bm25_rank(documents, query):
    tokenized_docs = [tokenize(doc) for doc in documents]
    bm25 = BM25Okapi(tokenized_docs)
    scores = bm25.get_scores(tokenize(query))
    return sorted(zip(documents, scores), key=lambda x: -x[1])
```

### 问题5：扩展性瓶颈

**现象：** 74条数据跑得快，10万条会卡
**解决：**
```python
# 1. 增量索引更新（只索引变更的文档）
# 2. 分区索引（按目录分片）
# 3. 缓存热查询结果
from functools import lru_cache

@lru_cache(maxsize=1000)
def search_cached(query):
    return perform_search(query)

# 4. 预留向量检索升级路径
# 当数据量超过1000条时，切换到向量检索
# 数据结构已预留：search_results 可兼容 vector search
```

---

## 四、面试常见问题

### Q1: 为什么用倒排索引而不是向量检索？

**推荐回答：**
> 倒排索引在中小规模（<1万条）场景下速度更快、资源消耗更低，且完全离线运行。向量检索需要 Embedding 模型，对离线场景不友好。当数据量超过1万条时，我会考虑升级到向量检索（如 Chroma/Milvus）。

### Q2: 如果数据量扩大到10万条怎么办？

**推荐回答：**
> 三层优化：
> 1. **索引优化**：引入 BM25 重排序，替代简单权重
> 2. **架构升级**：切换到向量数据库（Chroma/Milvus），保留倒排索引做预处理
> 3. **工程优化**：增量索引 + 缓存层 + 分布式部署

### Q3: 如何评估检索质量？

**推荐回答：**
> 三个指标：
> - **准确率（Precision）**：返回结果中有多少是真正相关的
> - **召回率（Recall）**：所有相关内容中找到了多少
> - **NDCG**：排序质量（相关结果是否排在前面）
>
> 实际做法：人工标注50个查询的Gold标准，定期跑评估。

### Q4: 和其他RAG方案对比？

| 维度 | 你的方案 | LangChain RAG |
|:-----|:---------|:--------------|
| 离线运行 | ✅ 完全离线 | ❌ 依赖外部API |
| 数据隐私 | ✅ 本地存储 | ⚠️ 需上传 |
| 规模 | <1万条优秀 | 百万级 |
| 复杂度 | 轻量级 | 重框架 |
| 适用场景 | 敏感数据 | 通用场景 |

---

## 五、项目亮点总结（用于简历）

> 构建了基于 Obsidian 的本地 RAG 知识库系统，实现了倒排索引 + H1-H4 层级权重评分的检索算法。设计了意图识别矩阵，将知识查询/项目查询/决策查询/上下文查询四类请求自动路由。系统完全离线运行，不依赖外部 API，检索延迟 <100ms，覆盖 74 个知识节点。

---

*文档版本：v1.0 | 更新时间：2026-09-01*
