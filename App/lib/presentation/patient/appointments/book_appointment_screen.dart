import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:health_iot/service/appointment_service.dart';
import 'package:health_iot/service/doctor_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String doctorId;
  final String? source; // 'reschedule' hoặc null
  final String? appointmentId; // ID lịch cũ nếu là reschedule

  const BookAppointmentScreen({
    super.key,
    required this.doctorId,
    this.source,
    this.appointmentId,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  final TextEditingController _reasonController = TextEditingController();

  List<dynamic> _weeklyAvailability = [];
  List<dynamic> _appointmentTypes = [];

  bool _isLoading = true;
  bool _isBooking = false;

  int _selectedDateIndex = 0;
  String? _selectedTime;
  String? _selectedTypeId;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // 1. Tải tất cả dữ liệu cùng lúc
  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _appointmentService.get7DayAvailability(widget.doctorId),
        _doctorService.getAppointmentTypes(widget.doctorId),
      ]);

      if (mounted) {
        setState(() {
          _weeklyAvailability = results[0];
          _appointmentTypes = results[1];

          // Tự động chọn loại dịch vụ đầu tiên nếu có (UX tốt hơn)
          if (_appointmentTypes.isNotEmpty) {
            _selectedTypeId = _appointmentTypes[0]['id'].toString();
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải dữ liệu: $e")),
        );
      }
    }
  }

  Future<void> _handleBooking() async {
    if (_selectedTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn loại dịch vụ!")));
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn giờ khám!")));
      return;
    }

    setState(() => _isBooking = true);

    try {
      final rawDateStr = _weeklyAvailability[_selectedDateIndex]['date'];

      // [QUAN TRỌNG] Chỉ lấy HH:mm, Service sẽ tự xử lý format chuẩn
      // Nếu backend cần HH:mm:ss, hãy để service lo.
      // Ở đây ta cứ gửi HH:mm cho an toàn, service mình đã fix logic cộng chuỗi rồi.
      final timeToSend = _selectedTime!;

      int typeIdInt = int.parse(_selectedTypeId!);

      bool success = false;
      if (widget.source == 'reschedule' && widget.appointmentId != null) {
        success = await _appointmentService.rescheduleAppointment(
          appointmentId: widget.appointmentId!,
          dateStr: rawDateStr,
          time: timeToSend,
          reason: _reasonController.text,
          typeId: typeIdInt.toString(),
        );
      } else {
        success = await _appointmentService.bookAppointment(
          doctorId: widget.doctorId,
          dateStr: rawDateStr,
          time: timeToSend,
          reason: _reasonController.text,
          typeId: typeIdInt.toString(),
        );
      }

      if (!mounted) return;
      setState(() => _isBooking = false);

      if (success) {
        final queryParams = "date=$rawDateStr&time=$_selectedTime";
        context.go('/find-doctor/profile/${widget.doctorId}/booking-success?rescheduled=${widget.source == 'reschedule'}&$queryParams');
      } else {
        // Nếu thất bại, hiển thị thông báo chung
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đặt lịch thất bại. Có thể bác sĩ đã nghỉ hoặc lỗi hệ thống."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isBooking = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(widget.source == 'reschedule' ? 'Đổi lịch hẹn' : 'Đặt lịch hẹn'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _weeklyAvailability.isEmpty
          ? const Center(child: Text("Không có lịch làm việc trong 7 ngày tới"))
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Chọn Dịch vụ
          const _SectionTitle(title: 'Loại dịch vụ'),
          const SizedBox(height: 12),
          _buildServiceDropdown(),

          const SizedBox(height: 24),

          // 2. Chọn Ngày
          const _SectionTitle(title: 'Chọn ngày'),
          const SizedBox(height: 16),
          _buildDateSelector(),

          const SizedBox(height: 24),

          // 3. Chọn Giờ
          const _SectionTitle(title: 'Giờ khám'),
          const SizedBox(height: 16),
          _buildTimeSlotGrid(),

          const SizedBox(height: 24),

          // 4. Ghi chú
          const _SectionTitle(title: 'Lý do khám (Ghi chú)'),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Triệu chứng, tiền sử bệnh...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ElevatedButton(
            onPressed: _isBooking ? null : _handleBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: Colors.teal.shade200,
            ),
            child: _isBooking
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Xác nhận', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceDropdown() {
    if (_appointmentTypes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
        child: const Text("Bác sĩ chưa cấu hình dịch vụ. Vui lòng liên hệ hỗ trợ.", style: TextStyle(color: Colors.orange)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTypeId,
          hint: const Text("Chọn hình thức khám"),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.teal),
          items: _appointmentTypes.map((type) {
            // Format giá tiền
            final price = NumberFormat.currency(locale: 'vi', symbol: 'đ').format(num.tryParse(type['price'].toString()) ?? 0);
            return DropdownMenuItem<String>(
              value: type['id'].toString(),
              child: Text("${type['name']} - $price", style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedTypeId = val),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 85,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _weeklyAvailability.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final dayData = _weeklyAvailability[index];
          final date = DateTime.parse(dayData['date']);
          final isSelected = index == _selectedDateIndex;

          return _DateChip(
            date: date,
            isSelected: isSelected,
            onTap: () => setState(() {
              _selectedDateIndex = index;
              _selectedTime = null; // Reset giờ khi đổi ngày
            }),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    final currentDayData = _weeklyAvailability[_selectedDateIndex];
    final String dateStr = currentDayData['date'];
    final bool isWorking = currentDayData['isWorking'];
    final List slots = currentDayData['slots'] ?? [];

    if (!isWorking && slots.isEmpty) {
      return _buildMessageContainer("Bác sĩ nghỉ vào ngày này.");
    }
    if (slots.isEmpty) {
      return _buildMessageContainer("Đã hết lịch trống trong ngày.");
    }

    // Thời gian hiện tại + 1 tiếng (Buffer time để không đặt sát giờ quá)
    final DateTime bufferTime = DateTime.now().add(const Duration(minutes: 1));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final String timeStr = slot['time'];
        final bool isBookedByOthers = slot['isBooked']; // Đã bị người khác đặt

        // Logic kiểm tra quá giờ
        bool isExpired = false;
        try {
          DateTime slotDateTime = DateTime.parse("$dateStr $timeStr:00");
          if (slotDateTime.isBefore(bufferTime)) {
            isExpired = true;
          }
        } catch (e) {
          print("Parse Error: $e");
        }

        // Slot không chọn được
        final bool isDisabled = isBookedByOthers || isExpired;
        final bool isSelected = _selectedTime == timeStr;

        return _TimeChip(
          time: timeStr,
          status: isBookedByOthers ? TimeSlotStatus.booked : (isExpired ? TimeSlotStatus.expired : TimeSlotStatus.available),
          isSelected: isSelected,
          onTap: isDisabled ? null : () => setState(() => _selectedTime = timeStr),
        );
      },
    );
  }

  Widget _buildMessageContainer(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Center(child: Text(msg, style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic))),
    );
  }
}

// ================= WIDGETS CON =================

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87));
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateChip({required this.date, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == DateFormat('yyyy-MM-dd').format(date);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 68,
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
          border: isSelected ? null : Border.all(color: isToday ? Colors.teal.withOpacity(0.5) : Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(DateFormat('E', 'vi').format(date),
                style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(date.day.toString(),
                style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

enum TimeSlotStatus { available, booked, expired }

class _TimeChip extends StatelessWidget {
  final String time;
  final TimeSlotStatus status;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TimeChip({required this.time, required this.status, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color textColor = Colors.black87;
    BoxBorder? border = Border.all(color: Colors.grey.shade300);
    TextDecoration? decoration;

    switch (status) {
      case TimeSlotStatus.booked:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade400;
        border = null;
        decoration = TextDecoration.lineThrough;
        break;
      case TimeSlotStatus.expired:
        bgColor = Colors.grey.shade100.withOpacity(0.5);
        textColor = Colors.grey.shade300;
        border = Border.all(color: Colors.grey.shade200);
        break;
      case TimeSlotStatus.available:
        if (isSelected) {
          bgColor = Colors.teal;
          textColor = Colors.white;
          border = null;
        }
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10), border: border),
        child: Center(
          child: Text(
            time,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: textColor,
              decoration: decoration,
              decorationColor: Colors.black45,
            ),
          ),
        ),
      ),
    );
  }
}