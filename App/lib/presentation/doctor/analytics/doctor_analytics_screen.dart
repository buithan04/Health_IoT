import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart'; // [QUAN TRỌNG] Phải import gói này
import '../../../../service/doctor_service.dart';

// --- 1. DATA MODELS (Đã sửa logic map ngày chuẩn xác) ---
class AnalyticsData {
  final String totalPatients;
  final String appointments;
  final String averageRating;
  final List<FlSpot> appointmentSpots;
  final List<String> appointmentLabels;
  final Map<String, double> diagnosesData;
  final List<double> demographicsData;

  const AnalyticsData({
    required this.totalPatients,
    required this.appointments,
    required this.averageRating,
    required this.appointmentSpots,
    required this.appointmentLabels,
    required this.diagnosesData,
    required this.demographicsData,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json, String period) {
    // 1. Line Chart: Map đúng label vào index (0..6 cho tuần, 0..11 cho năm)
    List<dynamic> chartRaw = json['chartData'] ?? [];
    List<FlSpot> spots = [];
    List<String> labels = [];

    if (period == 'week') {
      labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      List<double> values = List.filled(7, 0);

      for (var item in chartRaw) {
        // Backend trả về: "Mon", "Tue"...
        String rawLabel = (item['label'] ?? '').toString().trim();
        int index = _getDayIndex(rawLabel);
        if (index != -1) {
          values[index] = double.parse(item['value'].toString());
        }
      }
      for (int i = 0; i < values.length; i++) {
        spots.add(FlSpot(i.toDouble(), values[i]));
      }

    } else if (period == 'year') {
      labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      List<double> values = List.filled(12, 0);

      for (var item in chartRaw) {
        // Backend trả về: "Jan", "Feb"...
        String rawLabel = (item['label'] ?? '').toString().trim();
        int index = _getMonthIndex(rawLabel);
        if (index != -1) {
          values[index] = double.parse(item['value'].toString());
        }
      }
      for (int i = 0; i < values.length; i++) {
        spots.add(FlSpot(i.toDouble(), values[i]));
      }

    } else {
      // Month
      labels = ['Tuần 1', 'Tuần 2', 'Tuần 3', 'Tuần 4', 'Tuần 5'];
      List<double> values = List.filled(5, 0);

      for (var item in chartRaw) {
        String rawLabel = (item['label'] ?? '').toString().trim(); // "Tuần 1"...
        final match = RegExp(r'\d+').firstMatch(rawLabel);
        if (match != null) {
          int weekNum = int.parse(match.group(0)!);
          if (weekNum >= 1 && weekNum <= 5) {
            values[weekNum - 1] = double.parse(item['value'].toString());
          }
        }
      }
      for (int i = 0; i < values.length; i++) {
        spots.add(FlSpot(i.toDouble(), values[i]));
      }
    }

    // 2. Pie Chart
    Map<String, double> pieMap = {};
    List<dynamic> pieRaw = json['pieData'] ?? [];
    for (var item in pieRaw) {
      String key = item['label'] ?? 'Khác';
      if (key.length > 15) key = '${key.substring(0, 12)}...';
      pieMap[key] = double.parse(item['value'].toString());
    }
    if (pieMap.isEmpty) pieMap = {'Chưa có dữ liệu': 1};

    // 3. Demographics
    List<dynamic> demoRaw = json['demographicsData'] ?? [0,0,0,0];

    return AnalyticsData(
      totalPatients: json['totalPatients']?.toString() ?? '0',
      appointments: json['appointments']?.toString() ?? '0',
      averageRating: json['averageRating']?.toString() ?? '0.0',
      appointmentSpots: spots,
      appointmentLabels: labels,
      diagnosesData: pieMap,
      demographicsData: demoRaw.map((e) => double.parse(e.toString())).toList(),
    );
  }

  // Helpers
  static int _getDayIndex(String day) {
    switch (day) {
      case 'Mon': return 0;
      case 'Tue': return 1;
      case 'Wed': return 2;
      case 'Thu': return 3;
      case 'Fri': return 4;
      case 'Sat': return 5;
      case 'Sun': return 6;
      default: return -1;
    }
  }

  static int _getMonthIndex(String month) {
    switch (month) {
      case 'Jan': return 0;
      case 'Feb': return 1;
      case 'Mar': return 2;
      case 'Apr': return 3;
      case 'May': return 4;
      case 'Jun': return 5;
      case 'Jul': return 6;
      case 'Aug': return 7;
      case 'Sep': return 8;
      case 'Oct': return 9;
      case 'Nov': return 10;
      case 'Dec': return 11;
      default: return -1;
    }
  }
}

class DoctorAnalyticsScreen extends StatefulWidget {
  const DoctorAnalyticsScreen({super.key});

