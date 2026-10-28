# 叶子↔小天通信协议 v1.0

> 完整协议定义，支持15个Action + 11个错误码 + 安全边界

## 一、协议原则

1. **叶子不执行** — 只输出JSON指令，不碰文件/API/进程
2. **小天不决策** — 只接收、解析、执行、反馈
3. **错误现场原样返回** — 不带建议，不带重试，不带fallback
4. **所有指令必须带task_id** — 用于追踪和监护系统监控

## 二、指令Schema（叶子→小天）

```json
{
  "task_id": "string (required)",
  "action": "string (required)",
  "params": {},
  "expected": "string (optional)",
  "priority": "high|normal|low (default: normal)",
  "timeout": 5000 (optional, ms)
}
```

## 三、支持的Action（15个）

| Action | 描述 | 必需参数 | 安全级别 |
|:------|:-----|:--------|:--------:|
| `read_file` | 读取文件 | path | 🟢 |
| `write_file` | 写入文件 | path, content, mode | 🟡 |
| `append_file` | 追加到文件 | path, content | 🟡 |
| `delete_file` | 删除文件 | path | 🔴 |
| `list_dir` | 列出目录 | path | 🟢 |
| `exec_command` | 执行命令 | command, cwd | 🟡 |
| `http_get` | HTTP GET | url | 🟡 |
| `http_post` | HTTP POST | url, body, headers | 🟡 |
| `get_process` | 获取进程信息 | name or pid | 🟢 |
| `kill_process` | 终止进程 | pid | 🔴 |
| `restart_service` | 重启服务 | name | 🔴 |
| `start_service` | 启动服务 | name, cwd | 🟡 |
| `stop_service` | 停止服务 | name | 🟡 |
| `read_memory` | 读取记忆文件 | path | 🟢 |
| `write_memory` | 写入记忆文件 | path, content | 🟡 |

## 四、回执Schema（小天→叶子）

### 成功
```json
{
  "status": "OK",
  "task_id": "string",
  "result": {},
  "execution_time_ms": 123
}
```

### 错误
```json
{
  "status": "ERROR",
  "task_id": "string",
  "error_code": "string",
  "error_message": "string",
  "debug_info": "string (完整错误现场)",
  "suggestion_hint": null
}
```

## 五、错误码（11个）

| 错误码 | 含义 | 触发条件 |
|:------|:-----|:--------|
| `JSON_PARSE_ERROR` | 叶子输出非法JSON | 无法解析 |
| `ACTION_NOT_FOUND` | 未知action | action不在支持列表 |
| `MISSING_PARAM` | 缺少必需参数 | params不完整 |
| `PERMISSION_DENIED` | 权限不足 | 无访问权限 |
| `FILE_NOT_FOUND` | 文件不存在 | path指向的文件不存在 |
| `DIR_NOT_FOUND` | 目录不存在 | path指向的目录不存在 |
| `EXEC_TIMEOUT` | 执行超时 | 超过timeout毫秒 |
| `EXEC_ERROR` | 执行失败 | 命令返回非零退出码 |
| `NET_ERROR` | 网络错误 | HTTP请求失败 |
| `GUARD_INTERRUPT` | 监护系统中断 | 超时/死循环被强杀 |
| `PATH_PROTECTED` | 路径受保护 | 尝试操作系统关键目录 |

## 六、安全边界

### 受保护路径
- `C:\Windows\*`, `C:\Program Files\*`
- `HKLM:\*`, `HKCU:\*`

### 危险命令拦截
- `rm -rf /`, `del /f /s /q C:\*` → `PATH_PROTECTED`
- 系统级Kill → `PERMISSION_DENIED`

### 单次指令原则
叶子每次只发一条指令，等待回执后再发下一条。禁止批量发射。

## 七、监护系统

当检测到以下情况时强制中断：
- 叶子连续输出 100 条指令未收到回执
- 单条指令执行超过 30 秒

中断后发送 `GUARD_INTERRUPT` 错误码，直接 SIGTERM 终止。

## 八、完整协议文档

详细实现见：`C:\Users\王文斌\.claude\skills\叶子\protocols\leaf-tian-protocol-v1.md`
