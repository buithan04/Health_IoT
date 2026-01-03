import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_iot/service/prescription_service.dart'; // Đổi sang PrescriptionService
import 'package:app_iot/models/common/prescription_model.dart';

class DoctorPrescriptionDetailScreen extends StatefulWidget {
  final String prescriptionId;
  const DoctorPrescriptionDetailScreen({super.key, required this.prescriptionId});

  @override
  State<DoctorPrescriptionDetailScreen> createState() => _DoctorPrescriptionDetailScreenState();
}

class _DoctorPrescriptionDetailScreenState extends State<DoctorPrescriptionDetailScreen> {
  // Sử dụng PrescriptionService chuẩn
  final PrescriptionService _prescriptionService = PrescriptionService();

  Prescription? _detail;
  bool _isLoading = true;

  // Màu sắc
  final Color primaryColor = const Color(0xFF009688);
  final Color bgLight = const Color(0xFFF8F9FD);

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    final data = await _prescriptionService.getPrescriptionDetail(widget.prescriptionId);
    if (mounted) {
      setState(() {
        _detail = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: Text('Đơn thuốc #${widget.prescriptionId}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Nút In hoặc Share (Giả lập)
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Colors.black54),
            onPressed: () {},
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : _detail == null
          ? Center(child: Text("Không tìm thấy đơn thuốc", style: GoogleFonts.inter(color: Colors.grey)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- HEADER CARD (Thông tin chung) ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Text(
                      "THÔNG TIN ĐƠN THUỐC",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 1.2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.person_outline, "Bệnh nhân", _detail!.patientName),
                        const Divider(height: 24),
                        _buildDetailRow(Icons.calendar_today_outlined, "Ngày kê", "${_detail!.dateStr} - ${_detail!.timeStr}"),
                        const Divider(height: 24),
                        _buildDetailRow(Icons.medical_services_outlined, "Chẩn đoán", _detail!.diagnosis, isBold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- DANH SÁCH THUỐC ---
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text("DANH SÁCH THUỐC", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2)),
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _detail!.medications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final med = _detail!.medications[index];
                return _buildMedicationCard(index + 1, med);
              },
            ),

            const SizedBox(height: 24),

            // --- GHI CHÚ (LỜI DẶN) ---
            if(_detail!.notes.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates_outlined, size: 20, color: Colors.orange.shade800),
                        const SizedBox(width: 8),
                        Text("Lời dặn của bác sĩ", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_detail!.notes, style: GoogleFonts.inter(color: Colors.orange.shade900, height: 1.5)),
                  ],
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade400),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(label, style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 14)),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                height: 1.3
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(int index, MedicationItem med) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Text("$index", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: primaryColor),
                    const SizedBox(width: 4),
                    Expanded(child: Text(med.instruction, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700))),
                  ],
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(med.quantity, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: primaryColor)),
          )
        ],
      ),
    );
  }
}