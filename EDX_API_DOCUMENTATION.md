# Open edX Platform - Tổng hợp API Documentation

## Tổng quan
Open edX LMS Platform cung cấp **287 API endpoints** được tổ chức thành các module chức năng.

**Base URL**: `http://your-domain.com/api`

## Xác thực (Authentication)

### 3 Phương thức xác thực chính:

1. **JWT Token** (Khuyến nghị cho API clients)
```bash
POST /oauth2/v1/access_token
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials
&client_id=YOUR_CLIENT_ID
&client_secret=YOUR_CLIENT_SECRET
&token_type=jwt
```

Sử dụng trong header:
```
Authorization: JWT your_token_here
```

2. **Session-based** (Cookie)
```bash
POST /user/v1/account/login_session/
Content-Type: application/json

{
  "email_or_username": "user@example.com",
  "password": "password"
}
```

3. **CSRF Token** (Cho POST/PUT/DELETE requests)
```bash
GET /csrf/api/v1/token
```

---

## Nhóm API chính

### 1. 📚 Courses (Khóa học)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/courses/v1/courses/` | Danh sách tất cả courses | Public |
| GET | `/courses/v1/courses/{course_id}` | Chi tiết course | Public |
| GET | `/courses/v1/blocks/` | Cấu trúc blocks của course | Optional |
| GET | `/courses/v1/blocks/{usage_key}` | Chi tiết một block | Optional |
| GET | `/course_home/course_metadata/{course_id}` | Metadata course | Required |
| GET | `/course_home/outline/{course_id}` | Outline course | Required |
| GET | `/course_home/navigation/{course_id}` | Navigation course | Required |

**Tham số quan trọng cho `/courses/v1/courses/`:**
- `page`: Trang hiện tại
- `page_size`: Số lượng/trang (max 100)
- `active_only`: true/false - Chỉ lấy course đang active
- `org`: Lọc theo organization
- `search_term`: Tìm kiếm
- `username`: Lọc theo user enrollment

### 2. 📝 Enrollment (Đăng ký khóa học)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/enrollment/v1/enrollment` | Danh sách enrollments của user | Required |
| POST | `/enrollment/v1/enrollment` | Đăng ký course | Required |
| POST | `/enrollment/v1/unenroll/` | Hủy đăng ký course | Required |
| GET | `/enrollment/v1/enrollments/` | List tất cả enrollments | Staff |
| POST | `/bulk_enroll/v1/bulk_enroll` | Đăng ký hàng loạt | Staff |

**Body mẫu cho enrollment:**
```json
{
  "course_details": {
    "course_id": "course-v1:edX+DemoX+Demo_Course"
  },
  "user": "username"
}
```

### 3. 🎓 Certificates (Chứng chỉ)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/certificates/v0/certificates/{username}/` | Danh sách certificates | Required |
| GET | `/certificates/v0/certificates/{username}/courses/{course_id}/` | Certificate của course | Required |

### 4. 📊 Grades & Progress (Điểm & Tiến độ)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/grades/v1/courses/{course_id}/` | Điểm của user trong course | Required |
| GET | `/grades/v1/gradebook/{course_id}/` | Gradebook (bảng điểm tổng) | Instructor |
| POST | `/grades/v1/gradebook/{course_id}/bulk-update` | Cập nhật điểm hàng loạt | Instructor |
| GET | `/course_home/progress/{course_id}` | Tiến độ học tập | Required |
| GET | `/grades/v1/subsection/{subsection_id}/` | Điểm của subsection | Required |

### 5. 👤 User Profile (Thông tin người dùng)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/user/v1/accounts/{username}` | Thông tin profile | Required |
| PATCH | `/user/v1/accounts/{username}` | Cập nhật profile | Required |
| GET | `/mobile/v1/my_user_info` | Info user hiện tại (Mobile) | Required |
| GET | `/user/v1/preferences/{username}` | User preferences | Required |

### 6. 💬 Discussions (Thảo luận)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/discussion/v1/course_topics/{course_id}` | Topics discussion | Required |
| GET | `/discussion/v1/threads/` | Danh sách threads | Required |
| POST | `/discussion/v1/threads/` | Tạo thread mới | Required |
| GET | `/discussion/v1/threads/{thread_id}/` | Chi tiết thread | Required |
| PATCH | `/discussion/v1/threads/{thread_id}/` | Cập nhật thread | Required |
| DELETE | `/discussion/v1/threads/{thread_id}/` | Xóa thread | Required |
| POST | `/discussion/v1/comments/` | Tạo comment | Required |
| GET | `/discussion/v1/comments/{comment_id}/` | Chi tiết comment | Required |

