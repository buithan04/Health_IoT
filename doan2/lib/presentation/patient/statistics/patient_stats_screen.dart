import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:app_iot/models/patient/health_stat_model.dart'; // <--- IMPORT MODEL MỚI

// Màu chủ đạo & Nền (Có thể đưa vào Theme chung sau này)
const Color kPrimaryColor = Color(0xFF0F766E); // Teal 700
const Color kBackgroundColor = Color(0xFFF8FAFC); // Slate 50

// Hàm giả lập dữ liệu (Mock Data Generator)
// Trong thực tế, hàm này nên nằm ở một Service riêng (VD: HealthService)
List<HealthDataPoint> generateMockData(String type, String period) {
  final now = DateTime.now();
  final random = Random();
  List<HealthDataPoint> points = [];
  int count = period == 'day' ? 24 : (period == 'week' ? 7 : 30);

  double baseValue = type == 'heartRate' ? 75 : (type == 'spo2' ? 97 : 36.5);
  double variance = type == 'heartRate' ? 15 : (type == 'spo2' ? 2 : 0.5);

  for (int i = 0; i < count; i++) {
    DateTime time;
    if (period == 'day') {
      time = now.subtract(Duration(hours: count - 1 - i));
    } else {
      time = now.subtract(Duration(days: count - 1 - i));
    }
    double noise = (random.nextDouble() - 0.5) * variance;
    double val = baseValue + noise;
    if (type == 'spo2' && val > 100) val = 100;
    points.add(HealthDataPoint(time, val));
  }
  return points;
}

// =============================================================================
// MÀN HÌNH CHÍNH (DASHBOARD)
// =============================================================================

class PatientStatsScreen extends StatelessWidget {
  const PatientStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: Text('Theo dõi sức khỏe',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                labelColor: kPrimaryColor,
                unselectedLabelColor: Colors.grey.shade500,
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Hôm nay'),
                  Tab(text: 'Tuần này'),
                  Tab(text: 'Tháng này'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            _DashboardView(period: 'day'),
            _DashboardView(period: 'week'),
            _DashboardView(period: 'month'),
          ],
        ),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final String period;
  const _DashboardView({required this.period});

  @override
  Widget build(BuildContext context) {
    final hrData = generateMockData('heartRate', period);
    final spo2Data = generateMockData('spo2', period);
    final tempData = generateMockData('temperature', period);

    // Lấy config từ Model Static
    final configs = HealthConfigData.metrics;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 1. BIỂU ĐỒ TỔNG QUAN
        _DetailPieChart(
          hr: hrData.last.value,
          spo2: spo2Data.last.value,
          temp: tempData.last.value,
        ),

        const SizedBox(height: 24),
        Text("Chi tiết chỉ số", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 16),

        // 2. CÁC CARD METRIC
        // Duyệt qua Map config trong Model để render UI
        ...configs.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _HealthMetricCard(
              config: entry.value,
              data: entry.key == 'heartRate' ? hrData : (entry.key == 'spo2' ? spo2Data : tempData),
              period: period,
            ),
          );
        }),
        const SizedBox(height: 40),
      ],
    );
  }
}

// =============================================================================
// CÁC WIDGET CON (Đã được làm sạch code)
// =============================================================================

class _DetailPieChart extends StatelessWidget {
  final double hr;
  final double spo2;
  final double temp;

  const _DetailPieChart({required this.hr, required this.spo2, required this.temp});

  bool isNormal(String key, double val) {
    final conf = HealthConfigData.metrics[key]!;
    return val >= conf.minNormal && val <= conf.maxNormal;
  }

  @override
  Widget build(BuildContext context) {
    bool hrOk = isNormal('heartRate', hr);
    bool spo2Ok = isNormal('spo2', spo2);
    bool tempOk = isNormal('temperature', temp);

    int badCount = (hrOk ? 0 : 1) + (spo2Ok ? 0 : 1) + (tempOk ? 0 : 1);
    String centerText = badCount == 0 ? "Ổn định" : (badCount == 1 ? "Lưu ý" : "Cảnh báo");
    Color centerColor = badCount == 0 ? kPrimaryColor : (badCount == 1 ? Colors.orange : Colors.red);

    final metrics = HealthConfigData.metrics;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF64748B).withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tổng quan cơ thể", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              Icon(Icons.more_horiz, color: Colors.grey.shade400),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            color: metrics['heartRate']!.color.withOpacity(hrOk ? 1 : 0.4),
                            value: 1, title: '', radius: hrOk ? 25 : 15,
                            badgeWidget: _ChartBadge(Icons.favorite, Colors.white),
                            badgePositionPercentageOffset: .5,
                          ),
                          PieChartSectionData(
                            color: metrics['spo2']!.color.withOpacity(spo2Ok ? 1 : 0.4),
                            value: 1, title: '', radius: spo2Ok ? 25 : 15,
                            badgeWidget: _ChartBadge(Icons.water_drop, Colors.white),
                            badgePositionPercentageOffset: .5,
                          ),
                          PieChartSectionData(
                            color: metrics['temperature']!.color.withOpacity(tempOk ? 1 : 0.4),
                            value: 1, title: '', radius: tempOk ? 25 : 15,
                            badgeWidget: _ChartBadge(Icons.thermostat, Colors.white),
                            badgePositionPercentageOffset: .5,
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        centerText,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: centerColor),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(metrics['heartRate']!, hr, hrOk),
                    const SizedBox(height: 12),
                    _buildLegendItem(metrics['spo2']!, spo2, spo2Ok),
                    const SizedBox(height: 12),
                    _buildLegendItem(metrics['temperature']!, temp, tempOk),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(HealthMetricConfig config, double value, bool isOk) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: config.color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(config.title, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600))),
        Text("${value.toStringAsFixed(1)} ${config.unit}", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: isOk ? Colors.black87 : Colors.red)),
      ],
    );
  }
}

