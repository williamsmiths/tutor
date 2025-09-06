#!/bin/bash

# Script để setup git aliases từ .gitconfig-local
# Tác giả: Auto-generated script
# Ngày tạo: $(date)

echo "🔧 Đang setup git aliases..."

# Kiểm tra file .gitconfig-local có tồn tại không
if [ ! -f ".gitconfig-local" ]; then
    echo "❌ File .gitconfig-local không tồn tại!"
    exit 1
fi

# Add file .gitconfig-local vào git nếu chưa được track
if ! git ls-files | grep -q ".gitconfig-local"; then
    echo "📁 Đang add .gitconfig-local vào git..."
    git add .gitconfig-local
    echo "✅ Đã add .gitconfig-local vào git"
else
    echo "✅ .gitconfig-local đã được track bởi git"
fi

# Include .gitconfig-local vào git config global
echo "🔗 Đang include .gitconfig-local vào git config..."
GITCONFIG_PATH=$(pwd)/.gitconfig-local

# Kiểm tra xem đã include chưa
if ! git config --global --get include.path | grep -q ".gitconfig-local"; then
    git config --global include.path "$GITCONFIG_PATH"
    echo "✅ Đã include .gitconfig-local vào git config global"
else
    echo "✅ .gitconfig-local đã được include trong git config"
fi

# Kiểm tra các alias đã hoạt động chưa
echo "🧪 Đang test các alias..."
ALIASES=("fixsub" "setup" "pullsub" "pullall")

for alias in "${ALIASES[@]}"; do
    if git config --get alias.$alias > /dev/null 2>&1; then
        echo "✅ Alias 'git $alias' đã sẵn sàng"
    else
        echo "❌ Alias 'git $alias' chưa hoạt động"
    fi
done

echo ""
echo "🎉 Setup hoàn tất!"
echo ""
echo "📋 Các alias có sẵn:"
echo "  git fixsub  - Fix submodules về branch release/teak"
echo "  git setup   - Setup project"
echo "  git pullsub - Pull submodules an toàn"
echo "  git pullall - Pull tất cả submodules với remote"
echo ""
echo "💡 Để sử dụng, chỉ cần chạy: git <alias_name>"
