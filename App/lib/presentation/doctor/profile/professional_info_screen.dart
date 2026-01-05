import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_iot/service/doctor_service.dart';
import 'package:health_iot/service/user_service.dart';
import 'package:health_iot/core/api/api_client.dart';

class ProfessionalInfoScreen extends StatefulWidget {
  const ProfessionalInfoScreen({super.key});

  @override
  State<ProfessionalInfoScreen> createState() => _ProfessionalInfoScreenState();
}

class _ProfessionalInfoScreenState extends State<ProfessionalInfoScreen> {
  final DoctorService _doctorService = DoctorService();
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  // --- DỮ LIỆU CỐ ĐỊNH ---
  final List<String> _specialties = [
    'Đa khoa', 'Tim mạch', 'Nhi khoa', 'Da liễu', 'Nha khoa',
    'Thần kinh', 'Tiêu hóa', 'Tai Mũi Họng', 'Mắt', 'Sản phụ khoa',
    'Chấn thương chỉnh hình', 'Y học cổ truyền'
  ];

  final List<String> _degrees = [
    'Cử nhân',
    'Bác sĩ',
    'Thạc sĩ',
    'Tiến sĩ',
    'CK I',
    'CK II',
    'Giáo sư',
    'Phó Giáo sư'
  ];

  final List<String> _availableLanguages = [
    'Tiếng Việt',
    'Tiếng Anh',
    'Tiếng Pháp',
    'Tiếng Trung',
    'Tiếng Nhật',
    'Tiếng Hàn',
    'Tiếng Đức',
    'Tiếng Nga'
  ];

  // Controllers
  final _experienceController = TextEditingController();
  final _licenseController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _addressController = TextEditingController();
  final _feeController = TextEditingController();
  final _bioController = TextEditingController();

