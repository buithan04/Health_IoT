import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_iot/presentation/widgets/custom_avatar.dart';
import 'package:app_iot/service/doctor_service.dart';
import 'package:app_iot/models/doctor/patient_record_model.dart';

class PatientRecordScreen extends StatefulWidget {
  final String patientId;
  const PatientRecordScreen({super.key, required this.patientId});

  @override
  State<PatientRecordScreen> createState() => _PatientRecordScreenState();
}

class _PatientRecordScreenState extends State<PatientRecordScreen> {
  final DoctorService _doctorService = DoctorService();
  bool _isLoading = true;
  PatientRecord? _record;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _doctorService.getPatientRecord(widget.patientId);
      if (mounted) {
        setState(() {
          _record = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải hồ sơ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Nền xám xanh nhạt hiện đại
      appBar: AppBar(
        title: const Text('Hồ sơ bệnh án'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
            color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F766E)))
          : _record == null
          ? const Center(child: Text("Không tải được hồ sơ"))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header & Thông tin hành chính
            _buildHeaderCard(),
            const SizedBox(height: 20),

            // 2. Liên hệ khẩn cấp (Nếu có)
            if (_record!.emergencyName != 'Không có' && _record!.emergencyName.isNotEmpty)
              _buildEmergencyContact(),

            const SizedBox(height: 24),

            // 3. Chỉ số cơ thể
            _buildSectionTitle("Chỉ số cơ thể"),
            const SizedBox(height: 12),
            _buildVitalSignsGrid(),
            const SizedBox(height: 24),

            // 4. Thông tin y tế (Dị ứng / Bệnh nền) - Đã sửa màu
            _buildSectionTitle("Thông tin y tế"),
            const SizedBox(height: 12),
            _buildMedicalAlertCard(),
            const SizedBox(height: 24),

            // 5. Lịch sử khám
            _buildSectionTitle("Lịch sử khám bệnh"),
            const SizedBox(height: 12),
            _buildHistoryList(),
            const SizedBox(height: 24),

            // 6. Đơn thuốc
            _buildSectionTitle("Đơn thuốc gần đây"),
            const SizedBox(height: 12),
            _buildPrescriptionList(),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _record != null
          ? _FooterButton(patientId: widget.patientId)
          : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF64748B), // Slate 500
        letterSpacing: 1.0,
      ),
    );
  }

  // --- WIDGETS CON ---

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF64748B).withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: CustomAvatar(
              imageUrl: _record!.avatarUrl,
              radius: 32,
              fallbackText: _record!.fullName,
              backgroundColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _record!.fullName,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: [
                    _buildTag(_record!.gender, Colors.blue.shade50, Colors.blue.shade700),
                    _buildTag("${_record!.age} tuổi", Colors.grey.shade100, Colors.grey.shade700),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.work_outline_rounded, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _record!.occupation.isNotEmpty ? _record!.occupation : "Chưa cập nhật nghề nghiệp",
                        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569)),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _record!.address,
                        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569)),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildEmergencyContact() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2), // Rose 50 (Nhẹ nhàng hơn Orange/Red)
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFFE11D48), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("LIÊN HỆ KHẨN CẤP", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFE11D48))),
                const SizedBox(height: 2),
                Text(
                  _record!.emergencyName,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF881337), fontSize: 14),
                ),
                Text(
                  _record!.emergencyPhone,
                  style: GoogleFonts.inter(color: const Color(0xFF9F1239), fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded),
            color: const Color(0xFFE11D48),
            style: IconButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {
              // Logic gọi điện
            },
          )
        ],
      ),
    );
  }

  Widget _buildVitalSignsGrid() {
    double bmi = 0;
    if (_record!.height > 0 && _record!.weight > 0) {
      double hM = _record!.height / 100;
      bmi = _record!.weight / (hM * hM);
    }

    return Row(
      children: [
        _buildVitalCard(Icons.bloodtype_rounded, "Nhóm máu", _record!.bloodType, const Color(0xFFEC4899), const Color(0xFFFDF2F8)), // Pink
        const SizedBox(width: 12),
        _buildVitalCard(Icons.monitor_weight_rounded, "Cân nặng", "${_record!.weight} kg", const Color(0xFF3B82F6), const Color(0xFFEFF6FF)), // Blue
        const SizedBox(width: 12),
        _buildVitalCard(Icons.height_rounded, "Chiều cao", "${_record!.height} cm", const Color(0xFF0D9488), const Color(0xFFF0FDFA)), // Teal
      ],
    );
  }

  Widget _buildVitalCard(IconData icon, String label, String value, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF64748B).withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1E293B))),
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  // --- SỬA PHẦN NÀY ĐỂ BỚT ĐỎ ---
  Widget _buildMedicalAlertCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF64748B).withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          _buildInfoRow(
              Icons.coronavirus_outlined,
              "Dị ứng",
              _record!.allergies,
              const Color(0xFFF59E0B) // Amber (Thay vì Đỏ)
          ),
          Divider(height: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16),
          _buildInfoRow(
              Icons.medical_information_outlined,
              "Bệnh mãn tính",
              _record!.chronicConditions,
              const Color(0xFF6366F1) // Indigo (Thay vì Đỏ)
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    bool hasData = value.isNotEmpty && value != 'Không' && value != 'Không có';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                const SizedBox(height: 4),
                Text(
                    value,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        color: hasData ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                        fontWeight: hasData ? FontWeight.w500 : FontWeight.normal
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    // A. Logic Lọc: Chỉ lấy các lịch có status là 'completed' hoặc 'done'
    // Lưu ý: Cần đảm bảo Backend trả về đúng chữ này, nếu không thì hiển thị hết.
    final completedHistory = _record!.history.where((h) {
      final s = h.status.toLowerCase();
      return s == 'completed' || s == 'done' || s == 'finished';
    }).toList();

    // Nếu không có lịch hoàn thành nào (hoặc backend chưa trả status), hiển thị list gốc hoặc rỗng
    final listToShow = completedHistory.isNotEmpty ? completedHistory : _record!.history;

    if (listToShow.isEmpty) {
      return _buildEmptyState("Chưa có lịch sử khám hoàn thành.");
    }

    return Column(
      children: listToShow.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // [QUAN TRỌNG] Bấm vào để xem chi tiết lịch hẹn
            onTap: () {
              // Điều hướng sang trang chi tiết lịch hẹn (DoctorAppointmentDetailScreen)
              // Đảm bảo route này đã khai báo trong AppRouter
              context.push('/doctor/appointment-details/${item.id}');
            },
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: const Icon(Icons.history_edu_rounded, color: Color(0xFF475569), size: 24),
            ),
            title: Text(
              item.notes.isNotEmpty ? item.notes : "Phiên khám bệnh",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1E293B)),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ngày khám
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(item.date, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Người khám & Nơi khám
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Bs. ${item.doctorName} • ${item.hospital}",
                          style: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 13),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.check, size: 16, color: Colors.green),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- 2. ĐƠN THUỐC (Thêm tên người kê) ---
  Widget _buildPrescriptionList() {
    if (_record!.prescriptions.isEmpty) {
      return _buildEmptyState("Chưa có đơn thuốc nào.");
    }
    return Column(
      children: _record!.prescriptions.map((p) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // Navigate xem chi tiết đơn thuốc (DoctorPrescriptionDetailScreen)
            onTap: () {
              context.push('/doctor/prescriptions/${p.id}');
            },
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFCCFBF1), // Teal 100
                  borderRadius: BorderRadius.circular(10)
              ),
              child: const Icon(Icons.medication_liquid_rounded, color: Color(0xFF0F766E), size: 24),
            ),
            title: Text(
                "Đơn thuốc #${p.id}",
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1E293B))
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chẩn đoán
                  Text(
                    "Chẩn đoán: ${p.diagnosis}",
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF334155), fontWeight: FontWeight.w500),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Người kê đơn & Ngày
                  Row(
                    children: [
                      const Icon(Icons.edit_note_rounded, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        "Bs. ${p.doctorName} • ${p.date}",
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFCBD5E1)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid)),
      child: Center(child: Text(text, style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13))),
    );
  }
}

class _FooterButton extends StatelessWidget {
  final String patientId;
  const _FooterButton({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          // [SỬA LỖI TẠI ĐÂY]
          // Sai: context.push('/doctor/consultation/patientId=$patientId');
          // -> Gây lỗi "Invalid radix-10" vì nó gửi chuỗi "patientId=9"

          // Đúng: Chỉ gửi giá trị ID
          context.push('/doctor/consultation/$patientId');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F766E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4, // Tăng độ nổi một chút cho đẹp
          shadowColor: const Color(0xFF0F766E).withOpacity(0.4),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        icon: const Icon(Icons.medication_liquid_rounded, size: 22), // Đổi icon thuốc cho hợp ngữ cảnh
        label: const Text('Kê đơn thuốc & Chẩn đoán'),
      ),
    );
  }
}