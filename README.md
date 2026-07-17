# PRM393 – TEAM 6

## PROJECT NAME: WANDERLAB

---

## 1. Team Introduction

Nhóm dự án gồm 4 thành viên, tất cả đảm nhiệm vai trò Software Engineer, cùng phối hợp phát triển ứng dụng WanderLab từ khâu thiết kế hệ thống đến lập trình và kiểm thử.

| STT | Họ và tên | Vai trò | Nhiệm vụ / Đóng góp chính |
|---|---|---|---|
| 1 | Võ Hoàng Thắng | Software Engineer | Xác thực & xác nhận: xây dựng màn hình Đăng nhập/Đăng ký (chức năng B); xây dựng màn hình Xác nhận đặt chỗ (chức năng F). |
| 2 | Nguyễn Đại Lợi | Software Engineer (Team Leader) | Điều phối chung nhóm, tổng hợp báo cáo, kiểm soát tiến độ; nền tảng dữ liệu & nghiệp vụ đặt chỗ: thiết kế Database/API (chức năng A); xây dựng màn hình Đặt chỗ - Reservation (chức năng E). |
| 3 | Bùi Huỳnh Văn Phúc | Software Engineer | Trải nghiệm khám phá điểm đến: xây dựng màn hình Khám phá (chức năng C), Chi tiết điểm đến (chức năng D) và Bản đồ điểm đến (chức năng H). |
| 4 | Lê Minh Trí | Software Engineer | Trải nghiệm tương tác & kiến trúc ứng dụng: xây dựng màn hình Thông báo (chức năng G), Cộng đồng/Trò chuyện du khách (chức năng I); áp dụng quản lý trạng thái Provider/Bloc (chức năng J). |

## 2. Case Study: Booking & Reservation Systems

WanderLab là ứng dụng di động Flutter thuộc lĩnh vực Booking & Reservation Systems, hướng đến người dùng là các du khách (travelers) có nhu cầu:

- Khám phá các điểm đến và dịch vụ du lịch (tour, khách sạn, hoạt động trải nghiệm...).
- Xem thông tin chi tiết, đánh giá và hình ảnh của từng điểm đến/dịch vụ.
- Thực hiện đặt chỗ (reservation), theo dõi và quản lý các đơn đặt chỗ đã tạo.
- Nhận thông báo liên quan đến lịch trình và trạng thái đặt chỗ.
- Ghi lại và chia sẻ trải nghiệm du lịch cá nhân với cộng đồng du khách khác.

Bài toán đặt ra là xây dựng một hệ thống đặt chỗ hoàn chỉnh, có khả năng quản lý dữ liệu điểm đến/dịch vụ, xử lý luồng đặt chỗ từ lúc chọn dịch vụ đến khi xác nhận, đồng thời tạo trải nghiệm mang tính cộng đồng và cá nhân hóa cho người dùng.

## 3. Business Analysis / System Design

### 3.1. Chức năng chính của hệ thống

| Mã | Chức năng chính | Mô tả ngắn gọn | Điểm | Phụ trách | Trạng thái |
|---|---|---|---|---|---|
| A | Thiết kế Booking Database/API Structure | Thiết kế lược đồ dữ liệu/API cho điểm đến, dịch vụ, đặt chỗ, người dùng và nhật ký trải nghiệm. | 20% | Lợi | Hoàn thành |
| B | Login/Register Screen | Đăng ký, đăng nhập, xác thực người dùng. | 10% | Thắng | Hoàn thành |
| C | Destination Explorer Screen | Duyệt danh sách điểm đến/dịch vụ du lịch, tìm kiếm và lọc theo tiêu chí. | 10% | Phúc | Hoàn thành |
| D | Destination Detail Screen | Xem chi tiết điểm đến: hình ảnh, mô tả, dịch vụ đi kèm, đánh giá. | 10% | Phúc | Hoàn thành |
| E | Reservation Screen | Chọn dịch vụ, ngày giờ, số lượng khách và tạo yêu cầu đặt chỗ. | 10% | Lợi | Hoàn thành |
| F | Booking Confirmation & Payment | Thanh toán (MoMo, Tiền mặt), xác nhận thông tin đặt chỗ, hiển thị trạng thái và mã đặt chỗ. | 20% | Thắng | Hoàn thành |
| G | Notifications Screen | Thông báo nhắc lịch trình, xác nhận đặt chỗ, hiển thị Badge số thông báo. | 10% | Trí | Hoàn thành |
| H | Destination Map Screen | Hiển thị vị trí điểm đến trên bản đồ, chỉ đường cơ bản. | 10% | Phúc | Hoàn thành |

