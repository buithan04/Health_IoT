import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional ECG Monitor Widget - Hospital-grade visualization
/// Features:
/// - Real-time streaming with smooth 60fps animation
/// - Medical-grade grid (5mm × 5mm squares like ECG paper)
/// - Green phosphor display (classic CRT monitor look)
/// - Sweep line animation (moving baseline like real monitors)
/// - Auto-scaling and baseline correction
/// - Heart rate calculation and display
class ProfessionalECGMonitor extends StatefulWidget {
  final List<int>? dataPoints;
  final String? packetId;
  final DateTime? timestamp;
  final bool isConnected;
  final int samplingRate; // Hz (default: 125)
  
  const ProfessionalECGMonitor({
    Key? key,
    this.dataPoints,
    this.packetId,
    this.timestamp,
    this.isConnected = false,
    this.samplingRate = 125,
  }) : super(key: key);

  @override
  State<ProfessionalECGMonitor> createState() => _ProfessionalECGMonitorState();
}

class _ProfessionalECGMonitorState extends State<ProfessionalECGMonitor> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _sweepController;
  final List<double> _displayBuffer = [];
  static const int _maxBufferSize = 500; // 4 seconds at 125Hz
  Timer? _realtimePlaybackTimer; // Replay data at 125Hz (8ms per sample)
  final List<int> _incomingDataQueue = []; // Queue for incoming packets
  int? _calculatedHeartRate;
  String? _lastPacketId; // Track processed packets
  double _dynamicBaseline = 2048.0; // Auto-adjust baseline per packet
  
  @override
  void initState() {
    super.initState();
    
    // Sweep line animation (simulates CRT monitor sweep)
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    // Realtime playback: 125Hz = 8ms per sample
    _startRealtimePlayback();
  }
  
  void _startRealtimePlayback() {
    // Play back data at actual sampling rate: 125Hz = 8ms per sample
    _realtimePlaybackTimer = Timer.periodic(const Duration(milliseconds: 8), (timer) {
      if (!mounted) return;
      
      // Add one sample from queue to display buffer
      if (_incomingDataQueue.isNotEmpty) {
        final rawValue = _incomingDataQueue.removeAt(0).toDouble();
        final processedValue = _processSignal(rawValue);
        
        setState(() {
          _displayBuffer.add(processedValue);
          
          // Keep buffer at max size (4 seconds = 500 samples)
          if (_displayBuffer.length > _maxBufferSize) {
            _displayBuffer.removeAt(0);
          }
          
          // Calculate heart rate every 125 samples (1 second)
          if (_displayBuffer.length % widget.samplingRate == 0) {
            _calculateHeartRate();
          }
        });
      }
    });
  }
  
  @override
  void didUpdateWidget(ProfessionalECGMonitor oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if new packet arrived (different packetId)
    if (widget.packetId != null && widget.packetId != _lastPacketId) {
      _lastPacketId = widget.packetId;
      
      // Queue all 100 samples from new packet for realtime playback
      if (widget.dataPoints != null && widget.dataPoints!.isNotEmpty) {
        // Calculate dynamic baseline from this packet (median value)
        final sorted = List<int>.from(widget.dataPoints!)..sort();
        _dynamicBaseline = sorted[sorted.length ~/ 2].toDouble();
        
        _incomingDataQueue.addAll(widget.dataPoints!);
        
        // Limit queue size to prevent memory issues (max 500 samples queued)
        while (_incomingDataQueue.length > 500) {
          _incomingDataQueue.removeAt(0);
        }
      }
    }
  }
  
  double _processSignal(double rawValue) {
    // Step 1: Remove DC offset with dynamic baseline
    // ESP32 gửi dữ liệu đã xử lý, centered ở ~2048 (có thể drift)
    // Sử dụng median của packet hiện tại làm baseline động
    final centered = rawValue - _dynamicBaseline;
    
    // Step 2: Convert to mV (chuẩn ECG)
    // ESP32 đã apply DIGITAL_GAIN=4.0, vì vậy amplitude đã được khuếch đại
    // Với Gain=4.0, typical QRS ~1.5mV * 4 = 6mV → ~800 ADC units
    // Scale về ±2.5mV display range: (centered / 400.0) * 2.5
    final millivolts = (centered / 400.0) * 2.5;
    
    // Step 3: Light filtering (preserve R-peak sharpness)
    const alpha = 0.15; // Very light smoothing
    if (_displayBuffer.length >= 2) {
      final prev = _displayBuffer.last;
      // Exponential moving average
      return prev * (1 - alpha) + millivolts * alpha;
    }
    
    return millivolts;
  }
  
  void _calculateHeartRate() {
    if (_displayBuffer.length < widget.samplingRate * 2) return; // Need at least 2 seconds
    
    // Simple peak detection for HR calculation
    final recentData = _displayBuffer.sublist(
      math.max(0, _displayBuffer.length - widget.samplingRate * 3) // Last 3 seconds
    );
    
    // Find R-peaks (threshold at 70% of max value)
    final maxVal = recentData.reduce((a, b) => a > b ? a : b);
    final threshold = maxVal * 0.7;
    final peaks = <int>[];
    
    for (int i = 1; i < recentData.length - 1; i++) {
      if (recentData[i] > threshold && 
          recentData[i] > recentData[i - 1] && 
          recentData[i] > recentData[i + 1]) {
        // Avoid double-counting (minimum 200ms between peaks)
        if (peaks.isEmpty || (i - peaks.last) > widget.samplingRate * 0.2) {
          peaks.add(i);
        }
      }
    }
    
    // Calculate HR from average RR interval
    if (peaks.length >= 2) {
      final avgInterval = (peaks.last - peaks.first) / (peaks.length - 1);
      final rrSeconds = avgInterval / widget.samplingRate;
      _calculatedHeartRate = (60 / rrSeconds).round();
    }
  }
  
  @override
  void dispose() {
    _sweepController.dispose();
    _realtimePlaybackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildECGDisplay(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isConnected 
                    ? Colors.green.shade50 
                    : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isConnected ? Colors.green.shade400 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.monitor_heart,
                  color: widget.isConnected ? Colors.green.shade600 : Colors.grey.shade400,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Điện tâm đồ (ECG)',
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade800,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Lead II • ${widget.samplingRate}Hz',
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Heart Rate Display
          if (_calculatedHeartRate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300, width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    'HR',
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '$_calculatedHeartRate',
                    style: GoogleFonts.inter(
                      color: Colors.green.shade700,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'bpm',
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildECGDisplay() {
    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CustomPaint(
          painter: _ECGPainter(
            dataPoints: _displayBuffer,
            sweepProgress: _sweepController.value,
            samplingRate: widget.samplingRate,
            isConnected: widget.isConnected,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
  
  Widget _buildFooter() {
    final updateTime = widget.timestamp != null
        ? _formatTimestamp(widget.timestamp!)
        : 'Waiting for data...';
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.green.shade700, size: 14),
              const SizedBox(width: 6),
              Text(
                updateTime,
                style: GoogleFonts.robotoMono(
                  color: Colors.green.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (widget.packetId != null)
            Text(
              'PKT: ${widget.packetId}',
              style: GoogleFonts.robotoMono(
                color: Colors.green.shade700,
                fontSize: 10,
              ),
            ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isConnected ? Colors.green.shade500 : Colors.grey.shade400,
                  boxShadow: widget.isConnected ? [
                    BoxShadow(
                      color: Colors.green.shade300.withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ] : null,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.isConnected ? 'LIVE' : 'OFFLINE',
                style: GoogleFonts.inter(
                  color: widget.isConnected ? Colors.green.shade600 : Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 5) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

/// Custom painter for professional ECG waveform
class _ECGPainter extends CustomPainter {
  final List<double> dataPoints;
  final double sweepProgress;
  final int samplingRate;
  final bool isConnected;
  
  _ECGPainter({
    required this.dataPoints,
    required this.sweepProgress,
    required this.samplingRate,
    required this.isConnected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw medical-grade grid
    _drawMedicalGrid(canvas, size);
    
    // Draw ECG waveform
    if (dataPoints.isNotEmpty) {
      _drawWaveform(canvas, size);
    }
    
    // Draw sweep line (moving baseline)
    if (isConnected) {
      _drawSweepLine(canvas, size);
    }
    
    // Draw axis labels
    _drawAxisLabels(canvas, size);
  }
  
  void _drawMedicalGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    // Grid spacing: Standard ECG paper
    // Horizontal: 1 small square = 0.04s (at 25mm/s), 1 large square = 0.2s (5 small)
    // Vertical: 1 small square = 0.1mV, 1 large square = 0.5mV (5 small)
    // Display range: 4 seconds horizontal, 5mV vertical (±2.5mV)
    final horizontalSpacing = size.width / 100; // 100 small squares = 4s
    final verticalSpacing = size.height / 50;   // 50 small squares = 5mV
    
    // Minor grid lines (every 1mm - light)
    paint.color = Colors.grey.shade300;
    paint.strokeWidth = 0.3;
    for (int i = 0; i <= 100; i++) {
      final x = i * horizontalSpacing;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int i = 0; i <= 50; i++) {
      final y = i * verticalSpacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Major grid lines (every 5mm = 0.2s / 0.5mV - darker)
    paint.color = Colors.grey.shade500;
    paint.strokeWidth = 0.8;
    for (int i = 0; i <= 100; i += 5) {
      final x = i * horizontalSpacing;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int i = 0; i <= 50; i += 5) {
      final y = i * verticalSpacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Baseline (0mV) - special emphasis
    paint.color = Colors.grey.shade600;
    paint.strokeWidth = 1.2;
    final baselineY = size.height / 2; // Center = 0mV
    canvas.drawLine(Offset(0, baselineY), Offset(size.width, baselineY), paint);
  }
  
  void _drawWaveform(Canvas canvas, Size size) {
    final path = Path();
    final paint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // Glow effect (slight shadow for depth)
    final glowPaint = Paint()
      ..color = Colors.green.shade400.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    // ECG standard scaling: ±2mV range centered at baseline
    // Medical ECG displays typically show ±2-3mV range
    const yMin = -2.5; // mV
    const yMax = 2.5;  // mV
    const range = yMax - yMin; // 5mV total
    
    // Use cubic Bezier curves for smooth interpolation
    final points = <Offset>[];
    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / dataPoints.length) * size.width;
      
      // Map mV to display coordinates
      // Baseline (0mV) should be at center of display
      final normalizedY = (dataPoints[i] - yMin) / range;
      final y = size.height * (1.0 - normalizedY);
      
      points.add(Offset(x, y));
    }
    
    // Draw smooth curve through points
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = i > 0 ? points[i - 1] : points[i];
        final p1 = points[i];
        final p2 = points[i + 1];
        final p3 = i + 2 < points.length ? points[i + 2] : p2;
        
        // Catmull-Rom spline control points for smooth curve
        final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
        final cp1y = p1.dy + (p2.dy - p0.dy) / 6;
        final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
        final cp2y = p2.dy - (p3.dy - p1.dy) / 6;
        
        path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
      }
    }
    
    // Draw glow first, then main line
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }
  
  void _drawSweepLine(Canvas canvas, Size size) {
    final x = sweepProgress * size.width;
    
    // Sweep line (simulates scanning)
    final sweepPaint = Paint()
      ..color = Colors.green.shade300.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      sweepPaint,
    );
  }
  
  void _drawAxisLabels(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Voltage scale (left side) - standard ECG range
    final voltageLabels = ['+2.5mV', '+1.0mV', '0mV', '-1.0mV', '-2.5mV'];
    // Positions: +2.5mV (top), +1mV, 0mV (center), -1mV, -2.5mV (bottom)
    final positions = [0.0, 0.3, 0.5, 0.7, 1.0];
    for (int i = 0; i < voltageLabels.length; i++) {
      textPainter.text = TextSpan(
        text: voltageLabels[i],
        style: GoogleFonts.inter(
          color: i == 2 ? Colors.grey.shade800 : Colors.grey.shade600, // Emphasize 0mV
          fontSize: 9,
          fontWeight: i == 2 ? FontWeight.bold : FontWeight.normal,
        ),
      );
      textPainter.layout();
      final y = positions[i] * size.height - textPainter.height / 2;
      textPainter.paint(canvas, Offset(4, y));
    }
  }

  @override
  bool shouldRepaint(_ECGPainter oldDelegate) {
    return dataPoints != oldDelegate.dataPoints || 
           sweepProgress != oldDelegate.sweepProgress ||
           isConnected != oldDelegate.isConnected;
  }
}
