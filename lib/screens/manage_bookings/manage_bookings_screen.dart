import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/notification_provider.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  @override
  void initState() {
    super.initState();
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
        return Colors.blue;
      case 'Hoàn thành':
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
        return Colors.blue.shade50;
      case 'Hoàn thành':
        return Colors.green.shade50;
      case 'Đã hủy':
        return Colors.red.shade50;
      case 'Chờ xác nhận':
      default:
        return Colors.amber.shade50;
    }
  }

  Future<void> _updateStatus(BuildContext context, int bookingId, String newStatus, int userId) async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    final success = await provider.updateBookingStatus(bookingId, newStatus, userId);
    
    if (!context.mounted) return;

    if (success) {
      // Gửi thông báo
      Provider.of<NotificationProvider>(context, listen: false).addNotification(
        userId: userId,
        title: 'Cập nhật vé #$bookingId',
        message: 'Trạng thái vé của bạn đã chuyển thành: $newStatus',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật trạng thái thành: $newStatus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra khi cập nhật.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    if (authProvider.currentUser == null) {
      return const Center(
        child: Text(
          'Vui lòng đăng nhập để xem quản lý đặt chỗ.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final userId = authProvider.currentUser!.id!;

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
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await bookingProvider.loadUserBookings(userId);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookingProvider.userBookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookingProvider.userBookings[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          booking.destinationName ?? 'Điểm đến',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Mã vé: #${booking.id.toString().padLeft(6, '0')}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
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
                              const SizedBox(height: 16),
                              
                              // Buttons to change status
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                    onPressed: () => _confirmDelete(context, booking.id!),
                                  ),
                                  TextButton(
                                    onPressed: () => _showBookingDetails(context, booking),
                                    child: const Text('Chi tiết'),
                                  ),
                                  const Spacer(),
                                  if (booking.status == 'Chờ xác nhận') ...[
                                    TextButton(
                                      onPressed: () => _updateStatus(context, booking.id!, 'Đã hủy', userId),
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text('Hủy'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _updateStatus(context, booking.id!, 'Đã xác nhận', userId),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                                      child: const Text('Xác nhận'),
                                    ),
                                  ] else if (booking.status == 'Đã xác nhận' || booking.status == 'Đã thanh toán') ...[
                                    ElevatedButton(
                                      onPressed: () => _updateStatus(context, booking.id!, 'Hoàn thành', userId),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                      child: const Text('Hoàn thành'),
                                    ),
                                  ],
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

  void _confirmDelete(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa vé đặt chỗ'),
        content: const Text('Bạn có chắc chắn muốn xóa vé này khỏi lịch sử không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = Provider.of<BookingProvider>(context, listen: false);
              final success = await provider.deleteBooking(bookingId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Đã xóa vé thành công.' : 'Có lỗi xảy ra khi xóa vé.'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(BuildContext context, dynamic booking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Chi tiết Đặt chỗ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 32),
              _buildDetailRow('Mã đặt chỗ', '#${booking.id.toString().padLeft(6, '0')}'),
              _buildDetailRow('Dịch vụ', booking.serviceName ?? ''),
              _buildDetailRow('Thời gian', '${booking.bookingDate} | ${booking.bookingTime}'),
              _buildDetailRow('Số khách', '${booking.guestCount} người'),
              _buildDetailRow('Tổng tiền', '${booking.totalPrice.toStringAsFixed(0)} VNĐ'),
              const Divider(height: 32),
              const Text(
                'Phương thức thanh toán:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.payment, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(booking.paymentMethod ?? 'Chưa xác định'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Đóng'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

