import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_iot/service/reminder_service.dart';
import 'package:health_iot/models/patient/reminder_model.dart'; // Import Model

class MedicationRemindersScreen extends StatefulWidget {
  const MedicationRemindersScreen({super.key});

  @override
  State<MedicationRemindersScreen> createState() => _MedicationRemindersScreenState();
}

class _MedicationRemindersScreenState extends State<MedicationRemindersScreen> {
  final ReminderService _service = ReminderService();
  List<Reminder> _reminders = []; // Dùng List<Reminder>
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _service.getReminders(); // Trả về List<Reminder>
    if (mounted) {
      setState(() {
        _reminders = data;
        _isLoading = false;
      });
    }
  }

  // Xử lý Bật/Tắt dùng Model
  Future<void> _toggleActive(int id, bool value) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;

    // 1. Cập nhật giao diện ngay lập tức (Optimistic Update)
    final originalReminder = _reminders[index];
    setState(() {
      _reminders[index] = originalReminder.copyWith(isActive: value);
    });

    // 2. Gọi API
    final success = await _service.updateReminder(id, isActive: value);

    // 3. Nếu lỗi thì revert lại
    if (!success && mounted) {
      setState(() {
        _reminders[index] = originalReminder; // Quay về trạng thái cũ
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi kết nối")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Nhắc nhở uống thuốc', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.teal,
        child: _reminders.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _reminders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final reminder = _reminders[index]; // Object Reminder

            return _ReminderCard(
              name: reminder.medicationName, // Dùng property
              instruction: reminder.instruction ?? '',
              time: reminder.timeOfDay,      // Dùng getter đã xử lý trong Model
              isActive: reminder.isActive,
              onTap: () async {
                // Truyền cả object Reminder sang màn hình Edit
                final result = await context.push('/medication-reminders/edit', extra: reminder);
                if (result == true) {
                  setState(() => _isLoading = true);
                  _loadData();
                }
              },
              onChanged: (val) => _toggleActive(reminder.id, val),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Add không cần truyền tham số
          final result = await context.push('/medication-reminders/add');
          if (result == true) {
            setState(() => _isLoading = true);
            _loadData();
          }
        },
        backgroundColor: Colors.teal,
        // ... (Giữ nguyên style)
        icon: const Icon(Icons.add_alarm, size: 28),
        label: const Text('Tạo nhắc nhở', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    // ... (Giữ nguyên code UI cũ của bạn, không cần sửa)
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.notifications_off_outlined, size: 64, color: Colors.teal.shade300),
              ),
              const SizedBox(height: 24),
              Text("Chưa có nhắc nhở nào", style: GoogleFonts.inter(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Hãy thêm lịch uống thuốc để không bị quên nhé!", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

// ... Class _ReminderCard GIỮ NGUYÊN (Copy từ code cũ vào đây)
class _ReminderCard extends StatelessWidget {
  // Paste y nguyên code cũ của bạn vào đây
  final String name;
  final String instruction;
  final TimeOfDay time;
  final bool isActive;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTap;

  const _ReminderCard({
    required this.name,
    required this.instruction,
    required this.time,
    required this.isActive,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Màu sắc dựa trên trạng thái Active
    final Color cardColor = Colors.white;
    final Color timeBgColor = isActive ? const Color(0xFFE0F2F1) : const Color(0xFFEEEEEE); // Teal nhạt vs Xám nhạt
    final Color timeTextColor = isActive ? Colors.teal.shade700 : Colors.grey.shade500;
    final Color nameColor = isActive ? Colors.black87 : Colors.grey.shade500;
    final Color descColor = isActive ? Colors.grey.shade700 : Colors.grey.shade400;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20), // Bo góc lớn hơn
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Padding rộng hơn
            child: Row(
              children: [
                // 1. KHỐI THỜI GIAN (To và Nổi bật)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: timeBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        time.format(context),
                        style: GoogleFonts.inter(
                          fontSize: 26, // Font số to
                          fontWeight: FontWeight.w900,
                          color: timeTextColor,
                        ),
                      ),
                      Text(
                        time.period == DayPeriod.am ? "Sáng" : "Chiều",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: timeTextColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // 2. THÔNG TIN THUỐC
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Tên thuốc to hơn
                          color: nameColor,
                          decoration: !isActive ? TextDecoration.lineThrough : null, // Gạch ngang nếu tắt
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (instruction.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.description_outlined, size: 16, color: descColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                instruction,
                                style: GoogleFonts.inter(color: descColor, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // 3. NÚT BẬT/TẮT (Switch to hơn)
                Transform.scale(
                  scale: 1.1, // Phóng to nút switch 10%
                  child: Switch(
                    value: isActive,
                    onChanged: onChanged,
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.teal,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}