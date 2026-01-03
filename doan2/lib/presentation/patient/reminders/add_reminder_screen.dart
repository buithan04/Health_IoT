import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_iot/service/reminder_service.dart';
import 'package:app_iot/models/patient/reminder_model.dart'; // Import Model

class AddReminderScreen extends StatefulWidget {
  final Reminder? reminder; // Thay Map bằng Object Reminder

  const AddReminderScreen({super.key, this.reminder});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final ReminderService _service = ReminderService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Nếu đang Sửa (reminder != null)
    if (widget.reminder != null) {
      _nameController.text = widget.reminder!.medicationName;
      _instructionController.text = widget.reminder!.instruction ?? '';
      _selectedTime = widget.reminder!.timeOfDay; // Dùng getter từ Model
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.teal),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên thuốc")));
      return;
    }
    setState(() => _isSaving = true);

    bool success;
    if (widget.reminder == null) {
      // Thêm mới
      success = await _service.addReminder(
          _nameController.text,
          _instructionController.text,
          _selectedTime
      );
    } else {
      // Cập nhật
      success = await _service.updateReminder(
          widget.reminder!.id, // Lấy ID từ Object
          name: _nameController.text,
          instruction: _instructionController.text,
          time: _selectedTime
      );
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      context.pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi khi lưu")));
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa nhắc nhở này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSaving = true);
      // Lấy ID từ Object
      final success = await _service.deleteReminder(widget.reminder!.id);

      if (success && mounted) {
        context.pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminder != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa' : 'Thêm nhắc nhở'),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _isSaving ? null : _delete,
            )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Thẻ chọn giờ
          InkWell(
            onTap: () => _selectTime(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.shade100),
                boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  const Text("GIỜ UỐNG THUỐC", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text(
                    _selectedTime.format(context),
                    style: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.teal),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(20)),
                    child: const Text("Nhấn để đổi giờ", style: TextStyle(color: Colors.teal, fontSize: 12)),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(controller: _nameController, label: "Tên thuốc", hint: "Ví dụ: Panadol", icon: Icons.medication_outlined),
          const SizedBox(height: 16),
          _buildTextField(controller: _instructionController, label: "Hướng dẫn", hint: "Ví dụ: 1 viên sau ăn", icon: Icons.description_outlined),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(isEditing ? 'Lưu thay đổi' : 'Tạo nhắc nhở', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required IconData icon}) {
    // ... Code cũ giữ nguyên
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}