  @override
  State<DoctorAnalyticsScreen> createState() => _DoctorAnalyticsScreenState();
}

class _DoctorAnalyticsScreenState extends State<DoctorAnalyticsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final DoctorService _doctorService = DoctorService(); // Đảm bảo constructor DoctorService không cần tham số hoặc fix lại ở main

  bool _isLoading = true;
  AnalyticsData? _currentData;

  // Màu chủ đạo
  final Color primaryColor = const Color(0xFF009688);
  final Color bgLight = const Color(0xFFF8F9FD);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchData('week');
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      String period = 'week';
      if (_tabController.index == 1) period = 'month';
      if (_tabController.index == 2) period = 'year';
      _fetchData(period);
    }
  }

  Future<void> _fetchData(String period) async {
    setState(() => _isLoading = true);
    final json = await _doctorService.getAnalytics(period); // Đảm bảo hàm này có trong DoctorService

    if (mounted) {
      setState(() {
        if (json != null) {
          _currentData = AnalyticsData.fromJson(json, period);
        } else {
          _currentData = const AnalyticsData(
              totalPatients: '0', appointments: '0', averageRating: '0.0',
              appointmentSpots: [], appointmentLabels: [], diagnosesData: {}, demographicsData: [0,0,0,0]
          );
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Thống kê hiệu quả',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 20),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              padding: const EdgeInsets.all(4),
              indicator: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Tuần'),
                Tab(text: 'Tháng'),
                Tab(text: 'Năm'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : _currentData == null
          ? const Center(child: Text("Không có dữ liệu"))
          : _buildAnalyticsContent(_currentData!),
    );
  }

  Widget _buildAnalyticsContent(AnalyticsData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tổng quan", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          _buildSummaryRow(data),

          const SizedBox(height: 24),
          _ChartContainer(
            title: 'Xu hướng đặt lịch',
            subtitle: 'Số lượng lịch hẹn theo thời gian',
            icon: Icons.show_chart_rounded,
            iconColor: Colors.blueAccent,
            child: _ModernLineChart(spots: data.appointmentSpots, labels: data.appointmentLabels),
          ),

          const SizedBox(height: 20),
          _ChartContainer(
            title: 'Tỷ lệ dịch vụ',
            subtitle: 'Các loại hình khám phổ biến',
            icon: Icons.pie_chart_rounded,
            iconColor: Colors.orangeAccent,
            height: 320,
            child: _DonutChart(data: data.diagnosesData),
          ),

          const SizedBox(height: 20),
          _ChartContainer(
            title: 'Độ tuổi bệnh nhân',
            subtitle: 'Phân bố theo nhóm tuổi',
            icon: Icons.bar_chart_rounded,
            iconColor: Colors.purpleAccent,
            child: _ModernBarChart(data: data.demographicsData),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(AnalyticsData data) {
    return Row(
      children: [
        Expanded(child: _StatCard(title: 'Bệnh nhân', value: data.totalPatients, icon: Icons.people_alt_rounded, color: Colors.blue, bgColor: Colors.blue.shade50)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(title: 'Lịch hẹn', value: data.appointments, icon: Icons.calendar_month_rounded, color: Colors.teal, bgColor: Colors.teal.shade50)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(title: 'Đánh giá', value: data.averageRating, icon: Icons.star_rounded, color: Colors.orange, bgColor: Colors.orange.shade50, isRating: true)),
      ],
    );
  }
}

// UI COMPONENTS
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool isRating;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color, required this.bgColor, this.isRating = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(children: [
            Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            if (isRating) ...[const SizedBox(width: 4), const Icon(Icons.star, size: 16, color: Colors.amber)]
          ]),
        ],
      ),
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final double height;

  const _ChartContainer({required this.title, required this.subtitle, required this.icon, required this.iconColor, required this.child, this.height = 250});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)), Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]))]),
        ]),
        const SizedBox(height: 24),
        SizedBox(height: height, child: child),
      ]),
    );
  }
}

