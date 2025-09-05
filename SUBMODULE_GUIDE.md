# Hướng dẫn quản lý Submodules

## Vấn đề thường gặp

Khi pull submodules, bạn có thể gặp các vấn đề sau:
- Submodules không ở đúng branch `release/teak`
- Hiển thị tên branch dài `edx-abolger/ent-4262-bulk-enrollment-fix-8838-g2ec6f1ea454`
- Files không cần thiết xuất hiện trong submodules

## Giải pháp

### 1. Script `fix-submodules.sh`
Sử dụng để fix submodules về đúng branch `release/teak`:

```bash
./fix-submodules.sh
```

**Chức năng:**
- Update tất cả submodules
- Chuyển về branch `release/teak`
- Dọn dẹp files không cần thiết
- Hiển thị trạng thái cuối cùng

### 2. Script `pull-submodules.sh`
Sử dụng để pull submodules một cách an toàn:

```bash
./pull-submodules.sh
```

**Chức năng:**
- Pull main repository
- Update submodules
- Chuyển về branch `release/teak`
- Dọn dẹp files không cần thiết
- Hiển thị trạng thái cuối cùng

## Cách sử dụng

### Lần đầu tiên:
```bash
# Clone repository với submodules
git clone --recursive <repository-url>
cd tutor-edx

# Fix submodules
./fix-submodules.sh
```

### Mỗi lần pull:
```bash
# Sử dụng script an toàn
./pull-submodules.sh
```

### Chỉ fix submodules:
```bash
# Khi chỉ cần fix submodules
./fix-submodules.sh
```

## Kiểm tra trạng thái

```bash
# Kiểm tra trạng thái submodules
git submodule status

# Kiểm tra branch hiện tại của từng submodule
git submodule foreach 'echo "=== $(basename $(pwd)) ===" && git branch'
```

## Lưu ý

- Scripts sẽ tự động chuyển tất cả submodules về branch `release/teak`
- Files không cần thiết sẽ được dọn dẹp tự động
- Nếu có lỗi, hãy chạy lại script
- Luôn backup trước khi chạy scripts nếu có thay đổi quan trọng

## Troubleshooting

### Nếu script không chạy được:
```bash
# Cấp quyền thực thi
chmod +x fix-submodules.sh
chmod +x pull-submodules.sh
```

### Nếu submodule vẫn hiển thị tên branch dài:
Đây là hành vi bình thường của Git. Submodule đã ở đúng branch `release/teak`, chỉ là cách hiển thị khác nhau.

### Nếu có conflict:
```bash
# Reset submodule về trạng thái sạch
git submodule foreach 'git reset --hard HEAD'
./fix-submodules.sh
```
