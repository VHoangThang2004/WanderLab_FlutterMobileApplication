import 'package:flutter_test/flutter_test.dart';
import 'package:wanderlab/utils/validators.dart';

void main() {
  group('Auth Validators Test', () {
    test('validateEmail returns error if email is empty', () {
      final result = Validators.validateEmail('');
      expect(result, 'Email không được để trống');
    });

    test('validateEmail returns error if email is invalid', () {
      final result = Validators.validateEmail('invalid_email');
      expect(result, 'Email không đúng định dạng');
    });

    test('validateEmail returns null if email is valid', () {
      final result = Validators.validateEmail('test@example.com');
      expect(result, null);
    });

    test('validatePassword returns error if password is empty', () {
      final result = Validators.validatePassword('');
      expect(result, 'Mật khẩu không được để trống');
    });

    test('validatePassword returns error if password is less than 8 chars', () {
      final result = Validators.validatePassword('Pass1');
      expect(result, 'Mật khẩu phải có ít nhất 8 ký tự');
    });

    test('validatePassword returns error if password lacks numbers', () {
      final result = Validators.validatePassword('PasswordNoNumber');
      expect(result, 'Mật khẩu phải chứa ít nhất một chữ cái và một chữ số');
    });

    test('validatePassword returns null if password is valid', () {
      final result = Validators.validatePassword('Password123');
      expect(result, null);
    });
  });
}
