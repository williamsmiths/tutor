#!/bin/bash

# =======================================================
# Open edX Admin Account Creation Script
# Script tạo tài khoản admin hoặc staff cho Open edX
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

echo "👤 Tạo tài khoản Admin/Staff cho Open edX..."

# =======================================================
# KIỂM TRA MÔI TRƯỜNG
# =======================================================

# Kiểm tra xem có virtual environment không
if [ ! -d "env" ]; then
    print_error "Không tìm thấy virtual environment (thư mục env/)"
    print_error "Vui lòng chạy setup.sh trước để tạo môi trường"
    exit 1
fi

# Kiểm tra xem có tutor không
if ! command -v tutor &> /dev/null; then
    print_error "Không tìm thấy lệnh tutor"
    print_error "Vui lòng kích hoạt virtual environment và cài đặt tutor"
    exit 1
fi

# Bỏ qua kiểm tra services - tập trung vào tạo tài khoản
print_status "Tập trung vào tạo tài khoản..."

# =======================================================
# MENU CHỌN LOẠI TÀI KHOẢN
# =======================================================

show_menu() {
    echo ""
    echo "=============================================="
    echo "👤 TẠO TÀI KHOẢN TỰ ĐỘNG"
    echo "=============================================="
    echo "1. Tạo tài khoản Admin: admin@admin.com / admin123"
    echo "2. Tạo tài khoản Staff: user@user.com / user123"
    echo "3. Tạo cả 2 tài khoản"
    echo "4. Thoát"
    echo "=============================================="
}

# =======================================================
# HÀM TẠO TÀI KHOẢN
# =======================================================

create_admin_user() {
    echo ""
    print_status "TẠO TÀI KHOẢN ADMIN (SUPERUSER)"
    echo ""
    
    # Thông tin tài khoản cố định
    email="admin@admin.com"
    password="admin123"
    
    print_status "Đang tạo tài khoản admin..."
    print_status "Email: $email"
    print_status "Password: $password"
    
    # Tạo superuser mới với password
    print_status "Tạo tài khoản admin với password..."
    
    # Sử dụng lệnh tạo superuser tương tác
    printf "$email\n$password\n$password\n" | tutor dev run lms ./manage.py lms createsuperuser --username="admin"
    
    if [ $? -eq 0 ]; then
        print_success "Đã tạo tài khoản admin thành công!"
        print_status "Email: $email"
        print_status "Username: admin"
        print_status "Password: $password"
    else
        print_warning "Có thể tài khoản đã tồn tại. Đang cập nhật password..."
        # Cập nhật password cho user hiện có
        echo "from django.contrib.auth.models import User; u = User.objects.get(username='admin'); u.set_password('$password'); u.is_superuser = True; u.is_staff = True; u.save(); print('Password updated successfully')" | tutor dev run lms ./manage.py lms shell
        print_success "Đã cập nhật tài khoản admin thành công!"
        print_status "Email: $email"
        print_status "Username: admin"
        print_status "Password: $password"
    fi
}

create_staff_user() {
    echo ""
    print_status "TẠO TÀI KHOẢN STAFF"
    echo ""
    
    # Thông tin tài khoản cố định
    email="user@user.com"
    password="user123"
    
    print_status "Đang tạo tài khoản staff..."
    print_status "Email: $email"
    print_status "Password: $password"
    
    # Tạo staff user mới với password
    print_status "Tạo tài khoản staff với password..."
    
    # Sử dụng lệnh tạo superuser tương tác
    printf "$email\n$password\n$password\n" | tutor dev run lms ./manage.py lms createsuperuser --username="user"
    
    if [ $? -eq 0 ]; then
        # Set quyền staff cho user vừa tạo
        echo "from django.contrib.auth.models import User; u = User.objects.get(username='user'); u.is_staff = True; u.is_superuser = False; u.save(); print('Staff permissions set successfully')" | tutor dev run lms ./manage.py lms shell
        print_success "Đã tạo tài khoản staff thành công!"
        print_status "Email: $email"
        print_status "Username: user"
        print_status "Password: $password"
    else
        print_warning "Có thể tài khoản đã tồn tại. Đang cập nhật password..."
        # Cập nhật password và quyền staff cho user hiện có
        echo "from django.contrib.auth.models import User; u = User.objects.get(username='user'); u.set_password('$password'); u.is_staff = True; u.is_superuser = False; u.save(); print('Password and permissions updated successfully')" | tutor dev run lms ./manage.py lms shell
        print_success "Đã cập nhật tài khoản staff thành công!"
        print_status "Email: $email"
        print_status "Username: user"
        print_status "Password: $password"
    fi
}

# =======================================================
# MENU CHÍNH
# =======================================================

while true; do
    show_menu
    read -p "Chọn loại tài khoản bạn muốn tạo (1-4): " -n 1 -r
    echo ""
    
    case $REPLY in
        1)
            create_admin_user
            ;;
        2)
            create_staff_user
            ;;
        3)
            print_status "Tạo cả 2 tài khoản..."
            create_admin_user
            create_staff_user
            ;;
        4)
            print_status "Thoát script..."
            break
            ;;
        *)
            print_error "Lựa chọn không hợp lệ. Vui lòng chọn 1-4."
            ;;
    esac
    
    echo ""
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
echo "🎉 TẠO TÀI KHOẢN HOÀN TẤT!"
echo "=============================================="
echo ""
echo "📚 Truy cập Open edX:"
echo "   - LMS: http://local.overhang.io"
echo "   - Studio: http://studio.local.overhang.io"
echo ""
echo "🔐 Đăng nhập với tài khoản vừa tạo"
echo ""
echo "🛠️  Các lệnh hữu ích:"
echo "   - Xem danh sách users: tutor dev run lms ./manage.py lms shell"
echo "   - Đổi password: tutor dev run lms ./manage.py lms changepassword <email>"
echo "   - Xem logs: tutor dev logs"
echo ""
echo "=============================================="
