@echo off
REM GitHub 作品集 — 初始化 Git 仓库
chcp 65001 >nul
cd /d D:\AI软件\github-portfolio

if not exist .git (
    git init
    git add .
    git commit -m "Initial commit: AI Agent Ecosystem Portfolio"
    echo ✅ Git仓库已初始化
) else (
    git add .
    git status
    echo 💡 输入以下命令提交:
    echo    git commit -m "your message"
    echo    git push origin main
)
pause
