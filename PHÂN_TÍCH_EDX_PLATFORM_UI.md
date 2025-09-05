# Phân Tích EDX Platform và UI Trang Chủ

## Tổng Quan về EDX Platform

EDX Platform là một hệ thống học trực tuyến mã nguồn mở được viết bằng Python và JavaScript, sử dụng Django framework làm nền tảng chính. Dự án được tổ chức theo kiến trúc modular monolith với các thành phần chính:

### 1. Cấu Trúc Chính

- **LMS (Learning Management System)**: Hệ thống quản lý học tập, cung cấp nội dung học cho người dùng
- **CMS (Content Management System)**: Hệ thống quản lý nội dung, được gọi là Open edX Studio để tạo và chỉnh sửa khóa học
- **Frontend Applications**: Các ứng dụng micro-frontend sử dụng ReactJS

### 2. Thư Mục Chính

```
edx-platform/
├── lms/                    # Learning Management System
├── cms/                    # Content Management System
├── common/                 # Code chung giữa LMS và CMS
├── openedx/               # Core platform code
├── xmodule/               # XBlock runtime và các module
└── requirements/          # Python dependencies
```

## Phân Tích File main.html

File `main.html` là template chính của hệ thống LMS, được viết bằng Mako template engine. Đây là template cha mà tất cả các trang khác sẽ kế thừa.

### 1. Cấu Trúc Template Main.html

#### Header Section:

```html
<head>
  <!-- Meta tags cơ bản -->
  <meta charset="UTF-8" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <!-- CSS và JavaScript imports -->
  <!-- Google Analytics tracking -->
  <!-- Branch.io integration -->
  <!-- Course-specific assets -->
</head>
```

#### Body Structure:

```html
<body>
  <!-- Skip links for accessibility -->
  <!-- Header include -->
  <!-- Page banner -->
  <!-- Marketing hero section -->
  <!-- Main content wrapper -->
  <!-- Footer include -->
  <!-- JavaScript includes -->
</body>
```

### 2. Các Thành Phần UI Chính

#### A. Header (Navigation)

- **File**: `/lms/templates/header/header.html`
- **Chức năng**:
  - Logo và branding
  - Menu điều hướng chính
  - User authentication status
  - Language selector
  - Mobile hamburger menu
  - Search functionality

#### B. Main Content Area

- **Class**: `.content-wrapper.main-container`
- **Chức năng**:
  - Container chính cho nội dung trang
  - Responsive design
  - RTL (Right-to-Left) language support

#### C. Marketing Hero Section

- **Class**: `.marketing-hero`
- **Chức năng**:
  - Banner chính của trang
  - Promotional content
  - Call-to-action buttons

#### D. Footer

- **File**: `/lms/templates/footer.html`
- **Chức năng**:
  - Links thông tin trang web
  - Social media links
  - Copyright information

### 3. Hệ Thống Styling

#### CSS Architecture:

- **Version 1**: Pre-Pattern Library styling (`style-main-v1`)
- **SCSS Structure**:
  ```
  lms/static/sass/
  ├── lms-main-v1.scss      # Main stylesheet
  ├── _build-base-v1.scss   # Base styles
  ├── _build-lms-v1.scss    # LMS specific styles
  ├── _variables.scss       # SCSS variables
  ├── _mixins.scss         # SCSS mixins
  └── partials/            # Modular SCSS files
  ```

#### Key CSS Classes:

- `.window-wrap`: Main container wrapper
- `.global-header`: Header container
- `.content-wrapper`: Main content area
- `.marketing-hero`: Hero banner section
- `.courses-container`: Course listing area

### 4. JavaScript Integration

#### Core JavaScript Files:

- **RequireJS**: Module loading system
- **jQuery**: DOM manipulation và AJAX
- **Bootstrap**: UI components
- **Custom Scripts**:
  - `header.js`: Header functionality
  - `navigation.js`: Navigation utilities
  - `require-config.js`: RequireJS configuration

#### External Integrations:

- Google Analytics tracking
- Branch.io deep linking
- Segment.io analytics
- Course-specific JavaScript assets

### 5. Accessibility Features

- Skip links for screen readers
- ARIA labels và roles
- Keyboard navigation support
- Screen reader announcements
- RTL language support

### 6. Responsive Design

- Mobile-first approach
- Hamburger menu for mobile devices
- Flexible grid system
- Responsive images và videos
- Touch-friendly interface elements

## Trang Chủ (Homepage) Analysis

### 1. File index.html

Template chính cho trang chủ, kế thừa từ `main.html`:

#### Cấu Trúc:

