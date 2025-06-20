import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_v2/main.dart'; // Đảm bảo rằng 'weather_app_v2' là tên gói đúng

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Xây dựng ứng dụng của bạn và kích hoạt khung hình.
    await tester.pumpWidget(const MyApp()); // Kiểm tra ứng dụng chính của bạn.

    // Kiểm tra xem giá trị bộ đếm ban đầu là 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Nhấn vào biểu tượng '+' và kích hoạt một khung hình.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(); // Kích hoạt khung hình sau khi nhấn nút.

    // Kiểm tra xem bộ đếm đã tăng lên 1 hay chưa.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
