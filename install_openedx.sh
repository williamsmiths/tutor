#!/bin/bash

# =======================================================
# Open edX Tutor Installation Script
# Tự động xóa hết và cài lại Open edX từ đầu
# =======================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
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

echo "🚀 Bắt đầu cài đặt Open edX..."

# =======================================================
# KIỂM TRA YÊU CẦU HỆ THỐNG
# =======================================================

print_status "Kiểm tra Docker và quyền sudo..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker chưa được cài đặt. Vui lòng cài Docker trước!"
    exit 1
fi

# Check if we can run Docker with sudo
if ! sudo docker --version &> /dev/null; then
    print_error "Không thể chạy Docker với sudo. Kiểm tra quyền!"
    exit 1
fi

# Install python3-venv if not available
print_status "Cài đặt python3-venv..."
sudo apt update -qq
sudo apt install -y python3-venv python3-full

# Add user to docker group if not already in it
if ! groups $USER | grep -q '\bdocker\b'; then
    print_status "Thêm user vào docker group..."
    sudo usermod -aG docker $USER
    print_success "Đã thêm user vào docker group. Cần logout/login lại sau khi script chạy xong."
fi

print_success "Docker và sudo đã sẵn sàng"

# =======================================================
# BƯỚC 1: XÓA HẾT MỌI THỨ
# =======================================================

print_status "Đang xóa hết containers, images, volumes..."

# Stop all containers
sudo docker stop $(sudo docker ps -aq) 2>/dev/null || true

# Remove all containers
sudo docker rm $(sudo docker ps -aq) 2>/dev/null || true

# Remove all images
sudo docker rmi $(sudo docker images -q) 2>/dev/null || true

# Remove all volumes
sudo docker volume prune -f 2>/dev/null || true

# Remove all networks
sudo docker network prune -f 2>/dev/null || true

# System cleanup
sudo docker system prune -af --volumes 2>/dev/null || true

print_success "Đã xóa hết Docker containers, images và volumes"

# =======================================================
# BƯỚC 2: XÓA CẤU HÌNH TUTOR
# =======================================================

print_status "Đang xóa cấu hình Tutor cũ..."

# Remove Tutor config directories
sudo rm -rf ~/.local/share/tutor/ 2>/dev/null || true
sudo rm -rf /root/.local/share/tutor/ 2>/dev/null || true
rm -rf ~/.local/share/tutor/ 2>/dev/null || true

# Remove virtual environment
if [ -d "venv" ]; then
    sudo rm -rf venv/ 2>/dev/null || rm -rf venv/ 2>/dev/null || true
    print_success "Đã xóa virtual environment"
fi

print_success "Đã xóa cấu hình Tutor"

# =======================================================
# BƯỚC 3: TẠO LẠI VIRTUAL ENVIRONMENT
# =======================================================

print_status "Đang tạo virtual environment mới..."

python3 -m venv venv
source venv/bin/activate

# Upgrade pip trong venv
./venv/bin/pip install --upgrade pip

print_success "Đã tạo virtual environment"

# =======================================================
# BƯỚC 4: CÀI ĐẶT TUTOR
# =======================================================

print_status "Đang cài đặt Tutor 20.0.0..."

./venv/bin/pip install "tutor[full]==20.0.0"

print_success "Đã cài đặt Tutor"

# =======================================================
# BƯỚC 5: CẤU HÌNH TUTOR
# =======================================================

print_status "Đang cấu hình Tutor..."

# Auto-configure without interactive prompts
# Auto-configure with localhost and ports
./venv/bin/tutor config save 
  --set PLATFORM_NAME="hoc tien tuc" 
  --set CONTACT_EMAIL="conghuancse@gmail.com" 
  --set LMS_HOST="localhost:1433" 
  --set CMS_HOST="localhost:1434" 
  --set ENABLE_HTTPS=false 
  --set LANGUAGE_CODE="en" 
  --set CADDY_HTTP_PORT=1433 
  --set CADDY_HTTP_PORT_CMS=1434

