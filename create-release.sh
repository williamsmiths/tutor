#!/bin/bash

# Script tạo release cho Tutor
# Usage: ./create-release.sh [version]
# Example: ./create-release.sh 20.0.2

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if version is provided
if [ $# -eq 0 ]; then
    print_error "Version không được cung cấp!"
    echo "Usage: $0 <version>"
    echo "Example: $0 20.0.2"
    exit 1
fi

VERSION=$1
TAG_NAME="v$VERSION"

print_info "Bắt đầu tạo release cho version: $VERSION"

# Check if we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    print_warning "Bạn đang ở branch: $CURRENT_BRANCH"
    print_warning "Nên chuyển về main branch trước khi tạo release"
    read -p "Tiếp tục? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Hủy bỏ tạo release"
        exit 1
    fi
fi

# Check if working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    print_error "Working directory không sạch! Commit hoặc stash changes trước."
    git status --short
    exit 1
fi

# Check if tag already exists
if git tag -l | grep -q "^$TAG_NAME$"; then
    print_error "Tag $TAG_NAME đã tồn tại!"
    exit 1
fi

print_info "1. Cập nhật version trong tutor/__about__.py"
# Update version in __about__.py
sed -i "s/__version__ = \".*\"/__version__ = \"$VERSION\"/" tutor/__about__.py

# Verify the change
CURRENT_VERSION=$(make version)
if [ "$CURRENT_VERSION" != "$VERSION" ]; then
    print_error "Version không được cập nhật đúng! Expected: $VERSION, Got: $CURRENT_VERSION"
    exit 1
fi
print_success "Version đã được cập nhật thành: $CURRENT_VERSION"

print_info "2. Tạo changelog entry"
# Create changelog entry
if command -v scriv &> /dev/null; then
    print_info "Tạo changelog entry với scriv..."
    scriv create
    print_success "Changelog entry đã được tạo"
else
    print_warning "scriv không được cài đặt, bỏ qua tạo changelog entry"
fi

print_info "3. Commit changes"
git add tutor/__about__.py
if [ -d "changelog.d" ]; then
    git add changelog.d/
fi
git commit -m "Bump version to $VERSION"

print_info "4. Push changes to main branch"
git push origin main

print_info "5. Tạo tag: $TAG_NAME"
git tag $TAG_NAME

print_info "6. Push tag để trigger release workflow"
git push origin $TAG_NAME

print_success "Release đã được tạo thành công!"
print_info "Tag: $TAG_NAME"
print_info "Version: $VERSION"
print_info "GitHub Actions sẽ tự động build và tạo release"

# Show next steps
echo
print_info "Các bước tiếp theo:"
echo "1. Kiểm tra GitHub Actions: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\).*/\1/')/actions"
echo "2. Kiểm tra Releases: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\).*/\1/')/releases"
echo "3. Đợi workflow hoàn thành và download binary files"

# Show current git status
echo
print_info "Git status hiện tại:"
git status --short
echo
print_info "Tags hiện tại:"
git tag --sort=-version:refname | head -5
