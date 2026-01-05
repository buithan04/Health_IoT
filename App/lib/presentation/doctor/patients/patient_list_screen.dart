import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_iot/presentation/widgets/custom_avatar.dart';
import 'package:health_iot/service/doctor_service.dart';
import 'package:intl/intl.dart';
import 'package:health_iot/core/constants/app_config.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final DoctorService _doctorService = DoctorService();
  List<Map<String, dynamic>> _allPatients = []; // Danh sách gốc
  List<Map<String, dynamic>> _filteredPatients = []; // Danh sách hiển thị (đã lọc)
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPatients();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _allPatients.where((p) {
        final name = (p['patient_name'] ?? '').toString().toLowerCase();
        final phone = (p['phone_number'] ?? '').toString().toLowerCase();
        return name.contains(query) || phone.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchPatients() async {
    final data = await _doctorService.getMyPatients();
    if (mounted) {
      setState(() {
        _allPatients = data;
        _filteredPatients = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Màu nền sáng hiện đại
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Danh sách bệnh nhân',
          style: GoogleFonts.inter(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // --- THANH TÌM KIẾM ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên hoặc số điện thoại...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // --- DANH SÁCH ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text("Không tìm thấy bệnh nhân", style: GoogleFonts.inter(color: Colors.grey)),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredPatients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _ModernPatientCard(
                  patientData: _filteredPatients[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernPatientCard extends StatelessWidget {
  final Map<String, dynamic> patientData;

  const _ModernPatientCard({required this.patientData});

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientId = patientData['patient_id'].toString();
    final name = patientData['patient_name'] ?? 'Ẩn danh';
    final lastVisit = _formatDate(patientData['last_visit']);
    final phone = patientData['phone_number'] ?? '';
    String avatarUrl = patientData['avatar_url'] ?? '';

    avatarUrl = AppConfig.formatUrl(patientData['avatar_url']);

    return InkWell(
      onTap: () {
        // Truyền object data qua extra để màn hình sau không cần load lại thông tin cơ bản
        context.push('/doctor/patient-detail-menu', extra: patientData);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar với viền
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.teal.withOpacity(0.2), width: 2),
              ),
              child: CustomAvatar(
                imageUrl: avatarUrl,
                radius: 28,
                fallbackText: name,
                backgroundColor: Colors.grey[100],
              ),
            ),
            const SizedBox(width: 16),
            // Thông tin text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (phone.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(phone, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Khám gần nhất: $lastVisit',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.blue[800], fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}