print_success "Đã cấu hình Tutor với ports"

# =======================================================
# BƯỚC 6: CẬP NHẬT /etc/hosts
# =======================================================

print_status "Đang cập nhật /etc/hosts..."

# Remove old entries
sudo sed -i '/local\.openedx\.io/d' /etc/hosts
sudo sed -i '/studio\.local\.openedx\.io/d' /etc/hosts
sudo sed -i '/meilisearch\.local\.openedx\.io/d' /etc/hosts
sudo sed -i '/apps\.local\.openedx\.io/d' /etc/hosts

# Add new entries
echo "127.0.0.1 local.openedx.io" | sudo tee -a /etc/hosts
echo "127.0.0.1 studio.local.openedx.io" | sudo tee -a /etc/hosts
echo "127.0.0.1 meilisearch.local.openedx.io" | sudo tee -a /etc/hosts
echo "127.0.0.1 apps.local.openedx.io" | sudo tee -a /etc/hosts

print_success "Đã cập nhật /etc/hosts"

# =======================================================
# BƯỚC 7: KHỞI CHẠY OPEN EDX
# =======================================================

print_status "Đang khởi chạy Open edX... (có thể mất 10-15 phút)"

# Check if user is in docker group, if not use sudo
if groups | grep -q '\bdocker\b'; then
    ./venv/bin/tutor local launch --non-interactive
else
    sudo -E ./venv/bin/tutor local launch --non-interactive
fi

print_success "Đã khởi chạy Open edX"

# =======================================================
# BƯỚC 8: TẠO TÀI KHOẢN ADMIN
# =======================================================

print_status "Đang tạo tài khoản admin..."

# Check if user is in docker group, if not use sudo
if groups | grep -q '\bdocker\b'; then
    ./venv/bin/tutor local do createuser --staff --superuser admin admin@duytan.edu.vn <<EOF
123123
123123
EOF
else
    sudo -E ./venv/bin/tutor local do createuser --staff --superuser admin admin@example.com <<EOF
123123
123123
EOF
fi

print_success "Đã tạo tài khoản admin"

# =======================================================
# BƯỚC 9: KIỂM TRA TRẠNG THÁI
# =======================================================

print_status "Đang kiểm tra trạng thái..."

sleep 10

LMS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:1433 || echo "000")
STUDIO_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:1434 || echo "000")

# =======================================================
# HOÀN THÀNH
# =======================================================

echo ""
echo "=============================================="
echo "🎉 CÀI ĐẶT OPEN EDX HOÀN TẤT!"
echo "=============================================="
echo ""
echo "📚 LMS (Learning Management System):"
echo "   URL: http://localhost:1433"
echo "   Status: $LMS_STATUS"
echo ""
echo "🏫 Studio (Course Management):"
echo "   URL: http://localhost:1434" 
echo "   Status: $STUDIO_STATUS"
echo ""
echo "👤 Admin Account:"
echo "   Username: admin"
echo "   Password: 123123"
echo "   Email: admin@example.com"
echo ""
echo "🔍 Other Services:"
echo "   Meilisearch: http://meilisearch.local.openedx.io"
echo "   Apps: http://apps.local.openedx.io"
echo ""
echo "📋 Useful Commands:"
echo "   Kiểm tra status: sudo $(which tutor) local status"
echo "   Xem logs: sudo $(which tutor) local logs [service]"
echo "   Dừng: sudo $(which tutor) local stop" 
echo "   Khởi động: sudo $(which tutor) local start"
echo ""

if [ "$LMS_STATUS" = "200" ] && [ "$STUDIO_STATUS" = "302" ]; then
    print_success "✅ Tất cả services đang hoạt động bình thường!"
else
    print_warning "⚠️  Một số services có thể cần thời gian để khởi động hoàn toàn"
fi

echo ""
echo "🚀 Bạn có thể truy cập:"
echo "   - LMS: http://localhost:1433"
echo "   - Studio: http://localhost:1434"
echo "=============================================="
