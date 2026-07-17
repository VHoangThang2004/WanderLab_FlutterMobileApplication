# WanderLab - Ứng dụng Đặt vé Du lịch & Khám phá

WanderLab là một ứng dụng di động Flutter giúp người dùng khám phá các điểm đến du lịch, đặt vé dịch vụ, chia sẻ kinh nghiệm cộng đồng và xem bản đồ trực quan.

Ứng dụng được thiết kế theo tiêu chuẩn UI/UX hiện đại, mượt mà và quản lý dữ liệu cục bộ bằng SQLite (có thể dễ dàng scale lên backend thực tế).

---

## 1. Tiến độ Dự án (Project Status)

Tính đến thời điểm hiện tại, **hầu hết các chức năng cốt lõi (Core Features) đã được hoàn thiện 100%**.

### Các chức năng ĐÃ hoàn thành

- [x] **Xác thực người dùng (Auth):** Đăng nhập, Đăng ký, Đăng xuất, Lưu phiên đăng nhập (SharedPreferences).
- [x] **Khám phá (Explorer):** Hiển thị danh sách điểm đến, lọc theo danh mục (Biển, Núi, Văn hóa...), tìm kiếm, xem chi tiết.
- [x] **Đặt chỗ & Thanh toán (Booking & Payment):** Chọn ngày giờ, số khách -> Chọn phương thức thanh toán (giả lập) -> Xuất biên lai.
- [x] **Quản lý vé (Manage Bookings):** Xem danh sách vé đã đặt, cập nhật trạng thái (Xác nhận, Hủy, Hoàn thành), xóa vé.
- [x] **Yêu thích (Favorites):** Lưu/Bỏ lưu điểm đến yêu thích và xem danh sách.
- [x] **Bản đồ (Map):** Bản đồ tương tác (sử dụng `flutter_map`), hiển thị vị trí điểm đến, chỉ đường cơ bản.
- [x] **Cộng đồng (Community):** Nơi người dùng đăng bài viết, chia sẻ trải nghiệm, đánh giá điểm đến.
- [x] **Thông báo (Notifications):** Hệ thống thông báo cục bộ khi trạng thái vé thay đổi.
- [x] **Hồ sơ cá nhân (Profile):** Cập nhật thông tin cá nhân.

## 2. Kịch bản & Hướng dẫn Test (Walkthrough)

Để hiểu rõ cách hoạt động của ứng dụng, hãy làm theo các luồng (Flows) được sắp xếp dưới đây:

### 🌟 Luồng chính (Primary Flows)

#### Kịch bản 1: Luồng Đăng nhập & Khám phá

1. Mở ứng dụng. Nếu chưa có tài khoản, chọn **Đăng ký**, nhập thông tin và tạo tài khoản.
2. Đăng nhập vào ứng dụng, bạn sẽ được đưa tới màn hình **Khám phá** (Home).
3. Thử lướt danh sách điểm đến, gõ vào ô tìm kiếm (ví dụ: "Sapa") hoặc bấm vào các Filter (Biển, Núi...).
4. Bấm vào một thẻ điểm đến (VD: Vịnh Hạ Long) để vào màn hình **Chi tiết**.
5. Tại đây, đọc thông tin mô tả, xem giá vé, nhấn icon **Trái tim** (góc trên bên phải) để lưu vào Yêu thích.

#### Kịch bản 2: Luồng Đặt vé & Thanh toán (Mock Payment)

1. Trong màn hình Chi tiết điểm đến, bấm nút **ĐẶT CHỖ**.
2. Chọn Ngày, Thời gian, và Tăng/giảm số lượng khách -> Bấm **XÁC NHẬN ĐẶT CHỖ**.
3. Màn hình **Thanh toán** hiện ra. Thử click chọn các phương thức (Thẻ tín dụng, MoMo, Tiền mặt).
4. Bấm **THANH TOÁN NGAY**. Chờ 2 giây để hệ thống xử lý (Loading).
5. Màn hình **Biên lai xác nhận** (Booking Confirmation) xuất hiện với trạng thái "Đã thanh toán".

