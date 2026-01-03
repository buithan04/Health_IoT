import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart'; // Đảm bảo đã cài thư viện này
import 'package:app_iot/service/doctor_service.dart';

class PatientStatsDetailScreen extends StatefulWidget {
  final String patientId;
  const PatientStatsDetailScreen({super.key, required this.patientId});

  @override
  State<PatientStatsDetailScreen> createState() => _PatientStatsDetailScreenState();
}

class _PatientStatsDetailScreenState extends State<PatientStatsDetailScreen> {
  final DoctorService _doctorService = DoctorService();
  bool _isLoading = true;
  Map<String, List<double>> _stats = {};

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final data = await _doctorService.getPatientHealthStats(widget.patientId);
    if (mounted) {
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Chỉ số sức khỏe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Dữ liệu 7 lần đo gần nhất từ thiết bị.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Nhịp tim (BPM)',
            color: Colors.red,
            data: _stats['heart_rate'] ?? [],
            minY: 40, maxY: 160,
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'SpO2 (%)',
            color: Colors.teal,
            data: _stats['spo2'] ?? [],
            minY: 80, maxY: 100,
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Thân nhiệt (°C)',
            color: Colors.orange,
            data: _stats['temp'] ?? [],
            minY: 34, maxY: 42,
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<double> data;
  final double minY;
  final double maxY;

  const _ChartCard({
    required this.title,
    required this.color,
    required this.data,
    this.minY = 0,
    this.maxY = 100,
  });

  @override
  Widget build(BuildContext context) {
    // Chuyển đổi dữ liệu sang FlSpot
    List<FlSpot> spots = [];
    if (data.isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        spots.add(FlSpot(i.toDouble(), data[i]));
      }
    }

    String currentValue = data.isNotEmpty ? data.last.toStringAsFixed(1) : "--";

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  currentValue,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              padding: const EdgeInsets.only(right: 16),
              child: data.isEmpty
                  ? const Center(child: Text("Chưa có dữ liệu"))
                  : LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (data.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}