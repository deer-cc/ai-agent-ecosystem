# RAG 检索引擎架构

## 概述

生产级本地 RAG 检索引擎，支持混合检索（关键词 + TF-IDF向量）、持久化热加载、SSE流式输出。
完全离线运行，零外部 API 依赖。

## 技术栈

- **检索引擎**：ChromaDB（向量存储） + 自实现 TF-IDF + 倒排索引
- **API 层**：FastAPI + WebSocket（预留）
- **分词**：零依赖中文滑窗分词（双字+单字）
- **持久化**：JSON 文件缓存（inverted_index.json + chunks_meta.json）

## 架构图

```
┌─────────────────────────────────────────────────────────────┐
│                      用户请求层                              │
│  HTTP / SSE / WebSocket                                     │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│              API 路由层 (FastAPI)                            │
│  GET  /health        健康检查                                 │
│  POST /search        混合检索                                 │
│  GET  /stream        SSE 流式检索                             │
│  POST /refresh       重建索引                                 │
│  GET  /stats         索引统计                                 │
│  GET  /rag           UI 界面                                  │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│              HybridRetriever 检索层                           │
│  ┌─────────────────┐    ┌─────────────────┐                 │
│  │  关键词召回      │    │  TF-IDF向量召回  │                 │
│  │  (倒排索引)      │    │  (ChromaDB HNSW)│                 │
│  │  BM25变体评分    │    │  cosine相似度   │                 │
│  └────────┬────────┘    └────────┬────────┘                 │
│           └──────────┬───────────┘                          │
│                      ▼                                       │
│            加权融合排序 (35% + 65%)                          │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│              数据持久化层                                     │
│  ChromaDB (:8083本地) · JSON索引缓存 · Markdown文档源        │
└─────────────────────────────────────────────────────────────┘
```

## 核心设计决策

### 1. 为什么用 TF-IDF 而不是 Embedding 模型？

- 无网络依赖：HuggingFace 被墙，无法下载 sentence-transformers
- 速度优势：TF-IDF 计算 <1ms，Embedding 推理 ~50ms+
- 效果足够：对于中文专业术语（MCP、飞书、Jarvis）关键词匹配更精确
- 可解释性强：可以清晰说出"因为'协议'这个词匹配了8个块"

### 2. 为什么不用 LangChain？

- 引入重依赖（~50MB），增加部署复杂度
- 我们的场景只需要简单的检索，不需要完整的 RAG pipeline
- 自实现反而更可控、更好调试

### 3. 持久化方案

| 文件 | 大小 | 内容 |
|:-----|:----:|:-----|
| chroma.sqlite3 | ~2MB | 向量数据（ChromaDB内部） |
| inverted_index.json | ~400KB | 关键词→chunk ID映射 |
| chunks_meta.json | ~240KB | chunk标题/路径/预览 |

重启加载时间：<100ms（纯JSON读取）

### 4. 分词策略

```python
def tokenize(text):
    # 英文单词
    words = re.findall(r'[a-zA-Z0-9_]+', text.lower())
    # 中文单字
    cn_chars = re.findall(r'[一-鿿]', text)
    for i in range(len(cn_chars)):
        words.append(cn_chars[i])
        if i+1 < len(cn_chars):
            words.append(cn_chars[i] + cn_chars[i+1])  # 双字滑窗
    return list(dict.fromkeys(words))  # 去重保序
```

示例："MCP协议是什么" → ["mcp", "协", "协议", "议", "是", "什么"]

## API 详细

### POST /search
请求体：`{ "query": "xxx", "top_k": 5 }`
响应：
```json
{
  "query": "MCP协议",
  "results": [
    {
      "title": "对接方式",
      "path": "02_Areas/记忆库/openclaw-coordination-plan.md",
      "content_preview": "...",
      "keyword_score": 0.85,
      "vector_score": 0.72,
      "combined_score": 0.77
    }
  ],
  "context": "...",
  "hit_count": 5,
  "latency_ms": 12
}
```

### GET /stream?q=xxx&top_k=5
SSE 流式输出：
```
data: {"type":"meta","query":"MCP协议","top_k":2}
data: {"type":"count","count":2}
data: {"type":"result","index":0,"title":"...","score":0.77}
data: {"type":"done"}
```

## 性能指标

| 指标 | 数值 |
|:-----|:----:|
| 索引构建时间 | ~30s（592块）|
| 单次检索延迟 | <50ms |
| 内存占用 | ~15MB |
| 磁盘占用 | ~3MB |
| 冷启动加载 | <100ms |

## 已知限制

1. 分词为简单滑窗，不支持语义理解（如"AI助手"不自动联想到"Jarvis"）
2. 无 rerank 阶段，排序依赖混合打分
3. 不支持增量更新（需全量重建）
4. 无权限控制（本地服务，暂无需求）

---

*最后更新：2026-09-01*