#### Kịch bản 3: Luồng Quản lý & Thay đổi trạng thái

1. Quay về màn hình chính, chuyển sang tab **Quản lý** (icon tờ biên lai ở Bottom Navigation).
2. Kiểm tra vé vừa đặt có xuất hiện trong danh sách không.
3. Bấm **Chi tiết** để xem lại thông tin và xem **Phương thức thanh toán** đã được lưu đúng chưa.
4. Thử bấm các nút chuyển trạng thái: **Xác nhận**, **Hoàn thành**, hoặc **Hủy**.
5. Bấm vào icon **Thùng rác (Delete)** trên góc thẻ vé để xóa vé đó khỏi lịch sử.
6. Sang tab **Thông báo** (icon cái chuông) để xem các thông báo được tạo ra mỗi khi bạn đổi trạng thái vé ở bước trên.

---

### 💫 Luồng phụ (Secondary Flows)

#### Kịch bản 4: Trải nghiệm Bản đồ (Map)

1. Tại Bottom Navigation, chuyển sang tab **Bản đồ**.
2. Thử dùng 2 ngón tay hoặc các nút `+`, `-` để Zoom bản đồ.
3. Chạm vào bất kỳ **Marker** (điểm đánh dấu) nào trên bản đồ để mở popup thông tin.
4. Trong popup, bấm **Chỉ đường** để hiển thị đường line (mô phỏng) nối từ vị trí hiện tại đến điểm đến. Hoặc bấm **Xem chi tiết** để nhảy thẳng vào trang chi tiết của địa điểm đó.

#### Kịch bản 5: Chia sẻ Cộng đồng

1. Chuyển sang tab **Cộng đồng** (icon hình người).
2. Bấm nút dấu cộng `+` góc dưới bên phải (Floating Action Button).
3. Một form sẽ bật lên: Chọn 1 điểm đến, điền Tiêu đề, viết Nội dung trải nghiệm và chọn số Sao đánh giá.
4. Bấm **ĐĂNG BÀI VIẾT**.
5. Bài viết của bạn sẽ lập tức xuất hiện trên bảng tin cộng đồng cùng với tên người dùng và ngày đăng.

#### Kịch bản 6: Hồ sơ & Yêu thích

1. Quay lại tab **Khám phá**, bấm vào icon **Avatar** (góc trên bên trái) để mở trang Profile.
2. Thử sửa tên, SĐT, cập nhật thông tin và bấm Lưu.
3. Bấm vào icon **Trái tim** (góc trên bên phải) ở AppBar màn hình Khám phá.
4. Xem danh sách các điểm đến bạn đã thả tim lúc nãy. Bạn có thể nhấn lại vào thẻ để xem chi tiết hoặc bỏ tim.

---

## 3. Tech Stack (Công nghệ sử dụng)

* **Framework:** Flutter / Dart
- **State Management:** Provider
- **Local Database:** `sqflite` (SQLite)
- **Map Integration:** `flutter_map` & `latlong2`
- **Local Storage (Key-Value):** `shared_preferences`
- **Fonts:** `google_fonts`

## 4. Kiến trúc Thư mục (Folder Structure)

Dự án được tổ chức theo mô hình rõ ràng, phân chia theo tính năng (Feature-based folder structure):

- `lib/data`: Chứa `DatabaseHelper` xử lý SQLite, query, create tables.
- `lib/models`: Các class Entity (User, Destination, Booking, ExperienceLog...).
- `lib/providers`: Xử lý logic nghiệp vụ và quản lý trạng thái toàn cục (Auth, Booking, Destination...).
- `lib/screens`: Chứa toàn bộ giao diện UI, được chia nhỏ theo từng chức năng (auth, explorer, map, community...).

---
*Tài liệu SRS/SRD này được cập nhật theo tiến trình hiện tại của dự án.*
