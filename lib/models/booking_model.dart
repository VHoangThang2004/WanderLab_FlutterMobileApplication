class Booking {
  final int? id;
  final int userId;
  final int serviceId;
  final String bookingDate;
  final String bookingTime;
  final int guestCount;
  final String status;
  final double totalPrice;
  final String createdAt;
  final String? paymentMethod; // Thêm phương thức thanh toán

  // Helper fields for UI display populated via database join queries
  final String? serviceName;
  final String? destinationName;

  Booking({
    this.id,
    required this.userId,
    required this.serviceId,
    required this.bookingDate,
    required this.bookingTime,
    required this.guestCount,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    this.paymentMethod,
    this.serviceName,
    this.destinationName,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      userId: map['userId'],
      serviceId: map['serviceId'],
      bookingDate: map['bookingDate'],
      bookingTime: map['bookingTime'],
      guestCount: map['guestCount'],
      status: map['status'] ?? 'Chờ xác nhận',
      totalPrice: (map['totalPrice'] as num).toDouble(),
      createdAt: map['createdAt'],
      paymentMethod: map['paymentMethod'],
      serviceName: map['serviceName'],
      destinationName: map['destinationName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'serviceId': serviceId,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'guestCount': guestCount,
      'status': status,
      'totalPrice': totalPrice,
      'createdAt': createdAt,
      'paymentMethod': paymentMethod,
    };
  }
}