Công việc được chia theo 4 nhóm luồng nghiệp vụ để mỗi thành viên phụ trách trọn vẹn một mảng, giảm phụ thuộc chéo:

- **Lợi (Leader)** – Nền tảng dữ liệu & đặt chỗ (A, E).
- **Thắng** – Xác thực & xác nhận (B, F).
- **Phúc** – Khám phá điểm đến (C, D, H).
- **Trí** – Tương tác & kiến trúc (G, I, J).

### 3.2. Yêu cầu chức năng (Functional Requirements)

- Người dùng có thể đăng ký, đăng nhập và quản lý tài khoản cá nhân.
- Người dùng có thể tìm kiếm, lọc và xem danh sách điểm đến/dịch vụ du lịch.
- Người dùng có thể xem chi tiết điểm đến kèm hình ảnh, mô tả, đánh giá.
- Người dùng có thể tạo, xem, chỉnh sửa và huỷ đặt chỗ.
- Hệ thống xác nhận đặt chỗ, xử lý thanh toán (Ví MoMo, Tiền mặt) và cung cấp mã tham chiếu.
- Hệ thống gửi thông báo tự động về trạng thái đặt chỗ (đặc biệt khi thanh toán thành công).
- Người dùng có thể xem vị trí điểm đến trên bản đồ.
- Người dùng có thể tương tác, chia sẻ trải nghiệm trong cộng đồng du khách.

### 3.3. Yêu cầu phi chức năng (Non-functional Requirements)

- **Hiệu năng:** thời gian tải danh sách điểm đến và xử lý đặt chỗ nhanh, mượt mà.
- **Bảo mật:** xác thực người dùng an toàn, bảo vệ dữ liệu cá nhân và lịch sử đặt chỗ.
- **Khả năng sử dụng:** giao diện trực quan, thân thiện, có Badge thông báo tiện lợi ở Taskbar.
- **Khả năng bảo trì:** mã nguồn tổ chức rõ ràng theo kiến trúc quản lý trạng thái Provider.

### 3.4. Thiết kế cơ sở dữ liệu / Công nghệ lưu trữ

- Dự án hiện tại sử dụng **SQLite (`sqflite`)** để mô phỏng lưu trữ cục bộ tốc độ cao, hỗ trợ truy vấn các thực thể chính như: User, Destination, Service, Booking, Notification, CommunityPost.
- Các State được quản lý tập trung qua **Provider**.
- Tích hợp `flutter_map` để hiển thị bản đồ trực quan.

### 3.5. Kiến trúc ứng dụng

Ứng dụng áp dụng mô hình quản lý trạng thái Provider nhằm tách biệt rõ ràng giữa UI, logic nghiệp vụ và tầng dữ liệu.
Luồng UI tổng quát: `Login → Destination Explorer → Destination Detail → Reservation → Payment → Booking Confirmation`, kết hợp với các màn hình phụ trợ `Manage Bookings`, `Notifications`, `Map` và `Community`.

---

## 4. Demo of Mobile Application (Kịch bản & Hướng dẫn Test)

Nhóm trình diễn đầy đủ các chức năng thông qua các luồng (Flows) sau:

### 🌟 Luồng chính (Primary Flows)

**Kịch bản 1: Đăng nhập & Khám phá**

1. Mở ứng dụng. Chọn **Đăng ký**, nhập thông tin và tạo tài khoản.
2. Đăng nhập vào ứng dụng, bạn sẽ được đưa tới màn hình **Khám phá** (Home).
3. Thử lướt danh sách điểm đến, gõ vào ô tìm kiếm hoặc bấm vào các Filter.
4. Bấm vào một thẻ điểm đến để vào màn hình **Chi tiết**, đọc thông tin, bấm icon **Trái tim** để lưu vào Yêu thích.

**Kịch bản 2: Đặt vé & Thanh toán (MoMo & Tiền mặt)**

