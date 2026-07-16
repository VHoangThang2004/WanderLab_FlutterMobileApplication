import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load bookings for the user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      if (userId != null) {
        Provider.of<BookingProvider>(context, listen: false).loadUserBookings(userId);
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã xác nhận':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      case 'Chờ xác nhận':
      default:
        return Colors.amber.shade800;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Đã xác nhận':
        return Colors.green.shade50;
      case 'Đã hủy':
        return Colors.red.shade50;
      case 'Chờ xác nhận':
      default:
        return Colors.amber.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    if (authProvider.currentUser == null) {
      return const Center(
        child: Text(
          'Vui lòng đăng nhập để xem lịch sử đặt chỗ.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return Scaffold(
      body: bookingProvider.isLoading && bookingProvider.userBookings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : bookingProvider.userBookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'Bạn chưa thực hiện đặt chỗ nào.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Các yêu cầu đặt chỗ của bạn sẽ hiển thị tại đây.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    final userId = authProvider.currentUser?.id;
                    if (userId != null) {
                      await bookingProvider.loadUserBookings(userId);
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookingProvider.userBookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookingProvider.userBookings[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Destination and Status Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      booking.destinationName ?? 'Điểm đến',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusBgColor(booking.status),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      booking.status,
                                      style: TextStyle(
                                        color: _getStatusColor(booking.status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),

                              // Booking Details
                              Row(
                                children: [
                                  Icon(Icons.confirmation_num_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      booking.serviceName ?? 'Dịch vụ',
                                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${booking.bookingDate}  |  ${booking.bookingTime}',
                                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.people_outline, size: 18, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Số lượng khách: ${booking.guestCount}',
                                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),

                              // Price & Date created
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Đặt ngày: ${booking.createdAt.substring(0, 10)}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Tổng tiền: ',
                                        style: TextStyle(fontSize: 13, color: Colors.grey),
                                      ),
                                      Text(
                                        '${booking.totalPrice.toStringAsFixed(0)} VNĐ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
