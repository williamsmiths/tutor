#!/bin/bash

# Script build DTU theme cho môi trường development
# Build local với version dev và không push lên DockerHub

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration for dev
DEV_VERSION="dtu.dev.$(date +%Y%m%d_%H%M%S)"
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

# Function to check prerequisites
check_prerequisites() {
    print_step "Kiểm tra prerequisites cho dev environment..."
    
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

# Function to configure DTU theme for dev
configure_dtu_theme_dev() {
    print_step "Cấu hình theme DTU cho dev environment..."
    
    # Set DTU Primary Color (Red) for dev
    if ! tutor config save --set "INDIGO_PRIMARY_COLOR=#D32F2F"; then
        print_error "Không thể set INDIGO_PRIMARY_COLOR"
        exit 1
    fi
    
    # Set dev-specific configurations
    print_info "Đang cấu hình các setting cho dev environment..."
    
    # Enable debug mode for development
    if ! tutor config save --set "OPENEDX_DEBUG_MODE=true"; then
        print_warning "Không thể set OPENEDX_DEBUG_MODE, tiếp tục..."
    fi
    
    # Set development environment
    if ! tutor config save --set "OPENEDX_ENVIRONMENT=development"; then
        print_warning "Không thể set OPENEDX_ENVIRONMENT, tiếp tục..."
    fi
    
    # Enable development features
    if ! tutor config save --set "ENABLE_DEVELOPMENT_FEATURES=true"; then
        print_warning "Không thể set ENABLE_DEVELOPMENT_FEATURES, tiếp tục..."
    fi
    
    print_success "Đã cấu hình theme DTU cho dev environment"
    print_success "  - INDIGO_PRIMARY_COLOR=#D32F2F"
    print_success "  - OPENEDX_DEBUG_MODE=true"
    print_success "  - OPENEDX_ENVIRONMENT=development"
}

# Function to build Open edX with Indigo theme using tutor for dev
build_openedx_dev() {
    print_step "Build Open edX image cho dev environment..."
    
    # Save current config
    if ! tutor config save; then
        print_warning "Không thể lưu cấu hình, tiếp tục với cấu hình hiện tại..."
    fi
    
    # Build Open edX dev image with indigo theme
    print_info "Bắt đầu build Open edX dev image (có thể mất 10-30 phút)..."
    print_info "Version dev: ${DEV_VERSION}"
    
    if ! tutor images build openedx-dev; then
        print_error "Build Open edX dev image thất bại"
        exit 1
    fi
    
    print_success "Build Open edX image cho dev environment thành công"
}

# Function to get current Open edX dev image tag from tutor
get_current_openedx_dev_tag() {
    print_info "Đang lấy tag hiện tại của Open edX dev image từ tutor..."
    
    # Get Open edX dev image tag from tutor
    local openedx_dev_tag=$(tutor images printtag openedx-dev 2>/dev/null || echo "")
    
    if [ -z "$openedx_dev_tag" ]; then
        print_error "Không thể lấy Open edX dev image tag từ tutor"
        return 1
    fi
    
    echo "$openedx_dev_tag"
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

# Function to tag and push image for dev
tag_and_push_dev() {
    local source_tag=$1
    local target_tag=$2
    local target_image="${TARGET_REGISTRY}/${IMAGE_NAME}:${target_tag}"
    
    print_info "Đang tag image cho dev: ${source_tag} → ${target_image}"
    if ! docker tag "$source_tag" "$target_image"; then
        print_error "Không thể tag image"
        exit 1
    fi
    print_success "Tag image thành công"
    
    print_info "Đang push image dev lên DockerHub: ${target_image}"
    if ! docker push "$target_image"; then
        print_error "Không thể push image"
        exit 1
    fi
    print_success "Push image dev thành công: ${target_image}"
}

# Function to show dev usage instructions
show_dev_instructions() {
    print_success "=== Build Dev Environment Hoàn thành! ==="
    echo ""
    print_info "Open edX image cho dev environment đã được build và push:"
    print_info "  - DockerHub: ${TARGET_REGISTRY}/${IMAGE_NAME}:${DEV_VERSION}"
    echo ""
    print_info "Để sử dụng image dev này:"
    print_info "1. Cấu hình tutor để sử dụng image dev:"
    print_info "   tutor config save --set DOCKER_IMAGE_OPENEDX_DEV=${TARGET_REGISTRY}/${IMAGE_NAME}:${DEV_VERSION}"
    echo ""
    print_info "2. Deploy dev environment:"
    print_info "   tutor dev launch"
    echo ""
    print_info "3. Để xem logs trong dev mode:"
    print_info "   tutor dev logs -f"
    echo ""
    print_info "4. Để stop dev environment:"
    print_info "   tutor dev stop"
    echo ""
    print_info "5. Để reset dev environment:"
    print_info "   tutor dev stop && tutor dev launch"
    echo ""
    print_info "6. Để pull image dev từ DockerHub:"
    print_info "   docker pull ${TARGET_REGISTRY}/${IMAGE_NAME}:${DEV_VERSION}"
    echo ""
    print_warning "Lưu ý: Image này dành cho development với debug mode và dev features enabled!"
}

# Main function
main() {
    print_info "=== DTU Theme Build Script cho Dev Environment ==="
    print_info "Build Open edX image với theme DTU (màu đỏ) cho development"
    echo ""
    
    print_info "Dev version: ${DEV_VERSION}"
    print_info "Target: ${TARGET_REGISTRY}/${IMAGE_NAME}:${DEV_VERSION}"
    echo ""
    
    # Check prerequisites
    check_prerequisites
    echo ""
    
    # Configure DTU theme for dev
    configure_dtu_theme_dev
    echo ""
    
    # Login to Docker Hub
    docker_login
    echo ""
    
    # Build Open edX with Indigo theme for dev
    print_step "=== Bước 1: Build Open edX image cho dev environment ==="
    build_openedx_dev
    echo ""
    
    # Get current Open edX dev tag
    local current_tag=$(get_current_openedx_dev_tag)
    if [ $? -ne 0 ]; then
        print_error "Không thể lấy tag hiện tại"
        exit 1
    fi
    
    print_info "Tag hiện tại của Open edX dev image: ${current_tag}"
    echo ""
    
    # Tag and push image for dev
    print_step "=== Bước 2: Tag và push image dev lên DockerHub ==="
    tag_and_push_dev "$current_tag" "$DEV_VERSION"
    echo ""
    
    # Show dev usage instructions
    show_dev_instructions
}

# Run main function
main "$@"
