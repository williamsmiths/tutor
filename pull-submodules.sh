#!/bin/bash

# Script để pull submodules một cách an toàn
# Sử dụng: ./pull-submodules.sh

echo "🚀 Đang pull submodules một cách an toàn..."

# Chuyển về thư mục gốc
cd "$(dirname "$0")"

# 1. Pull main repository
echo "📥 Đang pull main repository..."
git pull origin dev

# 2. Update submodules
echo "📦 Đang update submodules..."
git submodule update --init --recursive

# 3. Chuyển tất cả submodules về branch được setup trong .gitmodules
echo "🔄 Đang chuyển submodules về branch được setup trong .gitmodules..."
git submodule foreach '
    echo "  📁 Đang xử lý: $(basename $(pwd))"
    git fetch origin
    
    # Lấy branch từ .gitmodules
    submodule_name=$(basename $(pwd))
    branch=$(git config -f ../.gitmodules submodule.$submodule_name.branch)
    
    if [ -n "$branch" ]; then
        echo "    🎯 Branch được setup: $branch"
        git checkout $branch
        git pull origin $branch
    else
        echo "    ⚠️  Không tìm thấy branch trong .gitmodules, sử dụng default"
        git checkout main || git checkout master
        git pull origin main || git pull origin master
    fi
'

# 4. Dọn dẹp files không cần thiết
echo "🧹 Đang dọn dẹp files không cần thiết..."

# Dọn dẹp frontend-app-learner-dashboard
if [ -f "frontend-app-learner-dashboard/webpack.dev-tutor.config.js" ]; then
    echo "  🗑️  Xóa webpack.dev-tutor.config.js từ frontend-app-learner-dashboard"
    rm -f frontend-app-learner-dashboard/webpack.dev-tutor.config.js
fi

# 5. Kiểm tra trạng thái
echo "✅ Hoàn thành! Trạng thái submodules:"
echo ""
git submodule status

echo ""
echo "📋 Tóm tắt:"
echo "  - Main repository đã được pull"
echo "  - Tất cả submodules đã được update và chuyển về branch được setup trong .gitmodules"
echo "  - Files không cần thiết đã được dọn dẹp"
echo "  - Hệ thống sẵn sàng sử dụng"
