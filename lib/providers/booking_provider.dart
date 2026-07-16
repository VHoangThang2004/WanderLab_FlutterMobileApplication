import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../models/booking_model.dart';
import '../data/database_helper.dart';

class BookingProvider with ChangeNotifier {
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  
  // Selected booking parameters
  ServiceModel? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _guestCount = 1;

  List<Booking> _userBookings = [];

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  ServiceModel? get selectedService => _selectedService;
  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;
  int get guestCount => _guestCount;
  List<Booking> get userBookings => _userBookings;

  double get totalPrice {
    if (_selectedService == null) return 0.0;
    return _selectedService!.price * _guestCount;
  }

  void selectService(ServiceModel? service) {
    _selectedService = service;
    notifyListeners();
  }

  void selectDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void selectTime(TimeOfDay? time) {
    _selectedTime = time;
    notifyListeners();
  }

  void setGuestCount(int count) {
    if (count >= 1) {
      _guestCount = count;
      notifyListeners();
    }
  }

  void resetSelection() {
    _selectedService = null;
    _selectedDate = null;
    _selectedTime = null;
    _guestCount = 1;
  }

  Future<void> loadServices(int destinationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _services = await DatabaseHelper.instance.getServicesForDestination(destinationId);
      if (_services.isNotEmpty) {
        _selectedService = _services.first;
      } else {
        _selectedService = null;
      }
    } catch (e) {
      debugPrint("Error loading services: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking({required int userId}) async {
    if (_selectedService == null || _selectedDate == null || _selectedTime == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final bookingDateStr = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
      final bookingTimeStr = "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";

      final newBooking = Booking(
        userId: userId,
        serviceId: _selectedService!.id!,
        bookingDate: bookingDateStr,
        bookingTime: bookingTimeStr,
        guestCount: _guestCount,
        status: 'Chờ xác nhận',
        totalPrice: totalPrice,
        createdAt: DateTime.now().toIso8601String(),
      );

      final result = await DatabaseHelper.instance.insertBooking(newBooking);
      if (result > 0) {
        // Reload bookings
        await loadUserBookings(userId);
        resetSelection();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error creating booking: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserBookings(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userBookings = await DatabaseHelper.instance.getBookingsForUser(userId);
    } catch (e) {
      debugPrint("Error loading bookings for user: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
