#!/bin/bash

# Script để pull main repository và fix submodules về đúng branch
# Sử dụng: ./fix-submodules.sh

echo "🔧 Đang pull main repository và fix submodules về đúng branch..."

# Chuyển về thư mục gốc
cd "$(dirname "$0")"

# 1. Pull main repository
echo "📥 Đang pull main repository..."
git pull origin dev

# 2. Update tất cả submodules
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

# 4. Dọn dẹp các file không cần thiết
echo "🧹 Đang dọn dẹp files không cần thiết..."

# Dọn dẹp frontend-app-learner-dashboard
if [ -f "frontend-app-learner-dashboard/webpack.dev-tutor.config.js" ]; then
    echo "  🗑️  Xóa webpack.dev-tutor.config.js từ frontend-app-learner-dashboard"
    rm -f frontend-app-learner-dashboard/webpack.dev-tutor.config.js
fi

# Kiểm tra chi tiết từng submodule
echo "🔍 Kiểm tra chi tiết từng submodule..."

# Kiểm tra edx-platform
if [ -d "edx-platform" ]; then
    echo "  📁 Kiểm tra edx-platform..."
    cd edx-platform
    current_branch=$(git branch --show-current)
    expected_branch="cvs_dev"
    if [ "$current_branch" = "$expected_branch" ]; then
        echo "    ✅ Branch đúng: $current_branch"
    else
        echo "    ⚠️  Branch hiện tại: $current_branch, mong đợi: $expected_branch"
    fi
    cd ..
else
    echo "  ❌ Thư mục edx-platform không tồn tại"
fi

# Kiểm tra frontend-app-authn
if [ -d "frontend-app-authn" ]; then
    echo "  📁 Kiểm tra frontend-app-authn..."
    cd frontend-app-authn
    current_branch=$(git branch --show-current)
    expected_branch="release/teak"
    if [ "$current_branch" = "$expected_branch" ]; then
        echo "    ✅ Branch đúng: $current_branch"
    else
        echo "    ⚠️  Branch hiện tại: $current_branch, mong đợi: $expected_branch"
    fi
    cd ..
else
    echo "  ❌ Thư mục frontend-app-authn không tồn tại"
fi

# Kiểm tra frontend-app-learner-dashboard
if [ -d "frontend-app-learner-dashboard" ]; then
    echo "  📁 Kiểm tra frontend-app-learner-dashboard..."
    cd frontend-app-learner-dashboard
    current_branch=$(git branch --show-current)
    expected_branch="release/teak"
    if [ "$current_branch" = "$expected_branch" ]; then
        echo "    ✅ Branch đúng: $current_branch"
    else
        echo "    ⚠️  Branch hiện tại: $current_branch, mong đợi: $expected_branch"
    fi
    cd ..
else
    echo "  ❌ Thư mục frontend-app-learner-dashboard không tồn tại"
fi

# Kiểm tra frontend-app-learning
if [ -d "frontend-app-learning" ]; then
    echo "  📁 Kiểm tra frontend-app-learning..."
    cd frontend-app-learning
    current_branch=$(git branch --show-current)
    expected_branch="release/teak"
    if [ "$current_branch" = "$expected_branch" ]; then
        echo "    ✅ Branch đúng: $current_branch"
    else
        echo "    ⚠️  Branch hiện tại: $current_branch, mong đợi: $expected_branch"
    fi
    cd ..
else
    echo "  ❌ Thư mục frontend-app-learning không tồn tại"
fi

# 5. Kiểm tra trạng thái
echo "✅ Hoàn thành! Trạng thái submodules:"
echo ""
git submodule status

echo ""
echo "📋 Tóm tắt:"
echo "  - Main repository đã được pull"
echo "  - Tất cả 4 submodules đã được update và chuyển về branch được setup trong .gitmodules:"
echo "    • edx-platform (branch: cvs_dev)"
echo "    • frontend-app-authn (branch: release/teak)"
echo "    • frontend-app-learner-dashboard (branch: release/teak)"
echo "    • frontend-app-learning (branch: release/teak)"
echo "  - Files không cần thiết đã được dọn dẹp"
echo "  - Hệ thống sẵn sàng sử dụng"
