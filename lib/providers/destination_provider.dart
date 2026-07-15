import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../data/database_helper.dart';

/// Bỏ dấu tiếng Việt để hỗ trợ tìm kiếm không dấu
String _removeDiacritics(String str) {
  const with_ = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'
      'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
  const without = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd'
      'AAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';

  final buffer = StringBuffer();
  for (final char in str.characters) {
    final idx = with_.indexOf(char);
    buffer.write(idx >= 0 ? without[idx] : char);
  }
  return buffer.toString();
}

class DestinationProvider with ChangeNotifier {
  List<Destination> _allDestinations = [];
  List<Destination> _filteredDestinations = [];
  
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  List<Destination> get destinations => _filteredDestinations;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  final List<String> categories = ['Tất cả', 'Biển', 'Núi', 'Văn hóa', 'Lịch sử'];

  DestinationProvider() {
    loadDestinations();
  }

  Future<void> loadDestinations() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allDestinations = await DatabaseHelper.instance.getDestinations();
      _applyFilters();
    } catch (e) {
      debugPrint("Error loading destinations: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchDestinations(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    // Chuẩn hóa query: lowercase + bỏ dấu
    final normalizedQuery = _removeDiacritics(_searchQuery.toLowerCase());

    _filteredDestinations = _allDestinations.where((destination) {
      final matchesCategory =
          _selectedCategory == 'Tất cả' || destination.category == _selectedCategory;

      // So sánh cả có dấu và không dấu
      final nameNorm = _removeDiacritics(destination.name.toLowerCase());
      final locationNorm = _removeDiacritics(destination.location.toLowerCase());

      final matchesSearch = normalizedQuery.isEmpty ||
          nameNorm.contains(normalizedQuery) ||
          locationNorm.contains(normalizedQuery) ||
          destination.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          destination.location.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
    notifyListeners();
  }
}
