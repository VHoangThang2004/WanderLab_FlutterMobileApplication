import 'package:flutter/material.dart';
import '../models/experience_log_model.dart';
import '../data/database_helper.dart';

class ExperienceProvider with ChangeNotifier {
  List<ExperienceLog> _logs = [];
  bool _isLoading = false;

  List<ExperienceLog> get logs => _logs;
  bool get isLoading => _isLoading;

  ExperienceProvider() {
    loadExperienceLogs();
  }

  Future<void> loadExperienceLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _logs = await DatabaseHelper.instance.getExperienceLogs();
    } catch (e) {
      debugPrint("Error loading experience logs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> postExperienceLog({
    required int userId,
    required int destinationId,
    required String title,
    required String content,
    required double rating,
    String? imageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newLog = ExperienceLog(
        userId: userId,
        destinationId: destinationId,
        title: title,
        content: content,
        rating: rating,
        imageUrl: imageUrl,
        createdAt: DateTime.now().toIso8601String(),
      );

      final result = await DatabaseHelper.instance.insertExperienceLog(newLog);
      if (result > 0) {
        await loadExperienceLogs();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error posting experience log: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
