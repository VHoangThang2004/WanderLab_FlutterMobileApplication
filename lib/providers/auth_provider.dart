import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database_helper.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setErrorMessage('');

    try {
      final user = await _dbHelper.getUserByEmail(email);

      if (user == null) {
        _setErrorMessage('Email không tồn tại');
        _setLoading(false);
        return false;
      }

      final hashedPassword = _hashPassword(password);
      if (user.passwordHash != hashedPassword) {
        _setErrorMessage('Sai mật khẩu');
        _setLoading(false);
        return false;
      }

      _currentUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setInt('userId', user.id!);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage('Lỗi đăng nhập: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    _setLoading(true);
    _setErrorMessage('');

    try {
      // Check if email already exists
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        _setErrorMessage('Email đã được sử dụng');
        _setLoading(false);
        return false;
      }

      final hashedPassword = _hashPassword(password);
      final newUser = UserModel(
        fullName: fullName,
        email: email,
        passwordHash: hashedPassword,
        createdAt: DateTime.now().toIso8601String(),
      );

      await _dbHelper.insertUser(newUser);
      
      // Auto login after registration could be done here if needed
      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage('Lỗi đăng ký: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile(String fullName) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _setErrorMessage('');

    try {
      await _dbHelper.updateProfile(_currentUser!.id!, fullName);
      // Update local state
      _currentUser = await _dbHelper.getUserById(_currentUser!.id!);
      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage('Lỗi cập nhật thông tin: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _setErrorMessage('');

    try {
      final hashedCurrentPassword = _hashPassword(currentPassword);
      if (_currentUser!.passwordHash != hashedCurrentPassword) {
        _setErrorMessage('Mật khẩu hiện tại không đúng');
        _setLoading(false);
        return false;
      }

      final hashedNewPassword = _hashPassword(newPassword);
      await _dbHelper.updatePassword(_currentUser!.id!, hashedNewPassword);
      
      // Update local state
      _currentUser = await _dbHelper.getUserById(_currentUser!.id!);
      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage('Lỗi đổi mật khẩu: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      final userId = prefs.getInt('userId');
      if (userId != null) {
        final user = await _dbHelper.getUserById(userId);
        if (user != null) {
          _currentUser = user;
          notifyListeners();
        } else {
          // If user doesn't exist in DB anymore, logout
          await logout();
        }
      } else {
        await logout();
      }
    }
  }
}