  // State
  String? _selectedSpecialty;
  String? _selectedDegree;
  List<String> _selectedLanguages = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final user = await UserService(ApiClient()).getUserProfile();
    if (user != null && mounted) {
      final doctor = await _doctorService.getDoctorDetail(user.id.toString());
      if (doctor != null) {
        _experienceController.text = doctor.yearsOfExperience.toString();
        _licenseController.text = doctor.licenseNumber;
        _hospitalController.text = doctor.hospitalName;
        _addressController.text = doctor.clinicAddress;
        _feeController.text = doctor.consultationFee.toString();
        _bioController.text = doctor.bio;

        setState(() {
          _selectedSpecialty =
          _specialties.contains(doctor.specialty) ? doctor.specialty : null;
          if (_selectedSpecialty == null && doctor.specialty.isNotEmpty) {
            _specialties.add(doctor.specialty);
            _selectedSpecialty = doctor.specialty;
          }

          _selectedDegree =
          _degrees.contains(doctor.education) ? doctor.education : null;
          if (_selectedDegree == null && doctor.education.isNotEmpty) {
            _degrees.add(doctor.education);
            _selectedDegree = doctor.education;
          }

          _selectedLanguages = List.from(doctor.languages);
        });
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    final success = await _doctorService.updateProfessionalInfo({
      'specialty': _selectedSpecialty ?? 'Đa khoa',
      'experience': _experienceController.text,
      'hospital': _hospitalController.text,
      'license': _licenseController.text,
      'education': _selectedDegree ?? '',
      'fee': _feeController.text,
      'languages': _selectedLanguages,
      'bio': _bioController.text,
      'clinicAddress': _addressController.text,
    });

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công!'),
            backgroundColor: Colors.teal),
      );
      setState(() => _isEditing = false);
      _fetchData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lỗi cập nhật'), backgroundColor: Colors.red),
      );
    }
  }

  // --- HÀM HIỂN THỊ MODAL CHỌN NGÔN NGỮ ---
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Chọn ngôn ngữ", style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _availableLanguages.map((lang) {
                          final isSelected = _selectedLanguages.contains(lang);
                          return FilterChip(
                            label: Text(lang),
                            selected: isSelected,
                            selectedColor: Colors.teal.shade100,
                            checkmarkColor: Colors.teal,
                            labelStyle: GoogleFonts.inter(
                              color: isSelected ? Colors.teal.shade900 : Colors
                                  .black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            onSelected: (bool selected) {
                              setModalState(() {
                                if (selected) {
                                  _selectedLanguages.add(lang);
                                } else {
                                  _selectedLanguages.remove(lang);
                                }
                              });
                              // Cập nhật state của màn hình cha luôn để UI thay đổi realtime
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius
                            .circular(10)),
                      ),
                      child: const Text("Xong", style: TextStyle(color: Colors
                          .white)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Nền xám rất nhạt
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
              Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Hồ sơ Chuyên môn', style: GoogleFonts.inter(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: () => setState(() => _isEditing = !_isEditing),
              child: Text(
                _isEditing ? 'Hủy' : 'Sửa',
                style: GoogleFonts.inter(color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Thông tin chung"),
            _buildCardContainer([
              _buildModernDropdown(
                  "Chuyên khoa", Icons.medical_services_outlined, _specialties,
                  _selectedSpecialty, (val) =>
                  setState(() => _selectedSpecialty = val)),
              const SizedBox(height: 20),
              _buildModernInput(
                  "Kinh nghiệm (năm)", Icons.work_history_outlined,
                  _experienceController, isNumber: true),
              const SizedBox(height: 20),
              _buildModernInput(
                  "Số giấy phép (CCHN)", Icons.verified_user_outlined,
                  _licenseController),
            ]),

            const SizedBox(height: 32),
            _buildSectionHeader("Nơi làm việc & Chi phí"),
            _buildCardContainer([
              _buildModernInput(
                  "Tên bệnh viện / Phòng khám", Icons.local_hospital_outlined,
                  _hospitalController),
              const SizedBox(height: 20),
              _buildModernInput(
                  "Địa chỉ phòng khám", Icons.location_on_outlined,
                  _addressController, maxLines: 2),
              const SizedBox(height: 20),
              _buildModernInput(
                  "Giá khám (VNĐ)", Icons.attach_money, _feeController,
                  isNumber: true),
            ]),

            const SizedBox(height: 32),
            _buildSectionHeader("Học vấn & Ngôn ngữ"),
            _buildCardContainer([
              _buildModernDropdown(
                  "Học vấn / Bằng cấp", Icons.school_outlined, _degrees,
                  _selectedDegree, (val) =>
                  setState(() => _selectedDegree = val)),
              const SizedBox(height: 20),
              // Ngôn ngữ Custom
              _buildModernLanguageSelector(),
            ]),

            const SizedBox(height: 32),
            _buildSectionHeader("Giới thiệu"),
            _buildCardContainer([
              _buildModernInput(
                  "Tiểu sử (Bio)", Icons.info_outline, _bioController,
                  maxLines: 5),
            ]),

            const SizedBox(height: 40),
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    shadowColor: Colors.teal.withOpacity(0.3),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : Text('Lưu thay đổi', style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS GIAO DIỆN MỚI ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
            letterSpacing: 1.2
        ),
      ),
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // Input Field Mới: Label nằm trên, ô nhập có viền
  Widget _buildModernInput(String label, IconData icon,
      TextEditingController controller,
      {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.teal),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: _isEditing,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: GoogleFonts.inter(
              fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: _isEditing ? 'Nhập thông tin...' : 'Chưa cập nhật',
            hintStyle: GoogleFonts.inter(
                color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            filled: true,
            fillColor: _isEditing ? Colors.grey.shade50 : Colors.transparent,
            // Viền khi bình thường
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            // Viền khi focus
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.teal, width: 1.5),
            ),
            // Viền khi disable (chế độ xem)
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
          ),
        ),
      ],
    );
  }

  // Dropdown Mới
  Widget _buildModernDropdown(String label, IconData icon, List<String> items,
      String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.teal),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: _isEditing ? onChanged : null,
          style: GoogleFonts.inter(
              fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            filled: true,
            fillColor: _isEditing ? Colors.grey.shade50 : Colors.transparent,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.teal, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      ],
    );
  }

  // Chọn ngôn ngữ mới
  Widget _buildModernLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.language_outlined, size: 18, color: Colors.teal),
            const SizedBox(width: 8),
            Text("Ngôn ngữ", style: GoogleFonts.inter(fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700)),
          ],
        ),
        const SizedBox(height: 12),

        // Hiển thị danh sách đã chọn
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedLanguages.isEmpty
                ? [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200)
                ),
                child: Text("Chưa chọn ngôn ngữ nào", style: GoogleFonts.inter(
                    color: Colors.grey.shade500, fontSize: 13)),
              )
            ]
                : _selectedLanguages.map((lang) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal.shade100),
                ),
                child: Text(
                  lang,
                  style: GoogleFonts.inter(color: Colors.teal.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              );
            }).toList(),
          ),
        ),

        // Nút thêm ngôn ngữ (chỉ hiện khi edit)
        if (_isEditing) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: _showLanguagePicker,
            borderRadius: BorderRadius.circular(10),
            // Bo tròn để khớp với InkWell
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                // [FIX] Đổi dashed -> solid
                border: Border.all(color: Colors.teal.shade300,
                    style: BorderStyle.solid,
                    width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                        Icons.add_circle_outline, color: Colors.teal, size: 18),
                    const SizedBox(width: 6),
                    Text("Thêm ngôn ngữ", style: GoogleFonts.inter(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }
}