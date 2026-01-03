import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_iot/core/api/api_client.dart';
import 'package:app_iot/service/user_service.dart';
import 'package:app_iot/models/common/user_model.dart';

class HealthRecordScreen extends StatefulWidget {
  const HealthRecordScreen({super.key});

  @override
  State<HealthRecordScreen> createState() => _HealthRecordScreenState();
}

class _HealthRecordScreenState extends State<HealthRecordScreen> {
  // 1. Khởi tạo Service
  final UserService _userService = UserService(ApiClient());

  bool _isEditing = false;
  bool _isLoading = true;

  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _historyController;
  late final TextEditingController _allergyController;

  String _bmi = '-';

  // [MỚI] Biến cho nhóm máu
  String? _selectedBloodType;
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _historyController = TextEditingController();
    _allergyController = TextEditingController();

    _heightController.addListener(_calculateBmi);
    _weightController.addListener(_calculateBmi);

    _fetchHealthData();
  }

  // 2. Hàm lấy dữ liệu từ Server (ĐÃ SỬA LỖI NULL SAFETY)
  Future<void> _fetchHealthData() async {
    try {
      // 1. Đổi kiểu biến thành User? (cho phép null)
      final User? user = await _userService.getUserProfile();

      // 2. Thêm kiểm tra: Nếu user null thì dừng luôn
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // 3. Lúc này Dart hiểu biến 'user' chắc chắn có dữ liệu
      if (mounted) {
        setState(() {
          // Truy cập an toàn vào các thuộc tính
          _heightController.text = user.height?.toString() ?? '';
          _weightController.text = user.weight?.toString() ?? '';
          _historyController.text = user.medicalHistory ?? '';
          _allergyController.text = user.allergies ?? '';

          // Xử lý nhóm máu
          if (_bloodTypes.contains(user.bloodType)) {
            _selectedBloodType = user.bloodType;
          }

          _calculateBmi();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        print("Lỗi tải hồ sơ sức khỏe: $e");
      }
    }
  }

  // 3. Hàm Lưu dữ liệu
  Future<void> _saveHealthData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang lưu thông tin...')),
    );

    // Gom dữ liệu để gửi
    final Map<String, dynamic> updateData = {
      'height': _heightController.text,
      'weight': _weightController.text,
      'medical_history': _historyController.text,
      'allergies': _allergyController.text,
      'blood_type': _selectedBloodType, // [MỚI] Gửi nhóm máu lên server
    };

    final success = await _userService.updateProfile(updateData);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu hồ sơ sức khỏe!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi lưu dữ liệu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _heightController.removeListener(_calculateBmi);
    _weightController.removeListener(_calculateBmi);
    _heightController.dispose();
    _weightController.dispose();
    _historyController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  void _calculateBmi() {
    final double heightCm = double.tryParse(_heightController.text) ?? 0;
    final double weightKg = double.tryParse(_weightController.text) ?? 0;

    if (heightCm > 0 && weightKg > 0) {
      final double heightM = heightCm / 100;
      final double bmiValue = weightKg / (heightM * heightM);
      if (mounted) {
        setState(() {
          _bmi = bmiValue.toStringAsFixed(1);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _bmi = '-';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Hồ sơ sức khỏe',
          style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Text(
              _isEditing ? 'Hủy' : 'Sửa',
              style: GoogleFonts.inter(
                color: Colors.teal.shade500,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBodyMetricsCard(),
            const SizedBox(height: 16),
            _buildEditableInfoCard(
              title: 'Tiền sử bệnh lý',
              controller: _historyController,
              hint: 'Liệt kê các bệnh đã mắc...',
            ),
            const SizedBox(height: 16),
            _buildEditableInfoCard(
              title: 'Dị ứng',
              controller: _allergyController,
              hint: 'Liệt kê các dị ứng (nếu có)...',
            ),
            const SizedBox(height: 40),
            Visibility(
              visible: _isEditing,
              child: ElevatedButton(
                onPressed: _saveHealthData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade500,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                ),
                child: Text(
                  'Lưu thay đổi',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON ---

  Widget _buildBodyMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chỉ số cơ thể',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _EditableMetricItem(
                  label: 'Chiều cao',
                  unit: 'cm',
                  controller: _heightController,
                  isEditing: _isEditing,
                ),
              ),
              Expanded(
                child: _EditableMetricItem(
                  label: 'Cân nặng',
                  unit: 'kg',
                  controller: _weightController,
                  isEditing: _isEditing,
                ),
              ),
              Expanded(
                child: _MetricDisplayItem(label: 'BMI', value: _bmi, unit: ''),
              ),
            ],
          ),

          // [MỚI] Phần hiển thị Nhóm Máu
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Nhóm máu", style: GoogleFonts.inter(fontSize: 15, color: Colors.grey.shade600)),
              _buildBloodTypeSelector(),
            ],
          )
        ],
      ),
    );
  }

  // [MỚI] Widget chọn/hiển thị nhóm máu
  Widget _buildBloodTypeSelector() {
    if (_isEditing) {
      return Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedBloodType,
            hint: Text("--", style: GoogleFonts.inter(color: Colors.grey)),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
            items: _bloodTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedBloodType = newValue;
              });
            },
          ),
        ),
      );
    } else {
      // Chế độ xem (View Mode)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Text(
          _selectedBloodType ?? 'Chưa cập nhật',
          style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700
          ),
        ),
      );
    }
  }

  Widget _buildEditableInfoCard({
    required String title,
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: _isEditing,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.teal.shade500, width: 2),
              ),
            ),
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}

class _EditableMetricItem extends StatelessWidget {
  final String label;
  final String unit;
  final TextEditingController controller;
  final bool isEditing;

  const _EditableMetricItem({required this.label, required this.unit, required this.controller, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        isEditing
            ? SizedBox(
          width: 70,
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.teal.shade500, width: 2)),
            ),
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal.shade600),
          ),
        )
            : Text(controller.text.isEmpty ? '--' : controller.text, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal.shade600)),
        const SizedBox(height: 2),
        if (unit.isNotEmpty) Text(unit, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }
}

class _MetricDisplayItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _MetricDisplayItem({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Container(
          height: 44, // Cố định chiều cao cho thẳng hàng với ô input
          alignment: Alignment.center,
          child: Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal.shade600)),
        ),
        const SizedBox(height: 2),
        if (unit.isNotEmpty) Text(unit, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }
}