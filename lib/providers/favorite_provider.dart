import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/destination_model.dart';

class FavoriteProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Destination> _favoriteDestinations = [];
  List<Destination> get favoriteDestinations => _favoriteDestinations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _favoriteDestinations = await _dbHelper.getFavoriteDestinationsForUser(userId);
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> toggleFavorite(int userId, int destinationId) async {
    try {
      final isNowFavorite = await _dbHelper.toggleFavorite(userId, destinationId);
      // Reload favorites list to stay updated
      await loadFavorites(userId);
      return isNowFavorite;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  bool isFavoriteLocally(int destinationId) {
    return _favoriteDestinations.any((dest) => dest.id == destinationId);
  }

  void clearFavoritesLocally() {
    _favoriteDestinations = [];
    notifyListeners();
  }
}
