#!/bin/bash

# =======================================================
# Open edX Setup Script
# Script cài đặt và khởi chạy Open edX với Tutor
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

echo "🚀 Bắt đầu setup Open edX..."

# =======================================================
# MENU CHỌN PHẦN
# =======================================================

show_menu() {
    echo ""
    echo "=============================================="
    echo "📋 MENU CHỌN PHẦN CÀI ĐẶT"
    echo "=============================================="
    echo "1. Phần 1: Cài đặt cơ bản"
    echo "   - Tạo virtual environment"
    echo "   - Cài đặt Tutor[full]"
    echo "   - Cài đặt gói hệ thống"
    echo "   - Khởi chạy Open edX"
    echo ""
    echo "2. Phần 2: Cấu hình mounts và dev"
    echo "   - Thêm mounts cho edx-platform"
    echo "   - Thêm mounts cho frontend apps"
    echo "   - Khởi động dev environment"
    echo ""
    echo "3. Chạy tất cả (Phần 1 + Phần 2)"
    echo ""
    echo "4. Thoát"
    echo "=============================================="
}

# Khởi tạo biến
PART1_COMPLETED=false
PART2_COMPLETED=false

while true; do
    show_menu
    read -p "Chọn phần bạn muốn thực hiện (1-4): " -n 1 -r
    echo ""
    
    case $REPLY in
        1)
            echo ""
            print_status "PHẦN 1: Cài đặt cơ bản"
            echo ""
            
            # Kiểm tra xem đã chạy phần 1 chưa
            if [[ $PART1_COMPLETED == true ]]; then
                print_warning "Phần 1 đã được thực hiện trước đó!"
                read -p "Bạn có muốn chạy lại không? (y/n): " -n 1 -r
                echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    continue
                fi
            fi
    # =======================================================
    # BƯỚC 1: TẠO VIRTUAL ENVIRONMENT
    # =======================================================
    
    print_status "Tạo virtual environment..."
    
    # Xóa virtual environment cũ nếu tồn tại
    if [ -d "env" ]; then
        print_status "Xóa virtual environment cũ..."
        rm -rf env/
    fi
    
    # Tạo virtual environment mới
    python3 -m venv env
    print_success "Đã tạo virtual environment"
    
    # =======================================================
    # BƯỚC 2: KÍCH HOẠT VIRTUAL ENVIRONMENT
    # =======================================================
    
    print_status "Kích hoạt virtual environment..."
    source env/bin/activate
    print_success "Đã kích hoạt virtual environment"
    
    # =======================================================
    # BƯỚC 3: CÀI ĐẶT TUTOR
    # =======================================================
    
    print_status "Cài đặt Tutor với đầy đủ tính năng..."
    pip install "tutor[full]"
    print_success "Đã cài đặt Tutor"
    
    # =======================================================
    # BƯỚC 4: CÀI ĐẶT CÁC GÓI HỆ THỐNG
    # =======================================================
    
    print_status "Cài đặt các gói hệ thống cần thiết..."
    sudo apt install -y python3 python3-pip libyaml-dev
    print_success "Đã cài đặt các gói hệ thống"
    
            PART1_COMPLETED=true
            print_success "Phần 1 hoàn thành!"
            ;;
        2)
            echo ""
            print_status "PHẦN 2: Cấu hình mounts"
            echo ""
            
            # Kiểm tra xem đã chạy phần 2 chưa
            if [[ $PART2_COMPLETED == true ]]; then
                print_warning "Phần 2 đã được thực hiện trước đó!"
                read -p "Bạn có muốn chạy lại không? (y/n): " -n 1 -r
                echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    continue
                fi
            fi
            
            # Kiểm tra xem đã có virtual environment chưa
            if [[ $PART1_COMPLETED == false ]] && [ ! -d "env" ]; then
                print_error "Cần chạy Phần 1 trước hoặc có virtual environment!"
                continue
            fi
            
            # Kích hoạt virtual environment nếu chưa
            if [[ $PART1_COMPLETED == false ]]; then
                print_status "Kích hoạt virtual environment hiện có..."
                source env/bin/activate
                print_success "Đã kích hoạt virtual environment"
            fi
            
            print_status "Đang thêm mounts cho development..."
            
            # Hiển thị danh sách mounts hiện tại
            print_status "Danh sách mounts hiện tại:"
            tutor mounts list
            
            # Thêm các mounts cho development
            print_status "Thêm mount cho edx-platform..."
            tutor mounts add ../edx-platform
            
            print_status "Thêm mount cho frontend-app-authn..."
            tutor mounts add ../frontend-app-authn
            
            print_status "Thêm mount cho frontend-app-learner-dashboard..."
            tutor mounts add ../frontend-app-learner-dashboard
            
            print_status "Thêm mount cho frontend-app-learning..."
            tutor mounts add ../frontend-app-learning
            
            # Hiển thị danh sách mounts sau khi thêm
            print_status "Danh sách mounts sau khi thêm:"
            tutor mounts list
            
            print_success "Đã thêm tất cả mounts thành công!"
            
            print_status "Khởi động lại services với mounts mới..."
            tutor dev stop
            tutor dev launch
            
            print_status "Dừng services để cấu hình..."
            tutor dev stop
            
            print_status "Khởi động services ở chế độ detached..."
            tutor dev start -d
            
            PART2_COMPLETED=true
            print_success "Phần 2 hoàn thành!"
            ;;
        3)
            echo ""
            print_status "CHẠY TẤT CẢ (Phần 1 + Phần 2)"
            echo ""
            
            # Chạy phần 1
            if [[ $PART1_COMPLETED == false ]]; then
                print_status "Thực hiện Phần 1..."
                # Copy code phần 1 vào đây
                # =======================================================
                # BƯỚC 1: TẠO VIRTUAL ENVIRONMENT
                # =======================================================
                
                print_status "Tạo virtual environment..."
                
                # Xóa virtual environment cũ nếu tồn tại
                if [ -d "env" ]; then
                    print_status "Xóa virtual environment cũ..."
                    rm -rf env/
                fi
                
                # Tạo virtual environment mới
                python3 -m venv env
                print_success "Đã tạo virtual environment"
                
                # =======================================================
                # BƯỚC 2: KÍCH HOẠT VIRTUAL ENVIRONMENT
                # =======================================================
                
                print_status "Kích hoạt virtual environment..."
                source env/bin/activate
                print_success "Đã kích hoạt virtual environment"
                
                # =======================================================
                # BƯỚC 3: CÀI ĐẶT TUTOR
                # =======================================================
                
                print_status "Cài đặt Tutor với đầy đủ tính năng..."
                pip install "tutor[full]"
                print_success "Đã cài đặt Tutor"
                
                # =======================================================
                # BƯỚC 4: CÀI ĐẶT CÁC GÓI HỆ THỐNG
                # =======================================================
                
                print_status "Cài đặt các gói hệ thống cần thiết..."
                sudo apt install -y python3 python3-pip libyaml-dev
                print_success "Đã cài đặt các gói hệ thống"
                
                # =======================================================
                # BƯỚC 5: KHỞI CHẠY OPEN EDX
                # =======================================================
                
                print_status "Khởi chạy Open edX..."
                tutor dev launch
                print_success "Đã khởi chạy Open edX"
                
                PART1_COMPLETED=true
            else
                print_warning "Phần 1 đã được thực hiện trước đó"
            fi
            
            # Chạy phần 2
            if [[ $PART2_COMPLETED == false ]]; then
                print_status "Thực hiện Phần 2..."
                
                print_status "Đang thêm mounts cho development..."
                
                # Hiển thị danh sách mounts hiện tại
                print_status "Danh sách mounts hiện tại:"
                tutor mounts list
                
                # Thêm các mounts cho development
                print_status "Thêm mount cho edx-platform..."
                tutor mounts add ../edx-platform
                
                print_status "Thêm mount cho frontend-app-authn..."
                tutor mounts add ../frontend-app-authn
                
                print_status "Thêm mount cho frontend-app-learner-dashboard..."
                tutor mounts add ../frontend-app-learner-dashboard
                
                print_status "Thêm mount cho frontend-app-learning..."
                tutor mounts add ../frontend-app-learning
                
                # Hiển thị danh sách mounts sau khi thêm
                print_status "Danh sách mounts sau khi thêm:"
                tutor mounts list
                
                print_success "Đã thêm tất cả mounts thành công!"
                
                print_status "Khởi động lại services với mounts mới..."
                tutor dev stop
                tutor dev launch
                
                print_status "Dừng services để cấu hình..."
                tutor dev stop
                
                print_status "Khởi động services ở chế độ detached..."
                tutor dev start -d
                
                PART2_COMPLETED=true
            else
                print_warning "Phần 2 đã được thực hiện trước đó"
            fi
            
            print_success "Tất cả các phần đã hoàn thành!"
            ;;
        4)
            print_status "Thoát script..."
            break
            ;;
        *)
            print_error "Lựa chọn không hợp lệ. Vui lòng chọn 1-4."
            ;;
    esac
    
    # Hiển thị trạng thái hiện tại
    echo ""
    print_status "Trạng thái hiện tại:"
    if [[ $PART1_COMPLETED == true ]]; then
        echo "   ✅ Phần 1: Đã hoàn thành"
    else
        echo "   ❌ Phần 1: Chưa thực hiện"
    fi
    
    if [[ $PART2_COMPLETED == true ]]; then
        echo "   ✅ Phần 2: Đã hoàn thành"
    else
        echo "   ❌ Phần 2: Chưa thực hiện"
    fi
    echo ""
    
    # Hỏi có muốn tiếp tục không
    read -p "Nhấn Enter để tiếp tục hoặc 'q' để thoát: " -r
    if [[ $REPLY == "q" ]]; then
        break
    fi
