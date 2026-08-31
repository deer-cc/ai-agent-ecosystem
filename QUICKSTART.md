# GitHub 作品集 快速使用

## 目录结构

```
github-portfolio/
├── README.md                    ← 项目总览（首页）
├── .gitignore
├── init_git.bat                 ← 一键初始化Git
├── ARCHITECTURE/
│   ├── architecture.md          ← 系统架构总览（5层架构）
│   └── multi-agent.md           ← 多Agent编排设计（叶子协议）
├── PROTOCOLS/
│   ├── mcp.md                   ← MCP协议集成实践
│   └── leaf-tian-protocol.md    ← 叶子↔小天通信协议
├── PROJECTS/
│   ├── 01-multi-agent-system.md      ← 项目1：多Agent系统
│   ├── 02-cc-connect-bridge.md       ← 项目2：跨平台桥接
│   ├── 03-desktop-automation.md      ← 项目3：桌面自动化v2
│   ├── 04-knowledge-base.md          ← 项目4：本地RAG检索
│   └── 05-service-governance.md      ← 项目5：服务治理
└── demos/                         ← 演示脚本和截图
```

## 初始化

```powershell
cd D:\AI软件\github-portfolio
.\init_git.bat
```

## 推送到GitHub

```powershell
git remote add origin https://github.com/你的用户名/ai-agent-ecosystem.git
git branch -M main
git push -u origin main
```

## 简历使用建议

把每个 PROJECT 文档中的"与简历的结合"部分复制到简历的项目经验中。
README.md 可作为 GitHub 主页展示。
