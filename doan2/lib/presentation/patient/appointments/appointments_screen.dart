import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart'; // Đảm bảo thống nhất Font
import 'package:app_iot/service/appointment_service.dart';
import 'package:app_iot/models/common/appointment_model.dart';
import 'package:app_iot/presentation/widgets/custom_avatar.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final AppointmentService _appointmentService = AppointmentService();

  List<Appointment> _upcoming = [];
  List<Appointment> _completed = [];
  List<Appointment> _cancelled = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isLoading = true);
    final allApps = await _appointmentService.getMyAppointments();

    if (mounted) {
      setState(() {
        _upcoming = allApps.where((a) => a.status == 'pending' || a.status == 'confirmed').toList();
        _completed = allApps.where((a) => a.status == 'completed').toList();
        _cancelled = allApps.where((a) => a.status == 'cancelled').toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Lịch hẹn của tôi', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.teal,
          indicatorColor: Colors.teal,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Sắp tới'),
            Tab(text: 'Hoàn thành'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _AppointmentList(appointments: _upcoming, onRefresh: _fetchAppointments),
          _AppointmentList(appointments: _completed, onRefresh: _fetchAppointments),
          _AppointmentList(appointments: _cancelled, onRefresh: _fetchAppointments),
        ],
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<Appointment> appointments;
  final VoidCallback onRefresh;

  const _AppointmentList({required this.appointments, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("Danh sách trống", style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        separatorBuilder: (ctx, index) => const SizedBox(height: 12),
        itemBuilder: (ctx, index) => _AppointmentCard(appointment: appointments[index]),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;
    Color bgColor;

    switch (appointment.status) {
      case 'confirmed':
        statusText = 'Đã duyệt'; statusColor = Colors.green.shade700; bgColor = Colors.green.shade50; break;
      case 'pending':
        statusText = 'Chờ duyệt'; statusColor = Colors.orange.shade800; bgColor = Colors.orange.shade50; break;
      case 'cancelled':
        statusText = 'Đã hủy'; statusColor = Colors.red.shade700; bgColor = Colors.red.shade50; break;
      default:
        statusText = 'Hoàn thành'; statusColor = Colors.blue.shade700; bgColor = Colors.blue.shade50;
    }

    // Lấy tên dịch vụ (nếu không có thì fallback về Specialty)
    final serviceDisplay = appointment.serviceName ?? appointment.specialty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => context.push('/appointments/details/${appointment.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Bác sĩ
                    CustomAvatar(
                      imageUrl: appointment.avatarUrl,
                      radius: 26,
                      fallbackText: appointment.doctorName,
                    ),
                    const SizedBox(width: 14),

                    // Thông tin chính
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.doctorName,
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Hiển thị Tên Dịch Vụ (DATA MỚI)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              serviceDisplay,
                              style: GoogleFonts.inter(color: Colors.teal.shade700, fontSize: 12, fontWeight: FontWeight.w500),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Badge trạng thái
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                      child: Text(statusText,
                          style: GoogleFonts.inter(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                    )
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                // Dòng dưới: Ngày giờ & Giá tiền
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(appointment.fullDateTimeStr,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87)),
                      ],
                    ),
                    // Hiển thị giá tiền (DATA MỚI)
                    if (appointment.price != null)
                      Text(
                        "${(appointment.price! / 1000).toStringAsFixed(0)}k",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}