class _ChartBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _ChartBadge(this.icon, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
      child: Icon(icon, size: 14, color: color),
    );
  }
}

class _HealthMetricCard extends StatelessWidget {
  final HealthMetricConfig config;
  final List<HealthDataPoint> data;
  final String period;

  const _HealthMetricCard({required this.config, required this.data, required this.period});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final currentValue = data.last.value;
    final isNormal = currentValue >= config.minNormal && currentValue <= config.maxNormal;
    final statusText = isNormal ? "Bình thường" : (currentValue < config.minNormal ? "Thấp" : "Cao");
    final statusColor = isNormal ? const Color(0xFF22C55E) : (currentValue < config.minNormal ? Colors.orange : Colors.red);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => _MetricDetailScreen(config: config, data: data, period: period)));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: const Color(0xFF64748B).withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: config.color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Icon(config.icon, color: config.color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(config.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(currentValue.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(width: 4),
                          Text(config.unit, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(statusText, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  minY: data.map((e) => e.value).reduce(min) * 0.95,
                  maxY: data.map((e) => e.value).reduce(max) * 1.05,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                      isCurved: true,
                      color: config.color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [config.color.withOpacity(0.15), config.color.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
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

class _MetricDetailScreen extends StatefulWidget {
  final HealthMetricConfig config;
  final List<HealthDataPoint> data;
  final String period;

  const _MetricDetailScreen({required this.config, required this.data, required this.period});

  @override
  State<_MetricDetailScreen> createState() => _MetricDetailScreenState();
}

class _MetricDetailScreenState extends State<_MetricDetailScreen> {
  late double _avg;
  late double _min;
  late double _max;

  @override
  void initState() {
    super.initState();
    if (widget.data.isNotEmpty) {
      final values = widget.data.map((e) => e.value).toList();
      _min = values.reduce(min);
      _max = values.reduce(max);
      _avg = values.reduce((a, b) => a + b) / values.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: Text(widget.config.title, style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 280,
              padding: const EdgeInsets.fromLTRB(16, 24, 24, 0),
              color: widget.config.color.withOpacity(0.03),
              child: _buildInteractiveChart(),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Thống kê chi tiết", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _buildStatBox("Trung bình", _avg)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatBox("Thấp nhất", _min)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatBox("Cao nhất", _max)),
                  ]),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: kBackgroundColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [Icon(Icons.info_outline_rounded, size: 20, color: Colors.grey.shade600), const SizedBox(width: 8), Text("Thông tin y tế", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey.shade800))]),
                      const SizedBox(height: 8),
                      Text(widget.config.description, style: GoogleFonts.inter(height: 1.5, color: Colors.grey.shade600, fontSize: 14)),
                    ]),
                  ),
                  const SizedBox(height: 32),
                  Text("Lịch sử đo", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildHistoryList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: (widget.config.key == 'spo2') ? 2 : 20, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: (widget.data.length / 5).ceil().toDouble(), getTitlesWidget: (value, meta) {
            int idx = value.toInt();
            if (idx >= 0 && idx < widget.data.length) {
              DateTime time = widget.data[idx].time;
              String label = widget.period == 'day' ? DateFormat('HH:mm').format(time) : DateFormat('dd/MM').format(time);
              return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)));
            }
            return const SizedBox.shrink();
          })),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: widget.data.map((e) => e.value).reduce(min) * 0.98,
        maxY: widget.data.map((e) => e.value).reduce(max) * 1.02,
        lineBarsData: [
          LineChartBarData(
            spots: widget.data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
            isCurved: true,
            gradient: LinearGradient(colors: [widget.config.color, widget.config.color.withOpacity(0.5)]),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [widget.config.color.withOpacity(0.2), widget.config.color.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => Colors.grey.shade800,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final val = spot.y;
                final time = widget.data[spot.x.toInt()].time;
                final timeStr = widget.period == 'day' ? DateFormat('HH:mm').format(time) : DateFormat('dd/MM HH:mm').format(time);
                return LineTooltipItem("$timeStr\n", const TextStyle(color: Colors.white70, fontSize: 10), children: [TextSpan(text: "${val.toStringAsFixed(1)} ${widget.config.unit}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))]);
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))], border: Border.all(color: Colors.grey.shade100)),
      child: Column(children: [Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500)), const SizedBox(height: 4), Text(value.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)), Text(widget.config.unit, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade400))]),
    );
  }

  Widget _buildHistoryList() {
    final reversedData = widget.data.reversed.toList();
    return ListView.separated(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: reversedData.length,
      separatorBuilder: (ctx, index) => Divider(height: 1, color: Colors.grey.shade100),
      itemBuilder: (context, index) {
        final item = reversedData[index];
        final isNormal = item.value >= widget.config.minNormal && item.value <= widget.config.maxNormal;
        final statusColor = isNormal ? Colors.green : (item.value < widget.config.minNormal ? Colors.orange : Colors.red);
        return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(DateFormat('dd/MM - HH:mm').format(item.time), style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          Row(children: [Text("${item.value.toStringAsFixed(1)} ${widget.config.unit}", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(width: 8), Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor))])
        ]));
      },
    );
  }
}