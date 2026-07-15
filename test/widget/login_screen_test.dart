import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wanderlab/providers/auth_provider.dart';
import 'package:wanderlab/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen shows validation errors when submitted empty', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify that the login button is present.
    expect(find.text('Đăng nhập'), findsOneWidget);

    // Tap the login button without entering any text.
    await tester.tap(find.text('Đăng nhập'));
    await tester.pump();

    // Verify that validation error messages are displayed.
    expect(find.text('Email không được để trống'), findsOneWidget);
    expect(find.text('Mật khẩu không được để trống'), findsOneWidget);
  });
}
