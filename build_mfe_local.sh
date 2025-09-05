#!/bin/bash

# Script để build MFE image từ source code local và push lên DockerHub
# Từ overhangio/openedx-mfe:20.0.0-indigo → konghuan42/openedx-mfe:20.0.0-indigo
# Với auto versioning từ Docker Hub

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SOURCE_REGISTRY="overhangio"
TARGET_REGISTRY="konghuan42"
IMAGE_NAME="openedx-mfe"
DOCKERHUB_API_URL="https://hub.docker.com/v2/repositories"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1" 1>&2
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" 1>&2
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" 1>&2
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" 1>&2
}

# Function to get latest version from Docker Hub
get_latest_version() {
    local registry=$1
    local image=$2
    
    print_info "Đang lấy version mới nhất từ Docker Hub cho ${registry}/${image}..."
    
    # Get tags from Docker Hub API
    local response=$(curl -s "${DOCKERHUB_API_URL}/${registry}/${image}/tags/?page_size=100" 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$response" ]; then
        print_error "Không thể kết nối đến Docker Hub API"
        return 1
    fi
    
    # Prefer tags in form vMAJOR.MINOR.PATCH
    local vtags=$(echo "$response" | grep -o '"name":"v[0-9]\+\.[0-9]\+\.[0-9]\+"' | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | sort -V)
    if [ -n "$vtags" ]; then
        echo "$vtags" | tail -1
        return 0
    fi

    # Fallback: tags like MAJOR.MINOR.PATCH or MAJOR.MINOR.PATCH-suffix
    local rawtags=$(echo "$response" | grep -o '"name":"[0-9]\+\.[0-9]\+\.[0-9]\+\(-[a-zA-Z0-9_.-]\\+\)\?"' | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\(\-[a-zA-Z0-9_.-]\+\)\?' | sort -V)
    if [ -n "$rawtags" ]; then
        local last=$(echo "$rawtags" | tail -1)
        # Strip any suffix and add leading v
        echo "v${last%%-*}"
        return 0
    fi

    # Nothing found
    return 1
}

# Function to increment version
increment_version() {
    local version=$1
    local vprefix=""
    local major minor patch

    # Accept vMAJOR.MINOR.PATCH
    if [[ $version =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        vprefix="v"
        major=${BASH_REMATCH[1]}
        minor=${BASH_REMATCH[2]}
        patch=${BASH_REMATCH[3]}
    # Accept MAJOR.MINOR.PATCH(-suffix)
    elif [[ $version =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)(-.+)?$ ]]; then
        vprefix="v"
        major=${BASH_REMATCH[1]}
        minor=${BASH_REMATCH[2]}
        patch=${BASH_REMATCH[3]}
    else
        print_error "Không thể parse version: $version"
        return 1
    fi

    patch=$((patch + 1))
    echo "${vprefix}${major}.${minor}.${patch}"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker không chạy hoặc không có quyền truy cập"
        exit 1
    fi
}

# Function to check if tutor is available
check_tutor() {
    if ! command -v tutor &> /dev/null; then
        print_error "Tutor không được cài đặt hoặc không có trong PATH"
        exit 1
    fi
}

# Function to login to Docker Hub
docker_login() {
    print_info "Đang đăng nhập vào Docker Hub..."
    if ! docker login; then
        print_error "Đăng nhập Docker Hub thất bại"
        exit 1
    fi
    print_success "Đăng nhập Docker Hub thành công"
}

# Function to build MFE using tutor
build_mfe_with_tutor() {
    print_info "Đang build MFE image bằng tutor..."
    
    # Build MFE image
    if ! tutor images build mfe; then
        print_error "Build MFE image thất bại"
        exit 1
    fi
    
    print_success "Build MFE image thành công"
}

# Function to get current MFE image tag from tutor
get_current_mfe_tag() {
    print_info "Đang lấy tag hiện tại của MFE image từ tutor..."
    
    # Get MFE image tag from tutor
    local mfe_tag=$(tutor images printtag mfe 2>/dev/null || echo "")
    
    if [ -z "$mfe_tag" ]; then
        print_error "Không thể lấy MFE image tag từ tutor"
        return 1
    fi
    
    echo "$mfe_tag"
}

# Function to tag and push image
tag_and_push() {
    local source_tag=$1
    local target_tag=$2
    local target_image="${TARGET_REGISTRY}/${IMAGE_NAME}:${target_tag}"
    
    print_info "Đang tag image: ${source_tag} → ${target_image}"
    if ! docker tag "$source_tag" "$target_image"; then
        print_error "Không thể tag image"
        exit 1
    fi
    print_success "Tag image thành công"
    
    print_info "Đang push image: ${target_image}"
    if ! docker push "$target_image"; then
        print_error "Không thể push image"
        exit 1
    fi
    print_success "Push image thành công: ${target_image}"
}

# Main function
main() {
    print_info "=== MFE Local Build Script ==="
    print_info "Build MFE image từ source code local và push lên DockerHub"
    print_info "Target: ${TARGET_REGISTRY}/${IMAGE_NAME}"
    echo ""
    
    # Check prerequisites
    check_docker
    check_tutor
    
    # Get latest version from TARGET registry (where we push)
    local latest_version=$(get_latest_version "$TARGET_REGISTRY" "$IMAGE_NAME")
    if [ $? -ne 0 ] || [ -z "$latest_version" ]; then
        # Fallback to base version from source image tag by stripping suffix
        print_warning "Không tìm thấy version trên repo đích, dùng fallback từ source: 20.0.0-indigo → v20.0.0"
        latest_version="v20.0.0"
    fi
    
    print_info "Version mới nhất từ ${TARGET_REGISTRY}/${IMAGE_NAME}: ${latest_version}"
    
    # Increment version
    local new_version=$(increment_version "$latest_version")
    if [ $? -ne 0 ]; then
        print_error "Không thể tăng version"
        exit 1
    fi
    
    print_info "Version mới sẽ là: ${new_version}"
    echo ""
    
    # Login to Docker Hub
    docker_login
    echo ""
    
    # Build MFE with tutor
    print_info "=== Bước 1: Build MFE image từ source code ==="
    build_mfe_with_tutor
    echo ""
    
    # Get current MFE tag
    local current_tag=$(get_current_mfe_tag)
    if [ $? -ne 0 ]; then
        print_error "Không thể lấy tag hiện tại"
        exit 1
    fi
    
    print_info "Tag hiện tại của MFE image: ${current_tag}"
    echo ""
    
    # Tag and push images
    print_info "=== Bước 2: Tag và push image incremented version lên DockerHub ==="
    tag_and_push "$current_tag" "$new_version"
    echo ""
    
    print_success "=== Hoàn thành! ==="
    print_info "MFE image đã được build và push:"
    print_info "  - ${TARGET_REGISTRY}/${IMAGE_NAME}:${new_version}"
    echo ""
    print_info "Bạn có thể cấu hình tutor để sử dụng image mới:"
    print_info "tutor config save --set DOCKER_IMAGE_MFE=${TARGET_REGISTRY}/${IMAGE_NAME}:${latest_version}"
}

# Check if version is provided as argument
if [ $# -eq 1 ]; then
    VERSION=$1
    print_info "Sử dụng version được cung cấp: ${VERSION}"
    
    check_docker
    check_tutor
    docker_login
    
    # Build MFE with tutor
    build_mfe_with_tutor
    
    # Get current MFE tag and push
    current_tag=$(get_current_mfe_tag)
    if [ $? -eq 0 ]; then
        tag_and_push "$current_tag" "$VERSION"
        
        # Also create incremented version
        new_version=$(increment_version "$VERSION")
        if [ $? -eq 0 ]; then
            tag_and_push "$current_tag" "$new_version"
            print_info "Images đã được push:"
            print_info "  - ${TARGET_REGISTRY}/${IMAGE_NAME}:${VERSION}"
            print_info "  - ${TARGET_REGISTRY}/${IMAGE_NAME}:${new_version}"
        fi
    fi
else
    # Run main function with auto versioning
    main "$@"
fi
