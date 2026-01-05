import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_iot/service/prescription_service.dart';
import 'package:health_iot/models/common/prescription_model.dart';
import 'package:health_iot/models/common/medication_model.dart';
import 'dart:async';

class ConsultationScreen extends StatefulWidget {
  // [CHUẨN HÓA] Nhận trực tiếp int, không nhận String nữa
  final int patientId;

  const ConsultationScreen({super.key, required this.patientId});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final PrescriptionService _prescriptionService = PrescriptionService();

  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();

  final List<MedicationItem> _medications = [];
  bool _isSubmitting = false;

  final Color primaryColor = const Color(0xFF009688);
  final Color bgLight = const Color(0xFFF8F9FD);

  @override
  void dispose() {
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addMedication(String name, String instruction, String quantity) {
    setState(() {
      _medications.add(MedicationItem(name: name, instruction: instruction, quantity: quantity));
    });
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  Future<void> _submitPrescription() async {
    // Validate dữ liệu đầu vào
    if (_diagnosisController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập chẩn đoán bệnh');
      return;
    }
    if (_medications.isEmpty) {
      _showErrorSnackBar('Đơn thuốc chưa có loại thuốc nào');
      return;
    }

    setState(() => _isSubmitting = true);

    // [CHUẨN HÓA] Không cần parse hay regex nữa vì widget.patientId đã là int chuẩn
    final success = await _prescriptionService.createPrescription(
      patientId: widget.patientId,
      diagnosis: _diagnosisController.text.trim(),
      notes: _notesController.text.trim(),
      medications: _medications,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      _showSuccessDialog();
    } else if (mounted) {
      _showErrorSnackBar('Có lỗi xảy ra, vui lòng thử lại');
    }
  }

  // ... (Giữ nguyên các hàm _showErrorSnackBar, _showSuccessDialog, _showAddMedicationDialog, build UI...)
  // Phần UI bên dưới của bạn đã khá ổn, chỉ cần giữ nguyên.

  // (Tôi rút gọn phần dưới để bạn dễ copy, logic UI không thay đổi)
  // ...

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.teal, size: 60),
            SizedBox(height: 16),
            Text("Kê đơn thành công!", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("Đơn thuốc đã được lưu và gửi đến hồ sơ bệnh nhân.", textAlign: TextAlign.center),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.teal,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Hoàn tất"),
          )
        ],
      ),
    );
  }

  // --- Copy lại phần _showAddMedicationDialog và build() từ file cũ của bạn vào đây ---
  // Lưu ý: Không thay đổi gì trong phần build(), code cũ của bạn đã hoạt động tốt với widget.patientId (nay là int).

  void _showAddMedicationDialog() {
    final nameCtrl = TextEditingController();
    final instructCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    Medication? selectedMed;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
          builder: (context, setSheetState) {
            void openSearchSheet() async {
              final Medication? result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const _MedicationSearchSheet(),
              );
              if (result != null) {
                setSheetState(() {
                  selectedMed = result;
                  nameCtrl.text = result.name;
                  if (result.defaultInstruction.isNotEmpty) instructCtrl.text = result.defaultInstruction;
                  qtyCtrl.text = "10 ${result.unit}";
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Thêm thuốc mới", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: openSearchSheet,
                      child: IgnorePointer(
                        child: _buildModernTextField(
                            controller: nameCtrl, label: "Tên thuốc", hint: "Chạm để tìm kiếm...", icon: Icons.search, isReadOnly: true
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(flex: 2, child: _buildModernTextField(controller: instructCtrl, label: "Cách dùng", hint: "Sáng 1 viên", icon: Icons.info_outline)),
                        const SizedBox(width: 12),
                        Expanded(flex: 1, child: _buildModernTextField(controller: qtyCtrl, label: "Số lượng", hint: "10 viên", icon: Icons.numbers)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: () {
                          if (nameCtrl.text.isNotEmpty && qtyCtrl.text.isNotEmpty) {
                            _addMedication(nameCtrl.text, instructCtrl.text, qtyCtrl.text);
                            Navigator.pop(context);
                          }
                        },
                        style: FilledButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text("Thêm vào đơn", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: Text('Kê đơn thuốc', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Chẩn đoán & Lời dặn"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                children: [
                  _buildModernTextField(controller: _diagnosisController, label: "Chẩn đoán bệnh (*)", hint: "Nhập tên bệnh...", icon: Icons.sick_outlined, isRequired: true),
                  const SizedBox(height: 16),
                  _buildModernTextField(controller: _notesController, label: "Lời dặn bác sĩ", hint: "Chế độ ăn uống, nghỉ ngơi...", icon: Icons.note_alt_outlined, maxLines: 3),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader("Danh sách thuốc (${_medications.length})"),
                TextButton.icon(
                  onPressed: _showAddMedicationDialog,
                  icon: Icon(Icons.add_circle_outline, color: primaryColor),
                  label: Text("Thêm thuốc", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(backgroundColor: primaryColor.withOpacity(0.1)),
                )
              ],
            ),
            const SizedBox(height: 12),
            if (_medications.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: Column(
                  children: [
                    Icon(Icons.medical_services_outlined, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text("Chưa có thuốc nào", style: GoogleFonts.inter(color: Colors.grey.shade500)),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _medications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final med = _medications[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))]),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.medication, color: Colors.blue.shade700),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(med.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(med.instruction, style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                              child: Text(med.quantity, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () => _removeMedication(index),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text("Xóa", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitPrescription,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            disabledBackgroundColor: primaryColor.withOpacity(0.6),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 4,
          ),
          child: _isSubmitting
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('LƯU & GỬI ĐƠN THUỐC', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    bool isReadOnly = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            children: isRequired ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: isReadOnly,
          enabled: !isReadOnly,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

// [PHẦN CÒN LẠI GIỮ NGUYÊN - CLASS _MedicationSearchSheet]
class _MedicationSearchSheet extends StatefulWidget {
  const _MedicationSearchSheet();

  @override
  State<_MedicationSearchSheet> createState() => _MedicationSearchSheetState();
}

class _MedicationSearchSheetState extends State<_MedicationSearchSheet> {
  final PrescriptionService _service = PrescriptionService();
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<Medication> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchMedicines('');
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchMedicines(query);
    });
  }

  Future<void> _searchMedicines(String query) async {
    setState(() => _isLoading = true);
    final data = await _service.searchMedications(query);
    if (mounted) {
      setState(() {
        _results = data;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Nhập tên thuốc để tìm...",
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                : _results.isEmpty
                ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text("Không tìm thấy thuốc", style: GoogleFonts.inter(color: Colors.grey)),
              ],
            ))
                : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _results.length,
              separatorBuilder: (_,__) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final med = _results[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(med.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
                  subtitle: Text("Đơn vị: ${med.unit}", style: GoogleFonts.inter(color: Colors.grey.shade600)),
                  trailing: const Icon(Icons.add_circle_outline, color: Colors.teal),
                  onTap: () {
                    Navigator.pop(context, med);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}