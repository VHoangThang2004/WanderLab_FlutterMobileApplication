import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/destination_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import 'booking_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final Destination destination;

  const BookingScreen({super.key, required this.destination});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    super.initState();
    // Load services for this destination
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false)
          .loadServices(widget.destination.id);
    });
  }

  Future<void> _selectDate(BuildContext context, BookingProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      provider.selectDate(picked);
    }
  }

  Future<void> _selectTime(BuildContext context, BookingProvider provider) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      provider.selectTime(picked);
    }
  }

  void _confirmBooking(BookingProvider provider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Bạn cần đăng nhập để đặt chỗ.')),
      );
      return;
    }

    if (provider.selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn dịch vụ.')),
      );
      return;
    }

    if (provider.selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày khởi hành.')),
      );
      return;
    }

    if (provider.selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn giờ khởi hành.')),
      );
      return;
    }

    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đặt chỗ'),
        content: Text(
          'Bạn có chắc chắn muốn đặt ${provider.selectedService?.name ?? "dịch vụ"} với tổng chi phí ${provider.totalPrice.toStringAsFixed(0)} VNĐ không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Có'),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    final booking = await provider.createBooking(userId: userId);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt chỗ trải nghiệm'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: provider.isLoading && provider.services.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination Info Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              widget.destination.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.destination.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        widget.destination.location,
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Service selection
                  const Text(
                    '1. Chọn dịch vụ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (provider.services.isEmpty)
                    const Text('Không tìm thấy dịch vụ nào cho điểm đến này.')
                  else
                    Column(
                      children: provider.services.map((service) {
                        final isSelected = provider.selectedService?.id == service.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => provider.selectService(service),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.secondaryContainer,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                service.category,
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                service.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          service.description,
                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${service.price.toStringAsFixed(0)} VNĐ / khách',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 24,
                                    )
                                  else
                                    Icon(
                                      Icons.radio_button_off,
                                      color: Colors.grey.shade400,
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),

                  // Date and Time selectors
                  const Text(
                    '2. Chọn ngày & giờ khởi hành',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context, provider),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            provider.selectedDate == null
                                ? 'Chọn ngày'
                                : '${provider.selectedDate!.day}/${provider.selectedDate!.month}/${provider.selectedDate!.year}',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectTime(context, provider),
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            provider.selectedTime == null
                                ? 'Chọn giờ'
                                : provider.selectedTime!.format(context),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Guest count selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '3. Số lượng khách',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: provider.guestCount > 1
                                ? () => provider.setGuestCount(provider.guestCount - 1)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              '${provider.guestCount}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            onPressed: () => provider.setGuestCount(provider.guestCount + 1),
                            icon: const Icon(Icons.add_circle_outline),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Pricing and Booking confirmation box
                  if (provider.selectedService != null) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng tiền tạm tính',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          '${provider.totalPrice.toStringAsFixed(0)} VNĐ',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : () => _confirmBooking(provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: provider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'XÁC NHẬN ĐẶT CHỖ',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
