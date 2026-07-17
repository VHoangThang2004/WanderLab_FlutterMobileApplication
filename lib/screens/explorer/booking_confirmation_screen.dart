import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../models/destination_model.dart';
import '../../providers/auth_provider.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;
  final Destination destination;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Xác nhận đặt chỗ'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Ngăn quay lại form
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 70,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đặt chỗ thành công!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cảm ơn bạn đã tin tưởng dịch vụ của chúng tôi.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Khung Biên lai (Ticket/Receipt style)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header của vé
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'MÃ ĐẶT CHỖ',
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        Text(
                          '#${booking.id.toString().padLeft(6, '0')}',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thông tin khách hàng
                        const Text(
                          'Thông tin khách hàng',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Khách hàng', currentUser?.fullName ?? 'Khách'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Email', currentUser?.email ?? 'Không có email'),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(),
                        ),
                        
                        // Thông tin dịch vụ & địa điểm
                        const Text(
                          'Thông tin dịch vụ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                destination.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    destination.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    booking.serviceName ?? 'Dịch vụ du lịch',
                                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Ngày đi', booking.bookingDate),
                        const SizedBox(height: 8),
                        _buildInfoRow('Giờ xuất phát', booking.bookingTime),
                        const SizedBox(height: 8),
                        _buildInfoRow('Số lượng khách', '${booking.guestCount} người'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Trạng thái', booking.status, isStatus: true),
                        
                        const SizedBox(height: 16.0),
                        
                        // Mô phỏng nét đứt
                        Row(
                          children: List.generate(30, (index) => Expanded(
                            child: Container(
                              color: index % 2 == 0 ? Colors.transparent : Colors.grey[300],
                              height: 1,
                            ),
                          )),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Tổng tiền
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng thanh toán',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${booking.totalPrice.toStringAsFixed(0)} VNĐ',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Mô phỏng Barcode / QR
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.qr_code_2, size: 80, color: Colors.grey[800]),
                              const SizedBox(height: 4),
                              Text('Quét mã này khi nhận dịch vụ', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'QUAY VỀ TRANG CHỦ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  // Chức năng tải hóa đơn (Mock)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã lưu biên lai vào máy.')),
                  );
                },
                child: Text('Tải biên lai PDF', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isStatus ? Colors.orange : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