done

# =======================================================
# HOÀN THÀNH
# =======================================================

echo ""
echo "=============================================="
echo "🎉 SETUP OPEN EDX HOÀN TẤT!"
echo "=============================================="
echo ""
echo "📋 Các bước đã thực hiện:"
if [[ $PART1_COMPLETED == true ]]; then
    echo "   ✅ Tạo virtual environment (env)"
    echo "   ✅ Kích hoạt virtual environment"
    echo "   ✅ Cài đặt Tutor[full]"
    echo "   ✅ Cài đặt python3, python3-pip, libyaml-dev"
else
    echo "   ⏭️  Phần 1: Chưa thực hiện"
fi

if [[ $PART2_COMPLETED == true ]]; then
    echo "   ✅ Thêm mounts cho edx-platform"
    echo "   ✅ Thêm mounts cho frontend apps"
    echo "   ✅ Khởi động dev environment"
else
    echo "   ⏭️  Phần 2: Chưa thực hiện"
fi
echo ""
echo "🔍 Kiểm tra trạng thái:"
echo "   tutor dev status"
echo ""
echo "📚 Truy cập Open edX:"
echo "   - LMS: http://local.overhang.io"
echo "   - Studio: http://studio.local.overhang.io"
echo ""
echo "🛠️  Các lệnh hữu ích:"
echo "   - Xem logs: tutor dev logs"
echo "   - Dừng services: tutor dev stop"
echo "   - Khởi động lại: tutor dev restart"
echo "   - Xem cấu hình: tutor config printroot"
echo ""
if [[ $PART2_COMPLETED == true ]]; then
    echo "📁 Mounts đã được cấu hình:"
    echo "   - EdX Platform: ../edx-platform"
    echo "   - Frontend Authn: ../frontend-app-authn"
    echo "   - Frontend Learner Dashboard: ../frontend-app-learner-dashboard"
    echo "   - Frontend Learning: ../frontend-app-learning"
fi
echo "=============================================="