class _ModernLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> labels;
  const _ModernLineChart({required this.spots, required this.labels});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1, getTitlesWidget: (value, meta) {
            if (value.toInt() >= 0 && value.toInt() < labels.length) {
              return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(labels[value.toInt()], style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500)));
            }
            return const SizedBox();
          })),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots, isCurved: true, color: const Color(0xFF009688), barWidth: 4, isStrokeCapRound: true,
            dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: const Color(0xFF009688))),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [const Color(0xFF009688).withOpacity(0.2), const Color(0xFF009688).withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // tooltipRoundedRadius: 8, // Đã xóa
            getTooltipColor: (spot) => Colors.blueGrey.withOpacity(0.8), // (Tùy chọn) Thêm dòng này nếu muốn chỉnh màu nền
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                return LineTooltipItem(
                  '${touchedSpot.y.toInt()}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

class _DonutChart extends StatefulWidget {
  final Map<String, double> data;
  const _DonutChart({required this.data});

  @override
  State<_DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<_DonutChart> {
  int touchedIndex = -1;
  final List<Color> colors = [const Color(0xFF4FC3F7), const Color(0xFF4DB6AC), const Color(0xFFFFB74D), const Color(0xFF9575CD), const Color(0xFFE57373)];

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const Center(child: Text("Chưa có dữ liệu"));
    final chartSections = <PieChartSectionData>[];
    final indicators = <Widget>[];
    int colorIndex = 0;
    widget.data.forEach((key, value) {
      final isTouched = chartSections.length == touchedIndex;
      final color = colors[colorIndex % colors.length];
      chartSections.add(PieChartSectionData(value: value, title: value.toStringAsFixed(0), color: color, radius: isTouched ? 60 : 50, titleStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14), titlePositionPercentageOffset: 0.5));
      indicators.add(Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Text(key, style: GoogleFonts.inter(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)), const SizedBox(width: 4), Text("(${value.toInt()})", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey))]));
      colorIndex++;
    });

    return Column(children: [
      Expanded(flex: 2, child: PieChart(PieChartData(pieTouchData: PieTouchData(touchCallback: (event, response) { setState(() { if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) { touchedIndex = -1; return; } touchedIndex = response.touchedSection!.touchedSectionIndex; }); }), borderData: FlBorderData(show: false), sectionsSpace: 2, centerSpaceRadius: 40, sections: chartSections))),
      const SizedBox(height: 10),
      Expanded(flex: 1, child: SingleChildScrollView(child: Wrap(spacing: 16, runSpacing: 8, alignment: WrapAlignment.center, children: indicators)))
    ]);
  }
}

class _ModernBarChart extends StatelessWidget {
  final List<double> data;
  const _ModernBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final List<String> titles = ['<18', '18-35', '36-55', '>55'];
    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround, gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => value.toInt() < titles.length ? Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(titles[value.toInt()], style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12))) : const SizedBox()))),
      barGroups: List.generate(data.length, (index) => BarChartGroupData(x: index, barRods: [BarChartRodData(toY: data[index], gradient: const LinearGradient(colors: [Color(0xFFAB47BC), Color(0xFF7E57C2)], begin: Alignment.bottomCenter, end: Alignment.topCenter), width: 20, borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)), backDrawRodData: BackgroundBarChartRodData(show: true, toY: (data.isEmpty ? 10 : data.reduce((a, b) => a > b ? a : b) * 1.2), color: Colors.grey.shade100))])),
    ));
  }
}