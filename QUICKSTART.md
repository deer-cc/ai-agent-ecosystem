# GitHub 作品集 快速使用

## 目录结构

```
github-portfolio/
├── README.md                    ← 仓库主页（面试/HR第一眼看到）
├── RESUME.md                    ← 完整简历（可直接复制粘贴）
├── ARCHITECTURE/                ← 架构文档
├── PROTOCOLS/                   ← 协议设计
├── PROJECTS/                    ← 7个核心项目详解
└── demos/                       ← 演示脚本和截图
```

## 快速开始

### 1. 推送到 GitHub（已完成）

```powershell
cd D:\AI软件\github-portfolio
git pull origin main
git add -A
git commit -m "Update resume and README for job application"
git push origin main
```

### 2. 投递简历

- **Boss直聘/拉勾**：将 RESUME.md 内容复制到在线简历编辑器
- **邮件投递**：导出为 PDF 或粘贴正文
- **面试展示**：打开 README.md + PROJECTS 目录，逐一讲解

### 3. 面试准备

重点准备以下话题：
- 项目1 Multi-Agent：叶子↔小天协议设计、15个Action、监护机制
- 项目2 cc-connect：跨平台桥接架构、凭证冲突解决
- 项目3 桌面自动化：性能优化（500ms→50ms）、Win32 API
- 项目4 RAG：倒排索引实现、离线检索优势
- 项目5 服务治理：三层架构、dispatcher 去重/节流/重试算法
- 项目6 RAG引擎：TF-IDF混合检索、中文分词、持久化热加载
- 项目7 客服引擎：LLM意图识别+多轮对话+RAG知识库融合+工程规范

---

*最后更新：2026-09-08*
