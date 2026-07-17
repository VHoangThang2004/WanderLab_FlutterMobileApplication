import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/destination_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/notification_provider.dart';
import 'booking_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Destination destination;

  const PaymentScreen({super.key, required this.destination});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'Cash';
  bool _isProcessing = false;

  void _processPayment(BookingProvider provider, int userId) async {
    if (_selectedMethod != 'Cash') {
      setState(() {
        _isProcessing = true;
      });
      // Giả lập thời gian xử lý thanh toán 2 giây
      await Future.delayed(const Duration(seconds: 2));
    }

    String paymentMethodName = 'Tiền mặt';
    String status = 'Chờ xác nhận';

    if (_selectedMethod == 'MoMo') {
      paymentMethodName = 'Ví MoMo';
      status = 'Đã thanh toán';
    }

    // Tạo booking
    final booking = await provider.createBooking(
      userId: userId,
      status: status,
      paymentMethod: paymentMethodName,
    );

    if (_selectedMethod == 'MoMo' && booking != null && mounted) {
      Provider.of<NotificationProvider>(context, listen: false).addNotification(
        userId: userId,
        title: 'Thanh toán thành công',
        message: 'Giao dịch qua Ví MoMo thành công. Vé đặt chỗ của bạn đã được xác nhận!',
      );
    }

    if (_selectedMethod != 'Cash') {
      setState(() {
        _isProcessing = false;
      });
    }

    if (booking != null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              booking: booking,
              destination: widget.destination,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xảy ra lỗi khi tạo yêu cầu đặt chỗ.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Lỗi: Bạn chưa đăng nhập')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        centerTitle: true,
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Đang xử lý thanh toán...',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng thanh toán',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.totalPrice.toStringAsFixed(0)} VNĐ',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Phương thức thanh toán',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildPaymentMethod(
                    title: 'Ví MoMo',
                    icon: Icons.account_balance_wallet,
                    value: 'MoMo',
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethod(
                    title: 'Thanh toán tiền mặt (tại quầy)',
                    icon: Icons.money,
                    value: 'Cash',
                  ),
                ],
              ),
            ),
      bottomNavigationBar: !_isProcessing
          ? Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _processPayment(provider, userId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'THANH TOÁN NGAY',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildPaymentMethod({required String title, required IconData icon, required String value}) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade600),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
            else
              Icon(Icons.circle_outlined, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }


}