### 7. 🔖 Bookmarks (Đánh dấu)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/bookmarks/v1/bookmarks/` | Danh sách bookmarks | Required |
| POST | `/bookmarks/v1/bookmarks/` | Tạo bookmark | Required |
| DELETE | `/bookmarks/v1/bookmarks/{username},{usage_id}/` | Xóa bookmark | Required |

### 8. 👥 Cohorts (Nhóm học viên)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/cohorts/v1/courses/{course_id}/cohorts/{cohort_id}` | Thông tin cohort | Staff |
| POST | `/cohorts/v1/courses/{course_id}/cohorts/{cohort_id}` | Tạo cohort | Staff |
| PATCH | `/cohorts/v1/courses/{course_id}/cohorts/{cohort_id}` | Cập nhật cohort | Staff |
| POST | `/cohorts/v1/courses/{course_id}/cohorts/{cohort_id}/users/{username}` | Thêm user vào cohort | Staff |
| DELETE | `/cohorts/v1/courses/{course_id}/cohorts/{cohort_id}/users/{username}` | Xóa user khỏi cohort | Staff |

### 9. 💰 Commerce (Thương mại)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/commerce/v1/courses/` | Danh sách courses với modes | Optional |
| GET | `/commerce/v1/courses/{course_id}/` | Chi tiết course modes | Optional |
| GET | `/course_modes/v1/courses/{course_id}/` | Enrollment modes | Public |
| POST | `/commerce/v0/baskets/` | Tạo basket (giỏ hàng) | Required |

### 10. 📱 Mobile API

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/mobile/v1/users/{username}/course_enrollments/` | Enrollments (Mobile) | Required |
| GET | `/mobile/v1/course_info/{course_id}/updates` | Course updates | Required |
| GET | `/mobile/v1/course_info/{course_id}/handouts` | Course handouts | Required |
| POST | `/mobile/v1/course_info/record_user_activity` | Ghi nhận activity | Required |

### 11. 🔔 Notifications (Thông báo)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/notifications/` | Danh sách notifications | Required |
| GET | `/notifications/count/` | Số lượng chưa đọc | Required |
| PUT | `/notifications/read/` | Đánh dấu đã đọc | Required |
| PATCH | `/notifications/mark-seen/{app_name}/` | Đánh dấu đã xem | Required |

### 12. 🎯 Completion (Hoàn thành)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| POST | `/completion/v1/completion-batch` | Cập nhật completion hàng loạt | Required |
| GET | `/completion/v1/subsection-completion/{username}/{course_key}/{subsection_id}` | Completion của subsection | Required |

### 13. 📝 ORA (Open Response Assessment)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/ora_staff_grader/initialize` | Khởi tạo grading interface | Staff |
| GET | `/ora_staff_grader/submission` | Lấy submissions cần grade | Staff |
| POST | `/ora_staff_grader/submission/grade` | Chấm điểm submission | Staff |
| POST | `/ora_staff_grader/submission/lock` | Lock submission để grade | Staff |

### 14. 🔐 Proctoring (Giám sát thi)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/edx_proctoring/v1/proctored_exam/active_exams_for_user` | Exams đang active | Required |
| POST | `/edx_proctoring/v1/proctored_exam/attempt` | Tạo exam attempt | Required |
| GET | `/edx_proctoring/v1/proctored_exam/attempt/{attempt_id}` | Thông tin attempt | Required |
| PUT | `/edx_proctoring/v1/proctored_exam/attempt/{attempt_id}` | Cập nhật attempt | Required |

### 15. 👨‍🏫 Instructor Tools (Công cụ giảng viên)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| POST | `/instructor/v1/reports/{course_id}/generate/problem_responses` | Tạo report responses | Instructor |
| GET | `/instructor/v1/reports/{course_id}` | Danh sách reports | Instructor |
| GET | `/instructor/v1/tasks/{course_id}` | Danh sách tasks | Instructor |

