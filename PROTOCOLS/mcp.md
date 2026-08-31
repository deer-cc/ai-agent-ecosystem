# MCP 协议集成实践

## 概览

本项目完整运用了 MCP（Model Context Protocol）协议的五层能力模型，
不只是简单的 Tools 调用。

## 已接入的 MCP Server

| Server | 功能 | 传输方式 | 状态 |
|:-------|:-----|:---------|:----:|
| **Playwright MCP** | 浏览器自动化（截图/点击/导航/填表） | stdio | ✅ 已接入 |
| **Native DevTools MCP** | 系统桌面操作（窗口/进程/文件） | stdio | ✅ 已接入 |
| **web-fetch MCP** | 网页内容抓取 | stdio | ✅ 已接入 |
| **Feishu MCP Server** | 飞书消息/文档/图片 | stdio | ⏸️ 待配置凭证 |

## 配置文件

### `.mcp.json`（项目级）

```json
{
  "mcpServers": {
    "playwright": {
      "command": "node",
      "args": ["D:\\AI软件\\ClaudeCode\\node_modules\\@playwright\\mcp\\dist\\index.js"]
    },
    "native-devtools": {
      "command": "node",
      "args": ["D:\\AI软件\\ClaudeCode\\node_modules\\native-devtools-mcp\\dist\\index.js"]
    }
  }
}
```

### `mcp-config.json`（全局）

```json
{
  "mcpServers": {
    "web-fetch": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-web-fetch"]
    }
  }
}
```

## 五层能力运用分析

### 1. Tools（工具调用）— ✅ 已充分使用

```
Client → tools/call(name, arguments) → Server → Result
```

**实践场景：**
- Playwright: `goto(url)`, `screenshot()`, `click(selector)`, `fill(selector, text)`
- DevTools: `get_processes()`, `list_files(path)`, `exec_command(cmd)`
- 自定义: desktop-bridge HTTP API 封装为 MCP Tool

**代码示例（desktop-bridge server.py）：**
```python
# HTTP API 端点，可封装为 MCP Tool
@app.post('/screenshot')
def screenshot(req: ScreenshotRequest):
    img = PIL.ImageGrab.grab(bbox=req.region)
    return {"data": base64.encode(img)}
```

### 2. Resources（资源读取）— ⏸️ 待扩展

```
Client → resources/list → Server → Resource[]
Client → resources/read(uri) → Server → ResourceContents
```

**规划中的场景：**
- 飞书文档：`resources/read("feishu://docs/{doc_id}")`
- 知识库：`resources/read("obsidian://notes/{note_id}")`
- 系统信息：`resources/read("sys:///processes")`

**优势：** 比 tools/call 更直接，Server 暴露数据 URI，Client 按需读取。

### 3. Prompts（提示模板）— ⏸️ 待扩展

```
Client → prompts/list → Server → Prompt[]
Client → prompts/get(name, arguments) → Server → PromptMessage[]
```

**规划中的场景：**
- 每个 Skill 预定义 prompt 模板（如"总结这段对话"、"分析这段代码"）
- Server 端管理模板版本，Client 端调用

### 4. Sampling（服务端→LLM）— ⏸️ 未使用

```
Server → sampling/createMessage(params) → Client → LLM → Response → Server
```

**适用场景：** Server 需要"智能"决策时自行调用 LLM（如数据分析后自动生成总结）。

### 5. Roots（根目录）— ✅ 隐含使用

```
Client → roots/list → Server → Root[]
```

Claude Code 默认把工作目录作为 Root 暴露给 MCP Server，
Server 可以感知文件范围并做智能操作。

## MCP 协议深度运用建议

### 当前水平

```
Tools:     ████████░░  80% — 已有多个Server接入，熟练调用
Resources: ████░░░░░░  40% — 知道原理但尚未使用
Prompts:   ██░░░░░░░░  20% — 了解概念，未实践
Sampling:  ░░░░░░░░░░   0% — 未涉及
Roots:     ████████░░  80% — Claude Code 自动注入
```

### 下一步方向

1. **编写自定义 MCP Server**：把小鱼/阿秋/阿甘的技能包装成 MCP Server
2. **启用 Resources**：让飞书/知识库通过 URI 暴露
3. **探索 Prompts**：为每个领域定义模板化交互

## 相关资源

- [MCP 官方文档](https://modelcontextprotocol.io/)
- [MCP SDK (TypeScript)](https://github.com/modelcontextprotocol/sdk)
- [Playwright MCP](https://github.com/anthropics/playwright-mcp)
- 本机项目：`C:\Users\王文斌\.claude\projects\d--AI--\memory\mcp-protocol-depth.md`