1. Trong màn hình Chi tiết điểm đến, bấm nút **ĐẶT CHỖ**.
2. Chọn Ngày, Thời gian, Tăng/giảm số lượng khách -> Bấm **XÁC NHẬN ĐẶT CHỖ**.
3. Màn hình **Thanh toán** hiện ra.
   - Nếu chọn **Tiền mặt** (Mặc định): Bấm THANH TOÁN NGAY, hệ thống lập tức chốt vé với trạng thái "Chờ xác nhận" và chuyển sang màn hình Biên lai xác nhận.
   - Nếu chọn **Ví MoMo**: Bấm THANH TOÁN NGAY, hệ thống mô phỏng xử lý 2 giây, chốt vé với trạng thái "Đã thanh toán" và gửi **thông báo tự động**. Màn hình chuyển sang Biên lai.

**Kịch bản 3: Quản lý & Thay đổi trạng thái**

1. Chuyển sang tab **Quản lý** ở Bottom Navigation.
2. Kiểm tra vé vừa đặt.
   - Với vé Tiền mặt ("Chờ xác nhận"): Bạn có thể bấm **Xác nhận** hoặc **Hủy**.
   - Với vé MoMo ("Đã thanh toán"): Bạn có thể bấm nút **Hoàn thành** màu xanh lá cây để kết thúc chuyến đi.
3. Chú ý tab **Thông báo** (icon cái chuông) ở dưới Taskbar: Khi có thông báo mới (do thanh toán MoMo thành công hoặc vừa đổi trạng thái vé), sẽ có một **Badge chấm đỏ hiện số** hiển thị ngay lập tức.
4. Bấm vào icon **Thùng rác** trên góc thẻ vé để xóa vé đó khỏi lịch sử.

### 💫 Luồng phụ (Secondary Flows)

**Kịch bản 4: Trải nghiệm Bản đồ (Map)**

1. Chuyển sang tab **Bản đồ**. Thử zoom và kéo bản đồ.
2. Chạm vào bất kỳ **Marker** nào để mở popup thông tin.
3. Bấm **Chỉ đường** để hiển thị đường line (mô phỏng) nối từ vị trí hiện tại đến điểm đến, hoặc bấm **Xem chi tiết**.

**Kịch bản 5: Cộng đồng & Hồ sơ**

1. Chuyển sang tab **Cộng đồng**. Bấm nút dấu cộng `+`, chọn điểm đến, điền nội dung review và đánh giá Sao -> Bấm **ĐĂNG BÀI VIẾT**. Bài viết sẽ lên bảng tin.
2. Vào **Hồ sơ** (icon Avatar ở trang chủ) để sửa thông tin cá nhân. Thử bấm icon Đăng xuất ngay bên cạnh.
3. Xem danh sách Yêu thích qua icon **Trái tim** ở màn hình chính.

---

## 5. Development Requirements

- **UI Implementation:** Đã xây dựng hoàn thiện 100% màn hình cho tất cả các chức năng.
- **Database:** Hoàn thiện tích hợp SQLite.
- **Tính năng mới cập nhật:** Hoàn thiện luồng thanh toán Tiền mặt/MoMo, tối ưu hệ thống Thông báo (Badge Taskbar) và nút chức năng trong Quản lý vé.

## 6. Conclusion and Discussion

Ứng dụng WanderLab đã hoàn thiện toàn bộ các chức năng cốt lõi theo đúng thiết kế ban đầu. Luồng đặt chỗ, thanh toán và quản lý vé hoạt động trơn tru. Giao diện trực quan, mượt mà. Trong tương lai, ứng dụng có thể được mở rộng bằng cách tích hợp Backend REST API, cổng thanh toán (MoMo API), và tính năng Chat thời gian thực.

## 7. Contribution

| Hạng mục | Nhóm | Thắng | Lợi | Phúc | Trí |
|---|---|---|---|---|---|
| Phân tích Case Study | 100% | 30% | 20% | 25% | 25% |
| Business analysis | 100% | 20% | 15% | 35% | 30% |
| System design | 100% | 35% | 15% | 30% | 20% |
| Implementation | 100% | 35% | 30% | 25% | 10% |
| Documentation | 100% | 40% | 20% | 25% | 15% |