### 16. 🔄 Credit & Programs

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/credit/v1/courses/` | Danh sách credit courses | Staff |
| GET | `/credit/v1/eligibility/` | Credit eligibility | Required |
| GET | `/dashboard/v0/programs/{program_uuid}/progress_details/` | Chi tiết tiến độ program | Required |

---

## Danh sách đầy đủ 287 Endpoints

File chi tiết: `edx-api-endpoints.txt`

### Theo nhóm chức năng:

#### Agreements (2 endpoints)
- `/agreements/v1/integrity_signature/{course_id}`
- `/agreements/v1/lti_pii_signature/{course_id}`

#### Bookmarks (3 endpoints)
- `/bookmarks/v1/bookmarks/`
- `/bookmarks/v1/bookmarks/{username},{usage_id}/`

#### Bulk Operations (3 endpoints)
- `/bulk_enroll/v1/bulk_enroll`
- `/bulk_email/...`
- `/bulk_user_retirement/...`

#### CCX (Custom Courses) (3 endpoints)
- `/ccx/v0/ccx/`
- `/ccx/v0/ccx/{ccx_course_id}/`

#### Certificates (2 endpoints)
- `/certificates/v0/certificates/{username}/`
- `/certificates/v0/certificates/{username}/courses/{course_id}/`

#### Cohorts (5 endpoints)
- `/cohorts/v1/courses/{course_key_string}/cohorts/{cohort_id}`
- `/cohorts/v1/courses/{course_key_string}/cohorts/{cohort_id}/users/{username}`
- `/cohorts/v1/settings/{course_key_string}`

#### Commerce (5 endpoints)
- `/commerce/v0/baskets/`
- `/commerce/v1/courses/`
- `/commerce/v1/courses/{course_id}/`
- `/commerce/v1/orders/{number}/`

#### Completion (2 endpoints)
- `/completion/v1/completion-batch`
- `/completion/v1/subsection-completion/{username}/{course_key}/{subsection_id}`

#### Course Experience (10 endpoints)
- `/course_experience/v1/course_deadlines_info/{course_key_string}`
- `/course_experience/v1/reset_course_deadlines`

#### Course Home (22 endpoints)
- `/course_home/course_metadata/{course_key_string}`
- `/course_home/dates/{course_key_string}`
- `/course_home/navigation/{course_key_string}`
- `/course_home/outline/{course_key_string}`
- `/course_home/progress/{course_key_string}`
- `/course_home/save_course_goal`
- v1 versions của các endpoint trên

#### Course Modes (2 endpoints)
- `/course_modes/v1/courses/{course_id}/`
- `/course_modes/v1/courses/{course_id}/{mode_slug}`

#### Courses (12 endpoints)
- `/courses/v1/courses/`
- `/courses/v1/courses/{course_key_string}`
- `/courses/v1/blocks/`
- `/courses/v1/blocks/{usage_key_string}`
- `/courses/v1/block_metadata/{usage_key_string}`
- `/courses/v1/course_ids/`
- v2 versions

#### Courseware (4 endpoints)
- `/courseware/celebration/{course_key_string}`
- `/courseware/course/{course_key_string}`
- `/courseware/resume/{course_key_string}`
- `/courseware/sequence/{usage_key_string}`

#### Credit (7 endpoints)
- `/credit/v1/courses/`
- `/credit/v1/eligibility/`
- `/credit/v1/providers/`
- `/credit/v1/providers/{provider_id}/`

#### Dashboard (2 endpoints)
- `/dashboard/v0/programs/{enterprise_uuid}/`
- `/dashboard/v0/programs/{program_uuid}/progress_details/`

#### Discounts (2 endpoints)
- `/discounts/course/{course_key_string}`
- `/discounts/user/{user_id}/course/{course_key_string}`

#### Discussion (20+ endpoints)
- `/discussion/v1/course_topics/{course_id}`
- `/discussion/v1/threads/`
- `/discussion/v1/threads/{thread_id}/`
- `/discussion/v1/comments/`
- `/discussion/v1/comments/{comment_id}/`
- `/discussion/v1/courses/{course_id}`
- v2, v3 versions

#### Proctoring (30+ endpoints)
- `/edx_proctoring/v1/proctored_exam/...`
- Nhiều endpoints quản lý exams, attempts, allowances

#### Enrollment (10 endpoints)
- `/enrollment/v1/enrollment`
- `/enrollment/v1/enrollment/{course_id}`
- `/enrollment/v1/enrollment/{username},{course_id}`
- `/enrollment/v1/enrollments/`
- `/enrollment/v1/roles/`

#### Entitlements (3 endpoints)
- `/entitlements/v1/entitlements/`
- `/entitlements/v1/entitlements/{uuid}/`
- `/entitlements/v1/entitlements/{uuid}/enrollments`

#### Grades (10 endpoints)
- `/grades/v1/courses/`
- `/grades/v1/courses/{course_id}/`
- `/grades/v1/gradebook/{course_id}/`
- `/grades/v1/gradebook/{course_id}/bulk-update`
- `/grades/v1/policy/courses/{course_id}/`

#### Instructor (3 endpoints)
- `/instructor/v1/reports/{course_id}`
- `/instructor/v1/tasks/{course_id}`

#### Learner Home (4 endpoints)
- `/learner_home/init/`
- `/learner_home/v1/programs/{program_uuid}/progress_details/`

#### Learning Sequences (1 endpoint)
- `/learning_sequences/v1/course_outline/{course_key_str}`

#### LTI Consumer (5 endpoints)
- `/lti_consumer/v1/lti/{lti_config_id}/...`

#### MFE Config (2 endpoints)
- `/mfe_config/v1`
- `/mfe_context`

#### Mobile API (10 endpoints)
- `/mobile/{api_version}/my_user_info`
- `/mobile/{api_version}/users/{username}`
- `/mobile/{api_version}/users/{username}/course_enrollments/`
- `/mobile/{api_version}/course_info/...`
- `/mobile/{api_version}/notifications/...`

#### Notifications (8 endpoints)
- `/notifications/`
- `/notifications/count/`
- `/notifications/read/`
- `/notifications/preferences/...`

#### ORA Staff Grader (10 endpoints)
- `/ora_staff_grader/initialize`
- `/ora_staff_grader/submission`
- `/ora_staff_grader/submission/grade`
- `/ora_staff_grader/submission/lock`

#### Programs (4 endpoints)
- `/programs/v1/programs/`
- `/programs/v1/programs/{program_uuid}/`

#### Support (3 endpoints)
- `/support/...`

#### Teams (10+ endpoints)
- `/teams/v1/...`

#### User (20+ endpoints)
- `/user/v1/accounts/{username}`
- `/user/v1/preferences/{username}`
- `/user/v1/account/login_session/`
- `/user/v1/account/registration/`

#### Verified Names (4 endpoints)
- `/edx_name_affirmation/v1/verified_name`
- `/edx_name_affirmation/v1/verified_name/{verified_name_id}`

---

## Cách sử dụng Postman Collection

### Import vào Postman:

1. Mở Postman
2. Click **Import** > **Upload Files**
3. Chọn file `edx-platform-api.postman_collection.json`
4. Collection sẽ xuất hiện trong sidebar

### Cấu hình Environment Variables:

Tạo Environment mới với các biến:

```
base_url: http://your-lms-domain.com
jwt_token: (để trống, sẽ lấy sau khi login)
csrf_token: (để trống, sẽ lấy sau khi call /csrf/api/v1/token)
```

### Quy trình test API:

1. **Lấy CSRF Token**: Run request "Get CSRF Token"
2. **Login**: Run "Login Session" hoặc "Get JWT Token"
3. **Copy token** vào Environment variable
4. **Test các API khác**

---

## Response Codes phổ biến

| Code | Ý nghĩa |
|------|---------|
| 200 | OK - Thành công |
| 201 | Created - Tạo mới thành công |
| 204 | No Content - Xóa/cập nhật thành công |
| 400 | Bad Request - Dữ liệu không hợp lệ |
| 401 | Unauthorized - Chưa đăng nhập |
| 403 | Forbidden - Không có quyền |
| 404 | Not Found - Không tìm thấy resource |
| 500 | Internal Server Error - Lỗi server |

---

## Lưu ý quan trọng

1. **Rate Limiting**: Một số API có giới hạn số request/phút
2. **Pagination**: Hầu hết list APIs đều hỗ trợ `page` và `page_size`
3. **Permissions**: Nhiều endpoints yêu cầu quyền Staff/Instructor
4. **Course ID Format**: 
   - Slash-based: `edX/DemoX/Demo_Course`
   - Opaque key: `course-v1:edX+DemoX+Demo_Course`
5. **Mobile APIs**: Thường tối ưu hơn cho bandwidth thấp

---

## Tài liệu tham khảo

- **OpenAPI Schema**: `/home/kongubuntu/Desktop/edx/tutor-edx/edx-platform/docs/lms-openapi.yaml`
- **Full Endpoint List**: `/home/kongubuntu/Desktop/edx/tutor-edx/edx-api-endpoints.txt`
- **Postman Collection**: `/home/kongubuntu/Desktop/edx/tutor-edx/edx-platform-api.postman_collection.json`

---

## Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra lại authentication token
2. Xác nhận quyền của user
3. Đọc chi tiết response error message
4. Tham khảo OpenAPI schema để biết chính xác request format

**Tổng số endpoints**: 287
**Phiên bản**: Open edX Platform (tutor-edx)
**Cập nhật**: 2025-11-03

