# MFE Local Build Script

Script để build MFE (Micro Frontend) image từ source code local và push lên DockerHub với auto versioning.

## Mô Tả

Script `build_mfe_local.sh` sẽ:
1. **Build MFE image từ source code local** bằng `tutor images build mfe`
2. **Tự động lấy version mới nhất** từ Docker Hub (`overhangio/openedx-mfe`)
3. **Tự động tăng version** (patch + 1)
4. **Tag và push** lên DockerHub với tên `konghuan42/openedx-mfe`

## Cách Sử Dụng

### Auto Versioning (Khuyến nghị)
```bash
./build_mfe_local.sh
```

### Với Version Cụ Thể
```bash
./build_mfe_local.sh 20.0.0-indigo
```

## Yêu Cầu Hệ Thống

- Docker đã cài đặt và chạy
- Tutor đã cài đặt và cấu hình
- Quyền truy cập Docker Hub
- `curl` (cho auto versioning)

## Cài Đặt Dependencies

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install curl

# CentOS/RHEL
sudo yum install curl

# macOS
brew install curl
```

## Quy Trình Build

### Bước 1: Đăng nhập Docker Hub
```bash
docker login
```

### Bước 2: Chạy Script
```bash
./build_mfe_local.sh
```

### Bước 3: Cấu hình Tutor (Tùy chọn)
Sau khi push images thành công, bạn có thể cấu hình tutor:

```bash
tutor config save --set DOCKER_IMAGE_MFE=konghuan42/openedx-mfe:20.0.0-indigo
```

## Auto Versioning

Script sẽ tự động:
1. Lấy version mới nhất từ Docker Hub (`overhangio/openedx-mfe`)
2. Tăng patch version (ví dụ: `20.0.0-indigo` → `20.0.1-indigo`)
3. Build MFE image từ source code local
4. Tag và push cả 2 versions lên `konghuan42/openedx-mfe`

## Ví Dụ Output

```
=== MFE Local Build Script ===
Build MFE image từ source code local và push lên DockerHub
Target: konghuan42/openedx-mfe

[INFO] Đang lấy version mới nhất từ Docker Hub cho overhangio/openedx-mfe...
[INFO] Version mới nhất từ overhangio/openedx-mfe: 20.0.0-indigo
[INFO] Version mới sẽ là: 20.0.1-indigo

[INFO] Đang đăng nhập vào Docker Hub...
Login Succeeded
[SUCCESS] Đăng nhập Docker Hub thành công

=== Bước 1: Build MFE image từ source code ===
[INFO] Đang build MFE image bằng tutor...
Building image docker.io/overhangio/openedx-mfe:20.0.0-indigo
[SUCCESS] Build MFE image thành công

[INFO] Tag hiện tại của MFE image: docker.io/overhangio/openedx-mfe:20.0.0-indigo

=== Bước 2: Tag và push images lên DockerHub ===
[INFO] Đang tag image: docker.io/overhangio/openedx-mfe:20.0.0-indigo → konghuan42/openedx-mfe:20.0.0-indigo
[SUCCESS] Tag image thành công
[INFO] Đang push image: konghuan42/openedx-mfe:20.0.0-indigo
[SUCCESS] Push image thành công: konghuan42/openedx-mfe:20.0.0-indigo

[INFO] Đang tag image: docker.io/overhangio/openedx-mfe:20.0.0-indigo → konghuan42/openedx-mfe:20.0.1-indigo
[SUCCESS] Tag image thành công
[INFO] Đang push image: konghuan42/openedx-mfe:20.0.1-indigo
[SUCCESS] Push image thành công: konghuan42/openedx-mfe:20.0.1-indigo

=== Hoàn thành! ===
[INFO] MFE images đã được build và push:
[INFO]   - konghuan42/openedx-mfe:20.0.0-indigo
[INFO]   - konghuan42/openedx-mfe:20.0.1-indigo

[INFO] Bạn có thể cấu hình tutor để sử dụng image mới:
[INFO] tutor config save --set DOCKER_IMAGE_MFE=konghuan42/openedx-mfe:20.0.0-indigo
```

## Troubleshooting

### Lỗi Docker không chạy
```bash
sudo systemctl start docker
sudo usermod -aG docker $USER
# Logout và login lại
```

### Lỗi Tutor không tìm thấy
```bash
# Cài đặt tutor
pip install tutor

# Hoặc kiểm tra PATH
which tutor
```

### Lỗi Docker Hub API
- Kiểm tra kết nối internet
- Thử lại sau vài phút
- Script sẽ fallback về version mặc định

### Lỗi Permission Denied
```bash
chmod +x build_mfe_local.sh
```

### Lỗi Docker Login
```bash
docker logout
docker login
```

### Lỗi Build MFE
```bash
# Kiểm tra tutor config
tutor config printroot

# Kiểm tra MFE plugin
tutor plugins list

# Build manual để debug
tutor images build mfe --no-cache
```

## Cấu Trúc Files

```
tutor-edx/
├── build_mfe_local.sh      # Script build MFE chính
├── MFE_BUILD_README.md     # File hướng dẫn này
├── frontend-app-learning/  # MFE Learning app
├── frontend-app-authn/     # MFE Authn app
└── frontend-app-learner-dashboard/  # MFE Learner Dashboard app
```

## Lưu Ý Quan Trọng

- **Script build từ source code local**, không phải pull image có sẵn
- **MFE chỉ có 1 image duy nhất** chứa tất cả frontend apps
- **Auto versioning** dựa trên version mới nhất từ Docker Hub
- **Tích hợp với tutor system** để build đúng cách
- Đảm bảo có đủ dung lượng disk cho Docker images
- Kiểm tra Docker Hub quota trước khi push nhiều images

## So Sánh Với Scripts Khác

| Script | Mục đích | Cách hoạt động |
|--------|----------|----------------|
| `build_mfe_local.sh` | **Build từ source code** | `tutor images build mfe` → tag → push |
| Scripts cũ | Tag và push image có sẵn | `docker pull` → `docker tag` → `docker push` |

Script này **build thực sự từ source code** như yêu cầu của bạn!