import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:app_iot/service/doctor_service.dart';

class ManageAvailabilityScreen extends StatefulWidget {
  const ManageAvailabilityScreen({super.key});

  @override
  State<ManageAvailabilityScreen> createState() => _ManageAvailabilityScreenState();
}

class _ManageAvailabilityScreenState extends State<ManageAvailabilityScreen> {
  final DoctorService _doctorService = DoctorService();
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedSlots = [];
  bool _isLoading = false;

  List<String> _allTimeSlots = [];

  @override
  void initState() {
    super.initState();
    // 1. SỬA: Chạy từ 4 (4h sáng) đến 23 (11h đêm)
    _allTimeSlots = _generateTimeSlots(startHour: 4, endHour: 23);
    _fetchAvailability();
  }

  // 2. SỬA: Hàm sinh giờ (Bỏ điều kiện if để lấy cả 23:30)
  List<String> _generateTimeSlots({required int startHour, required int endHour}) {
    List<String> slots = [];
    for (int i = startHour; i <= endHour; i++) {
      // Luôn thêm giờ chẵn (VD: 04:00, ..., 23:00)
      slots.add('${i.toString().padLeft(2, '0')}:00');

      // Luôn thêm giờ lẻ (VD: 04:30, ..., 23:30)
      // Đã bỏ điều kiện 'if (i != endHour)' để lấy được mốc 23:30 cuối cùng
      slots.add('${i.toString().padLeft(2, '0')}:30');
    }
    return slots;
  }

  Future<void> _fetchAvailability() async {
    setState(() => _isLoading = true);
    try {
      final slots = await _doctorService.getAvailableSlots(_selectedDate);
      if (mounted) {
        setState(() {
          _selectedSlots = slots;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAvailability() async {
    setState(() => _isLoading = true);
    final success = await _doctorService.saveAvailableSlots(_selectedDate, _selectedSlots);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lưu lịch thành công!"), backgroundColor: Colors.green)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lưu thất bại. Vui lòng kiểm tra lại."), backgroundColor: Colors.red)
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchAvailability();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Quản lý Lịch trống'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveAvailability,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text("LƯU", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.teal)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDateSelector(),
          const SizedBox(height: 16),
          Text(
            'Chọn các khung giờ bạn RẢNH để bệnh nhân có thể đặt lịch (Lưu ý: Lịch này sẽ áp dụng cho tất cả các ngày thứ ${DateFormat('E', 'vi').format(_selectedDate)}).',
            style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          _buildSlotsGrid(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    String dateText = DateFormat('EEEE, dd/MM/yyyy', 'vi').format(_selectedDate);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ngày làm việc", style: GoogleFonts.inter(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    dateText,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const Icon(Icons.calendar_month, color: Colors.teal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Giữ 4 cột để hiển thị nhiều giờ cho gọn
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.0,
      ),
      itemCount: _allTimeSlots.length,
      itemBuilder: (context, index) {
        final slot = _allTimeSlots[index];
        final isSelected = _selectedSlots.contains(slot);

        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedSlots.remove(slot);
              } else {
                _selectedSlots.add(slot);
              }
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? Colors.teal : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? Colors.teal : Colors.grey.shade300),
              boxShadow: isSelected ? [BoxShadow(color: Colors.teal.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))] : [],
            ),
            child: Center(
              child: Text(slot, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: isSelected ? Colors.white : Colors.grey[700])),
            ),
          ),
        );
      },
    );
  }
}