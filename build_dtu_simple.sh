#!/bin/bash

# Script đơn giản để build DTU theme với màu đỏ và push lên DockerHub
# Chỉ set INDIGO_PRIMARY_COLOR=#D32F2F và build với version dtu.v1.0.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TARGET_REGISTRY="konghuan42"
IMAGE_NAME="openedx"
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

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1" 1>&2
}

# Function to get latest DTU version from Docker Hub
get_latest_dtu_version() {
    print_info "Đang lấy version DTU mới nhất từ Docker Hub cho ${TARGET_REGISTRY}/${IMAGE_NAME}..."
    
    # Get tags from Docker Hub API
    local response=$(curl -s "${DOCKERHUB_API_URL}/${TARGET_REGISTRY}/${IMAGE_NAME}/tags/?page_size=100" 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$response" ]; then
        print_error "Không thể kết nối đến Docker Hub API"
        return 1
    fi
    
    # Look for DTU tags in form dtu.vMAJOR.MINOR.PATCH
    local dtu_tags=$(echo "$response" | grep -o '"name":"dtu\.v[0-9]\+\.[0-9]\+\.[0-9]\+"' | grep -o 'dtu\.v[0-9]\+\.[0-9]\+\.[0-9]\+' | sort -V)
    if [ -n "$dtu_tags" ]; then
        echo "$dtu_tags" | tail -1
        return 0
    fi

    # If no DTU tags found, start with dtu.v1.0.0
    echo "dtu.v1.0.0"
    return 0
}

# Function to increment DTU version
increment_dtu_version() {
    local version=$1
    local major minor patch

    # Parse dtu.vMAJOR.MINOR.PATCH
    if [[ $version =~ ^dtu\.v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        major=${BASH_REMATCH[1]}
        minor=${BASH_REMATCH[2]}
        patch=${BASH_REMATCH[3]}
    else
        print_error "Không thể parse DTU version: $version"
        return 1
    fi

    patch=$((patch + 1))
    echo "dtu.v${major}.${minor}.${patch}"
}

# Function to check prerequisites
check_prerequisites() {
    print_step "Kiểm tra prerequisites..."
    
    # Check Docker
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker không chạy hoặc không có quyền truy cập"
        exit 1
    fi
    print_success "Docker đang chạy"
    
    # Check Tutor
    if ! command -v tutor &> /dev/null; then
        print_error "Tutor không được cài đặt hoặc không có trong PATH"
        exit 1
    fi
    print_success "Tutor đã được cài đặt"
    
    # Check if indigo plugin is available
    if ! tutor plugins list | grep -q "indigo"; then
        print_warning "Plugin indigo chưa được enable, đang enable..."
        if ! tutor plugins enable indigo; then
            print_error "Không thể enable plugin indigo"
            exit 1
        fi
        print_success "Plugin indigo đã được enable"
    else
        print_success "Plugin indigo đã được enable"
    fi
}

# Function to configure DTU theme
configure_dtu_theme() {
    print_step "Cấu hình theme DTU với màu đỏ..."
    
    # Set DTU Primary Color (Red)
    if ! tutor config save --set "INDIGO_PRIMARY_COLOR=#D32F2F"; then
        print_error "Không thể set INDIGO_PRIMARY_COLOR"
        exit 1
    fi
    
    print_success "Đã set INDIGO_PRIMARY_COLOR=#D32F2F"
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

# Function to build Open edX with Indigo theme using tutor
build_openedx_with_tutor() {
    print_step "Build Open edX image với theme Indigo..."
    
    # Save current config
    if ! tutor config save; then
        print_warning "Không thể lưu cấu hình, tiếp tục với cấu hình hiện tại..."
    fi
    
    # Build Open edX image with indigo theme
    print_info "Bắt đầu build Open edX image (có thể mất 10-30 phút)..."
    if ! tutor images build openedx; then
        print_error "Build Open edX image thất bại"
        exit 1
    fi
    
    print_success "Build Open edX image với theme Indigo thành công"
}

# Function to get current Open edX image tag from tutor
get_current_openedx_tag() {
    print_info "Đang lấy tag hiện tại của Open edX image từ tutor..."
    
    # Get Open edX image tag from tutor
    local openedx_tag=$(tutor images printtag openedx 2>/dev/null || echo "")
    
    if [ -z "$openedx_tag" ]; then
        print_error "Không thể lấy Open edX image tag từ tutor"
        return 1
    fi
    
    echo "$openedx_tag"
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
    print_info "=== DTU Theme Build Script ==="
    print_info "Build Open edX image với theme DTU (màu đỏ) và push lên DockerHub"
    echo ""
    
    # Get latest DTU version and increment it
    local latest_version=$(get_latest_dtu_version)
    if [ $? -ne 0 ]; then
        print_error "Không thể lấy version mới nhất"
        exit 1
    fi
    
    local new_version=$(increment_dtu_version "$latest_version")
    if [ $? -ne 0 ]; then
        print_error "Không thể tăng version"
        exit 1
    fi
    
    print_info "Version hiện tại: ${latest_version}"
    print_info "Version mới sẽ là: ${new_version}"
    print_info "Target: ${TARGET_REGISTRY}/${IMAGE_NAME}:${new_version}"
    echo ""
    
    # Check prerequisites
    check_prerequisites
    echo ""
    
    # Configure DTU theme
    configure_dtu_theme
    echo ""
    
    # Login to Docker Hub
    docker_login
    echo ""
    
    # Build Open edX with Indigo theme
    print_step "=== Bước 1: Build Open edX image với theme DTU ==="
    build_openedx_with_tutor
    echo ""
    
    # Get current Open edX tag
    local current_tag=$(get_current_openedx_tag)
    if [ $? -ne 0 ]; then
        print_error "Không thể lấy tag hiện tại"
        exit 1
    fi
    
    print_info "Tag hiện tại của Open edX image: ${current_tag}"
    echo ""
    
    # Tag and push images
    print_step "=== Bước 2: Tag và push image lên DockerHub ==="
    tag_and_push "$current_tag" "$new_version"
    echo ""
    
    print_success "=== Hoàn thành! ==="
    print_info "Open edX image với theme DTU đã được build và push:"
    print_info "  - ${TARGET_REGISTRY}/${IMAGE_NAME}:${new_version}"
    echo ""
    print_info "Bạn có thể cấu hình tutor để sử dụng image mới:"
    print_info "tutor config save --set DOCKER_IMAGE_OPENEDX=${TARGET_REGISTRY}/${IMAGE_NAME}:${new_version}"
    echo ""
    print_info "Để deploy image mới:"
    print_info "tutor local start -d"
}

# Run main function
main "$@"