```html
<main id="main">
  <section class="home">
    <header>
      <!-- Title và heading group -->
      <!-- Course search form -->
      <!-- Promo video -->
    </header>
    <!-- Course listing -->
  </section>
</main>
```

#### Components Chính:

1. **Overlay Section**: Banner chính với thông điệp marketing
2. **Course Search**: Form tìm kiếm khóa học
3. **Course Listing**: Danh sách các khóa học nổi bật
4. **Promo Video Modal**: Video giới thiệu (nếu có)

### 2. Course Listing

- **File**: `courses_list.html`
- **Features**:
  - Grid layout hiển thị khóa học
  - Pagination với `homepage_course_max`
  - "View all Courses" link
  - Course cards với thông tin chi tiết

## Đề Xuất Cập Nhật UI

### 1. Modernization Areas:

- **Design System**: Chuyển từ Pattern Library v1 sang v2
- **Component Library**: Sử dụng React components cho UI phức tạp
- **CSS Framework**: Có thể áp dụng CSS Grid và Flexbox hiện đại
- **Responsive Improvements**: Cải thiện mobile experience

### 2. Accessibility Enhancements:

- Cải thiện color contrast
- Better keyboard navigation
- Enhanced screen reader support
- Focus management improvements

### 3. Performance Optimizations:

- CSS và JavaScript bundling
- Image optimization
- Lazy loading cho course cards
- Critical CSS inlining

### 4. User Experience:

- Interactive course discovery
- Personalized recommendations
- Progressive web app features
- Better search functionality

## Quy Trình Cập Nhật UI với Tutor Development Mode

### 1. Thiết Lập Môi Trường Development

#### Bước 1: Mount edx-platform repo

```bash
# Thêm edx-platform vào bind mount để live-reload
tutor mounts add /home/thienmdp/Ubuntu_Workspace/tutor/edx-platform

# Verify mount configuration
tutor mounts list
```

#### Bước 2: Khởi tạo development environment

```bash
# Launch development environment (chỉ chạy lần đầu)
tutor dev launch

# Sau khi setup xong, start services
tutor dev start
```

#### Bước 3: Truy cập ứng dụng

- **LMS**: http://local.openedx.io:8000
- **CMS**: http://studio.local.openedx.io:8001

### 2. Workflow Cập Nhật UI

#### A. Workflow Templates (HTML)

**Thứ tự thực hiện:**

1. **Phân tích current templates**

   ```bash
   # Tìm template hiện tại
   find edx-platform/lms/templates -name "*.html" | grep -E "(main|index|header|footer)"
   ```

2. **Backup templates gốc**

   ```bash
   cp edx-platform/lms/templates/main.html edx-platform/lms/templates/main.html.backup
   cp edx-platform/lms/templates/index.html edx-platform/lms/templates/index.html.backup
   ```

3. **Chỉnh sửa templates**

   - Sửa `main.html` cho layout chung
   - Sửa `index.html` cho homepage
   - Sửa `header/header.html` cho navigation
   - Sửa `footer.html` cho footer

4. **Live reload** - Thay đổi sẽ tự động reflect ngay lập tức

#### B. Workflow Styling (CSS/SCSS)

**Thứ tự thực hiện:**

1. **Locate current stylesheets**

   ```bash
   # Main SCSS files
   ls -la edx-platform/lms/static/sass/
   # Check which stylesheet đang được sử dụng
   grep -r "style-main" edx-platform/lms/templates/main.html
   ```

2. **Create custom theme hoặc modify existing**

   ```bash
   # Option 1: Modify existing SCSS
   vim edx-platform/lms/static/sass/lms-main-v1.scss

   # Option 2: Create custom theme
   mkdir -p edx-platform/themes/custom-theme/lms/static/sass/
   ```

3. **Compile SCSS** (Tutor sẽ tự động compile trong dev mode)

   ```bash
   # Manual compile nếu cần
   tutor dev run lms npm run compile-sass
   ```

4. **Check compiled CSS**
   ```bash
   ls -la edx-platform/lms/static/css/
   ```

#### C. Workflow JavaScript

**Thứ tự thực hiện:**

1. **Locate JS files**

   ```bash
   find edx-platform/lms/static/js -name "*.js" | grep -E "(main|header|footer)"
   ```

2. **Modify/Add custom JS**

   ```bash
   # Edit existing
   vim edx-platform/lms/static/js/header/header.js

   # Add new JS module
   touch edx-platform/lms/static/js/custom/homepage.js
   ```

3. **Update RequireJS config**

   ```bash
   vim edx-platform/lms/static/lms/js/require-config.js
   ```

