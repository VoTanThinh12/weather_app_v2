1. Chuẩn bị môi trường phát triển

Kiểm tra phiên bản Flutter:
Dự án được phát triển trên Flutter phiên bản stable 3.29.0 (channel stable). Bạn có thể cài đặt đúng phiên bản này hoặc cao hơn để đảm bảo tương thích.

Cài đặt các công cụ hỗ trợ:
Đảm bảo đã cài đặt Android Studio, VS Code, Android SDK và Visual Studio (nếu phát triển ứng dụng Windows).

2. Tải và mở dự án
   Clone dự án từ GitHub: git clone https://github.com/VoTanThinh12/weather_app_v2.git

3. Cài đặt các gói phụ thuộc

Trong terminal của IDE, chạy lệnh: flutter pub get

Lệnh này sẽ tải về tất cả các thư viện cần thiết cho dự án.

4. Nhập API Key của WeatherAPI
   Để ứng dụng Weather App lấy được dữ liệu thời tiết từ WeatherAPI, bạn cần cung cấp API Key hợp lệ. Trong dự án này, API Key được khai báo trực tiếp trong file lib/Service/api_service.dart như hình bên dưới:

const String apiKey = "612532f7683246cba4d121126251706";

Bạn có thể giữ nguyên API Key mặc định này để chạy thử nghiệm. Tuy nhiên, để đảm bảo an toàn và chủ động, khuyến khích bạn đăng ký tài khoản tại WeatherAPI.com để lấy API Key riêng của mình.

Cách thay đổi API Key:

Đăng ký tài khoản và lấy API Key mới tại trang WeatherAPI.com.

Mở file lib/Service/api_service.dart trong dự án.

Thay thế chuỗi API Key cũ bằng API Key mới của bạn:

const String apiKey = "YOUR_NEW_API_KEY";

Lưu file và chạy lại ứng dụng.

5. Chạy ứng dụng

Chạy trên thiết bị Android hoặc trình giả lập: flutter run 6. Xử lý lỗi thường gặp

Nếu gặp lỗi khi chạy dự án, bạn có thể thử các lệnh sau để làm sạch và khởi động lại:

flutter clean
flutter pub get
flutter run
