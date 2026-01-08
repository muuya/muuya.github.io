#!/bin/bash

# 自动部署脚本 - 提交并推送到 GitHub
# 使用方法: ./deploy.sh [提交信息]

set -e  # 遇到错误立即退出

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 开始部署到 GitHub...${NC}\n"

# 进入脚本所在目录
cd "$(dirname "$0")"

# 检查是否在 git 仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}❌ 错误: 当前目录不是 Git 仓库${NC}"
    exit 1
fi

# 获取提交信息
if [ -z "$1" ]; then
    COMMIT_MSG="更新内容: $(date '+%Y-%m-%d %H:%M:%S')"
else
    COMMIT_MSG="$1"
fi

# 显示当前状态
echo -e "${BLUE}📊 当前 Git 状态:${NC}"
git status -s
echo ""

# 添加所有更改
echo -e "${BLUE}📦 添加文件到暂存区...${NC}"
git add .

# 检查是否有更改需要提交
if git diff --staged --quiet; then
    echo -e "${YELLOW}⚠️  没有需要提交的更改${NC}"
    
    # 检查是否有未推送的提交
    if git rev-parse --abbrev-ref --symbolic-full-name @{u} > /dev/null 2>&1; then
        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse @{u})
        BASE=$(git merge-base @ @{u})
        
        if [ $LOCAL = $REMOTE ]; then
            echo -e "${GREEN}✅ 所有更改已同步到远程仓库${NC}"
            exit 0
        elif [ $LOCAL = $BASE ]; then
            echo -e "${YELLOW}⚠️  远程仓库有新的提交，请先执行 git pull${NC}"
            exit 1
        fi
    fi
else
    # 提交更改（禁用 GPG 签名以避免非交互式环境问题）
    echo -e "${BLUE}💾 提交更改...${NC}"
    git commit --no-gpg-sign -m "$COMMIT_MSG"
    echo -e "${GREEN}✅ 提交成功: $COMMIT_MSG${NC}\n"
fi

# 推送到远程仓库
echo -e "${BLUE}📤 推送到 GitHub...${NC}"
BRANCH=$(git branch --show-current)
git push origin "$BRANCH"

echo -e "\n${GREEN}🎉 部署完成！${NC}"
echo -e "${GREEN}📍 分支: $BRANCH${NC}"
echo -e "${GREEN}🌐 仓库: $(git remote get-url origin)${NC}"

