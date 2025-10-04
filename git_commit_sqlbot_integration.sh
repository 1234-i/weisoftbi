#!/bin/bash

# SQLBot 集成 Git 提交脚本
# 按批次提交代码到远程仓库

set -e  # 遇到错误立即退出

echo "========================================="
echo "SQLBot 集成 Git 提交脚本"
echo "========================================="
echo ""

# 检查是否在 Git 仓库中
if [ ! -d ".git" ]; then
    echo "错误：当前目录不是 Git 仓库"
    exit 1
fi

# 检查是否有未提交的更改
if [ -z "$(git status --porcelain)" ]; then
    echo "没有需要提交的更改"
    exit 0
fi

echo "当前分支：$(git branch --show-current)"
echo ""

# ============================================
# 说明：使用官方代码，无需修改
# ============================================
echo "========================================="
echo "✅ 使用官方 DatasetSQLBotServer.java"
echo "========================================="
echo ""
echo "本次集成使用官方的 DatasetSQLBotServer.java 文件"
echo "无需修改任何代码，只需提交文档"
echo ""

# ============================================
# 提交批次 1：文档更新
# ============================================
echo "========================================="
echo "提交批次 1：文档更新"
echo "========================================="
echo ""

# 添加所有 SQLBot 相关的 Markdown 文档
echo "添加 SQLBot 相关文档..."
git add SQLBot*.md 2>/dev/null || echo "没有找到 SQLBot 文档"
git add README_SQLBOT_INTEGRATION.md 2>/dev/null || echo "没有找到 README"
git add GIT_COMMIT_GUIDE.md 2>/dev/null || echo "没有找到 Git 指南"
git add git_commit_sqlbot_integration.sh 2>/dev/null || echo "没有找到提交脚本"
git add update_datasource_description.sql 2>/dev/null || echo "没有找到 SQL 脚本"

# 检查是否有文档需要提交
if git diff --cached --quiet; then
    echo "⚠️  没有文档需要提交，跳过批次 1"
    echo ""
else
    echo "提交批次 1..."
    git commit -m "docs: 添加 SQLBot 集成文档

- 添加完整的集成实施文档
- 包含所有问题的解决方案
- 提供详细的配置说明
- 添加测试验证步骤
- 添加数据源描述更新脚本
- 使用官方 DatasetSQLBotServer.java，无需修改代码

相关问题：SQLBot 集成 - 文档"

    echo "✅ 提交批次 1 完成"
    echo ""
fi

# ============================================
# 提交批次 2：其他修改（可选）
# ============================================
echo "========================================="
echo "提交批次 2：其他修改（可选）"
echo "========================================="
echo ""

# 检查是否还有其他未提交的更改
if [ -n "$(git status --porcelain)" ]; then
    echo "还有以下未提交的更改："
    git status --short
    echo ""
    echo "⚠️  注意：这些更改与 SQLBot 集成无关"
    echo "建议单独处理这些更改"
    echo ""
    echo "是否要提交这些更改？(y/n)"
    read -r answer

    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        echo "请输入提交信息："
        read -r commit_message

        git add .
        git commit -m "$commit_message"

        echo "✅ 提交批次 2 完成"
        echo ""
    else
        echo "⚠️  跳过批次 2"
        echo ""
    fi
else
    echo "✅ 没有其他未提交的更改"
    echo ""
fi

# ============================================
# 推送到远程仓库
# ============================================
echo "========================================="
echo "推送到远程仓库"
echo "========================================="
echo ""

echo "是否要推送到远程仓库？(y/n)"
read -r answer

if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    current_branch=$(git branch --show-current)
    echo "推送分支：$current_branch"
    
    git push origin "$current_branch"
    
    echo "✅ 推送完成"
    echo ""
else
    echo "⚠️  跳过推送"
    echo ""
fi

# ============================================
# 完成
# ============================================
echo "========================================="
echo "✅ 所有提交完成！"
echo "========================================="
echo ""

echo "提交历史："
git log --oneline -5

echo ""
echo "如果需要推送，请运行："
echo "  git push origin $(git branch --show-current)"

