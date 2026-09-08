# 项目七：客服引擎 v1.0 — AI 对话系统

> 作品集项目：展示 LLM 意图识别 + 多轮对话 + RAG 知识库融合 + 工程规范

## 一句话定位

> 基于 FastAPI + LLM 的多轮对话客服引擎，集成意图识别、RAG 知识库检索、多轮对话状态机，配套完整工程规范（pytest + Docker + CI）

## 技术栈

Python · FastAPI · Pydantic · httpx · 倒排索引 · TF-IDF · pytest · Docker · GitHub Actions

## 核心能力

| 能力 | 实现方式 | 技术亮点 |
|:-----|:---------|:---------|
| 意图识别 | LLM 为主 + 关键词兜底 | 多级分类策略，LLM失败自动降级 |
| 多轮对话 | Session 级状态机 | 历史窗口管理，保留最近 N 轮 |
| 知识库检索 | 倒排索引 + TF-IDF | 零外部依赖，完全离线运行 |
| 回复策略 | 按意图路由模板 | 售前/售后/投诉分流处理 |
| 工程规范 | pytest + Docker + CI | 18个测试用例全部通过 |

## 架构

```
┌─────────────────────────────────────────────────────────┐
│  Frontend (演示)                                         │
│  static/index.html — 浏览器打开即演示                    │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTP
┌──────────────────────▼──────────────────────────────────┐
│  FastAPI :8899                                           │
│  /chat POST    ← 对话入口                                │
│  /intent POST   ← 意图识别                               │
│  /kb/search GET ← 知识库检索                             │
│  /health GET    ← 健康检查                               │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│  Core Engine                                            │
│  ├── intent.py    ← 意图识别（LLM + 关键词兜底）         │
│  ├── dialog.py    ← 多轮对话状态机                      │
│  ├── rag.py       ← 知识库检索（倒排索引+TF-IDF）        │
│  ├── response.py  ← 回复策略（按意图路由）               │
│  └── models.py    ← Pydantic 数据模型                   │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│  Data Layer                                             │
│  knowledge/  ← 知识库文档（faq/shipping/returns）       │
│  conversations/ ← 对话历史（JSON）                      │
└─────────────────────────────────────────────────────────┘
```

## 意图识别设计

### 多级分类策略

```
用户消息
    ↓
[Step 1] LLM 意图分类（置信度 > 0.5?）
    ├── 是 → 使用 LLM 结果
    └── 否 → [Step 2] 关键词兜底匹配
              ├── 匹配到 → 使用关键词结果
              └── 未匹配 → unknown
```

### 支持的意图类型

| 意图 | 关键词示例 | 场景 |
|:-----|:----------|:-----|
| shipping | 物流、快递、发货、运费 | 物流查询 |
| returns | 退货、退款、质量、不满意 | 退换货 |
| price | 多少钱、优惠、打折 | 价格咨询 |
| product | 材质、尺寸、真假 | 商品详情 |
| stock | 有货、库存、预售 | 库存查询 |
| greeting | 你好、在吗 | 打招呼 |
| bye | 再见、谢谢 | 告别 |
| complaint | 差评、投诉、假货 | 投诉反馈 |

## 多轮对话状态机

```python
class DialogManager:
    def process(self, user_message, intent_result, kb_results):
        # 1. 更新轮次和时间戳
        # 2. 追加用户消息到历史
        # 3. 限制历史长度（history_window）
        # 4. 根据意图生成回复
        # 5. 追加助手回复到历史
        # 6. 返回 (reply, updated_session)
```

**设计要点：**
- Session 级状态隔离，不同用户互不影响
- 历史窗口可配置（默认最近6轮）
- 低置信度时引导用户澄清

## RAG 知识库检索

### 双路召回

| 路径 | 权重 | 说明 |
|:-----|:----:|:-----|
| 关键词匹配 | 50% | 倒排索引，精确匹配 |
| TF-IDF 向量 | 50% | 词频×逆文档频率 |

### 中文分词

纯正则实现，无外部依赖：
- 中文双字滑窗提取关键词
- 英文单词提取（长度≥2）

### 性能

- 知识库加载：<100ms（热启动）
- 单次检索：<10ms
- 支持增量更新（刷新接口）

## 工程规范

### 测试覆盖

```
tests/test_intent.py  — 意图识别（7个用例）
tests/test_dialog.py  — 对话状态机（6个用例）
tests/test_rag.py     — 知识库检索（5个用例）
────────────────────────────────
总计：18 个测试用例，全部通过
```

### CI/CD

```yaml
# .github/workflows/ci.yml
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - checkout
      - setup-python-3.10
      - install-dependencies
      - run-tests  # pytest -v
```

### Docker 部署

```dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8899
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8899"]
```

## 快速开始

```powershell
# 1. 安装依赖
cd D:\AI软件\核心引擎\客服引擎
pip install -r requirements.txt

# 2. 运行测试
python -m pytest tests/ -v

# 3. 启动服务
python -m src.main

# 4. 打开演示页面
# http://127.0.0.1:8899
```

## 面试讲解要点

### Q: 意图识别怎么做的？

> 采用多级分类策略。第一级用 LLM 做通用意图分类，置信度低或 LLM 失败时自动降级到关键词规则匹配。这样既利用了 LLM 的泛化能力，又保证了关键场景的覆盖率。实际测试中，关键词兜底覆盖了约 85% 的日常咨询。

### Q: 多轮对话怎么管理上下文？

> 每个 session 独立维护一个对话历史列表，配置 history_window 控制保留轮数。每次新消息到来时，追加用户消息和助手回复，然后截断超出窗口的历史。这样既保持了对话连续性，又控制了 token 消耗。

### Q: RAG 检索为什么不用 Embedding？

> 三个原因：一、HuggingFace 被墙无法下载模型；二、TF-IDF 速度更快（<10ms vs 50ms+）；三、对中文专业术语（如"七天无理由"、"运费险"）关键词匹配反而比语义检索更精确。这是工程上的务实选择。

### Q: 这个项目和现有 RAG 引擎有什么区别？

> 现有 RAG 引擎（项目四）是通用知识库检索，面向内部知识查询。客服引擎的 RAG 是面向电商场景的垂直知识库，专门针对售后/物流/价格等客服场景优化，并且与对话状态机和意图识别深度整合。

## 文件结构

```
客服引擎/
├── src/
│   ├── main.py            ← FastAPI 入口 + 路由
│   ├── intent.py          ← 意图识别（LLM + 关键词）
│   ├── dialog.py          ← 多轮对话状态机
│   ├── rag.py             ← 知识库检索
│   ├── response.py        ← 回复策略
│   └── models.py          ← Pydantic 数据模型
├── knowledge/
│   ├── faq.md             ← 常见问题
│   ├── shipping.md        ← 物流规则
│   └── returns.md         ← 退换货规则
├── conversations/          ← 对话历史（JSON）
├── static/index.html      ← 演示页面
├── tests/                  ← 测试套件（18个用例）
├── docker-compose.yml
├── Dockerfile
├── .github/workflows/ci.yml
├── requirements.txt
├── config.json
└── README.md
```

---

*创建：2026-09-08*
*状态：已完成（作品集项目 v1.0）*