4. **Build JS assets**
   ```bash
   tutor dev run lms npm run build-dev
   ```

### 3. Detailed Development Steps

#### Step 1: Initial Setup

```bash
# 1. Mount edx-platform for live development
cd /home/thienmdp/Ubuntu_Workspace/tutor
tutor mounts add ./edx-platform

# 2. Build development image (include mounted code)
tutor images build openedx-dev

# 3. Launch development environment
tutor dev launch

# 4. Verify services are running
tutor dev status
```

#### Step 2: Frontend Asset Development

**SCSS Development:**

```bash
# 1. Navigate to SCSS directory
cd edx-platform/lms/static/sass

# 2. Create custom variables
echo '@import "variables-custom";' >> lms-main-v1.scss
touch _variables-custom.scss

# 3. Watch for SCSS changes (in container)
tutor dev run lms npm run watch-sass
```

**Template Development:**

```bash
# 1. Main layout customization
vim edx-platform/lms/templates/main.html

# 2. Homepage customization
vim edx-platform/lms/templates/index.html

# 3. Header/Footer customization
vim edx-platform/lms/templates/header/header.html
vim edx-platform/lms/templates/footer.html
```

#### Step 3: Testing & Debugging

```bash
# 1. Check for template errors
tutor dev logs lms | grep -i error

# 2. Validate HTML output
curl http://local.openedx.io:8000 | tidy -q -e

# 3. Check CSS compilation
tutor dev run lms find /openedx/staticfiles -name "*.css" -newer /tmp/last-build

# 4. Restart services if needed
tutor dev restart lms cms
```

### 4. Hot Reload Workflow

Khi có bind-mount, Tutor tự động:

1. **Templates**: Hot reload ngay lập tức
2. **SCSS**: Auto-compile khi có thay đổi
3. **JavaScript**: Cần rebuild với `npm run build-dev`
4. **Static files**: Auto-collect trong dev mode

### 5. Production Deployment

```bash
# 1. Build production image với changes
tutor images build openedx

# 2. Deploy to production
tutor local launch

# 3. Hoặc push image lên registry
docker tag $(tutor config printvalue DOCKER_IMAGE_OPENEDX) your-registry/openedx:custom
docker push your-registry/openedx:custom
```

### 6. Troubleshooting Common Issues

#### Issue: CSS không update

```bash
# Clear static files cache
tutor dev run lms python manage.py collectstatic --noinput --clear

# Rebuild CSS
tutor dev run lms npm run build-dev
```

#### Issue: Template changes không hiển thị

```bash
# Check template syntax
tutor dev run lms python manage.py validate_templates

# Restart LMS
tutor dev restart lms
```

#### Issue: JavaScript errors

```bash
# Check browser console
# Rebuild JS assets
tutor dev run lms npm run webpack
```

### 7. Best Practices

1. **Version Control**: Luôn commit changes từng bước nhỏ
2. **Testing**: Test trên multiple browsers và screen sizes
3. **Performance**: Monitor asset file sizes và load times
4. **Accessibility**: Validate WCAG compliance
5. **Documentation**: Document custom changes cho team

### 8. File Structure cho Custom UI

```
edx-platform/
├── lms/
│   ├── templates/
│   │   ├── main.html                 # Main layout
│   │   ├── index.html               # Homepage
│   │   ├── header/
│   │   │   └── header.html          # Navigation
│   │   └── footer.html              # Footer
│   └── static/
│       ├── sass/
│       │   ├── lms-main-v1.scss     # Main stylesheet
│       │   ├── _variables-custom.scss # Custom variables
│       │   └── partials/
│       │       └── _homepage.scss    # Homepage styles
│       └── js/
│           ├── header/
│           │   └── header.js        # Header interactions
│           └── custom/
│               └── homepage.js      # Homepage functionality
```

## Kết Luận

EDX Platform với Tutor development mode cung cấp một workflow mạnh mẽ cho UI development với:

- **Live reload** cho templates và styles
- **Hot module replacement** cho JavaScript
- **Bind mounting** cho development thuận tiện
- **Auto-compilation** cho SCSS và static assets

Quy trình này cho phép rapid prototyping và testing, đảm bảo changes được reflect ngay lập tức trong development environment.

Framework hiện tại đã có foundation tốt, với workflow này bạn có thể:

1. Cải thiện component structure một cách hiệu quả
2. Modernize CSS architecture với live feedback
3. Enhance responsive design với hot reload
4. Improve accessibility với immediate testing
5. Optimize performance với realtime monitoring
