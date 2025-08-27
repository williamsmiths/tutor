#!/bin/bash

# Script debug release cho Tutor
# Usage: ./debug-release.sh [tag_name]
# Example: ./debug-release.sh v20.0.2

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Check if tag is provided
if [ $# -eq 0 ]; then
    print_error "Tag name không được cung cấp!"
    echo "Usage: $0 <tag_name>"
    echo "Example: $0 v20.0.2"
    exit 1
fi

TAG_NAME=$1

print_info "Debug release cho tag: $TAG_NAME"

echo
print_info "=== 1. Kiểm tra Git status ==="
echo "Current branch: $(git branch --show-current)"
echo "Current commit: $(git rev-parse HEAD)"
echo "Tag exists: $(git tag -l | grep -c "^$TAG_NAME$")"

echo
print_info "=== 2. Kiểm tra version ==="
echo "Version from make: $(make version)"
echo "Version from __about__.py: $(grep '__version__' tutor/__about__.py)"

echo
print_info "=== 3. Kiểm tra GitHub CLI ==="
if command -v gh &> /dev/null; then
    echo "GitHub CLI version: $(gh --version | head -1)"
    
    # Check if release exists
    if gh release view $TAG_NAME >/dev/null 2>&1; then
        print_success "Release $TAG_NAME tồn tại trên GitHub"
        echo "Release info:"
        gh release view $TAG_NAME --json name,tagName,url,assets
    else
        print_warning "Release $TAG_NAME không tồn tại trên GitHub"
    fi
else
    print_warning "GitHub CLI không được cài đặt"
fi

echo
print_info "=== 4. Kiểm tra local build ==="
if [ -f "./dist/tutor" ]; then
    print_success "Binary file tồn tại: ./dist/tutor"
    echo "File size: $(ls -lh ./dist/tutor | awk '{print $5}')"
    echo "File permissions: $(ls -la ./dist/tutor | awk '{print $1}')"
    
    # Test binary
    echo "Binary version: $(./dist/tutor --version 2>/dev/null || echo 'Failed to get version')"
else
    print_warning "Binary file không tồn tại: ./dist/tutor"
    print_info "Chạy 'make bundle' để tạo binary"
fi

echo
print_info "=== 5. Kiểm tra environment ==="
echo "OS: $(uname -s)"
echo "Architecture: $(uname -m)"
echo "Python version: $(python --version)"
echo "Make version: $(make --version | head -1)"

echo
print_info "=== 6. Kiểm tra workflow files ==="
if [ -f ".github/workflows/release.yml" ]; then
    print_success "Release workflow tồn tại"
    echo "Workflow trigger:"
    grep -A 5 "on:" .github/workflows/release.yml
else
    print_error "Release workflow không tồn tại"
fi

echo
print_info "=== 7. Kiểm tra changelog ==="
if [ -d "changelog.d" ]; then
    echo "Changelog entries:"
    ls -la changelog.d/ | grep -v "^total"
else
    print_warning "Changelog directory không tồn tại"
fi

echo
print_info "=== 8. Simulate filename generation ==="
FILENAME="tutor-$(uname -s)_$(uname -m)"
echo "Generated filename: $FILENAME"
echo "Expected files:"
echo "  - $FILENAME (Linux)"
echo "  - tutor-Darwin_x86_64 (macOS)"

echo
print_info "=== 9. Kiểm tra repository info ==="
REMOTE_URL=$(git config --get remote.origin.url)
echo "Remote URL: $REMOTE_URL"
if [[ $REMOTE_URL == *"github.com"* ]]; then
    REPO_NAME=$(echo $REMOTE_URL | sed 's/.*github.com[:/]\([^/]*\/[^/]*\).*/\1/')
    echo "Repository: $REPO_NAME"
    echo "Actions URL: https://github.com/$REPO_NAME/actions"
    echo "Releases URL: https://github.com/$REPO_NAME/releases"
fi

echo
print_info "=== Debug hoàn thành ==="
print_info "Nếu có lỗi, kiểm tra:"
echo "1. GitHub Actions logs"
echo "2. Release page trên GitHub"
echo "3. Binary files trong dist/"
echo "4. Version trong tutor/__about__.py"
