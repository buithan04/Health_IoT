import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_iot/service/notification_service.dart';
import 'package:app_iot/models/common/notification_model.dart';
import 'package:app_iot/service/socket_service.dart'; // Import Socket

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  final SocketService _socketService = SocketService();

  StreamSubscription? _subscription;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _socketService.connect();
    _loadData();
    _listenRealtime(); // Kích hoạt lắng nghe Realtime
  }

  Future<void> _markAllAsRead() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    // 1. Cập nhật UI ngay lập tức (Optimistic UI)
    setState(() {
      for (final n in unread) {
        n.isRead = true;
      }
    });

    // 2. Gọi API 1 lần duy nhất
    await _service.markAllAsRead();
  }

  void _listenRealtime() {
    // --- [FIX] LẮNG NGHE STREAM CHO BỆNH NHÂN ---
    _subscription = _socketService.notificationStream.listen((data) {
      if (mounted) {
        try {
          final newNotif = NotificationModel.fromJson(data);
          setState(() {
            // Chống trùng lặp
            final exists = _notifications.any((item) => item.id == newNotif.id);
            if (!exists) {
              _notifications.insert(0, newNotif); // Hiện ngay lập tức
            }
          });
        } catch (e) {
          print("Socket patient error: $e");
        }
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _service.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(int id, int index) async {
    final removedItem = _notifications[index];
    setState(() => _notifications.removeAt(index));
    final success = await _service.deleteNotification(id);
    if (!success && mounted) {
      setState(() => _notifications.insert(index, removedItem));
    }
  }

  Future<void> _deleteAllNotifications() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.clear_all_rounded, color: Colors.orange[700], size: 28),
            const SizedBox(width: 12),
            const Text('Xóa hiển thị'),
          ],
        ),
        content: Text(
          'Xóa TẤT CẢ ${_notifications.length} thông báo khỏi danh sách hiển thị?\n\n(Thông báo vẫn được lưu trong hệ thống)',
          style: GoogleFonts.inter(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy', style: GoogleFonts.inter(color: Colors.grey[700])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xóa hiển thị'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Clear local display only (no API call)
    setState(() {
      _notifications.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã xóa tất cả khỏi danh sách hiển thị'),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Tải lại',
          textColor: Colors.white,
          onPressed: _loadData,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Hủy lắng nghe
    super.dispose();
  }

  // --- [FIXED] XỬ LÝ ĐIỀU HƯỚNG BỆNH NHÂN THEO ĐÚNG APPROUTER ---
  void _onNotificationTap(NotificationModel item) async {
    if (!item.isRead) {
      _service.markAsRead(item.id);
      setState(() => item.isRead = true);
    }

    if (item.relatedId.isEmpty) return;

    switch (item.type) {
      case 'APPOINTMENT_CONFIRMED':
      case 'APPOINTMENT_CANCELLED':
      // Router: /appointments/details/:appointmentId
        context.push('/appointments/details/${item.relatedId}');
        break;

      case 'APPOINTMENT_COMPLETED':
      // Router: /write-review (extra: Appointment object)
      // Lưu ý: Trường hợp này cần fetch object Appointment trước,
      // hoặc sửa Router để nhận ID. Tạm thời dẫn về chi tiết để xem.
        context.push('/appointments/details/${item.relatedId}');
        break;

      case 'NEW_PRESCRIPTION':
      // Router: /prescriptions/details/:prescriptionId
        context.push('/prescriptions/details/${item.relatedId}');
        break;

      case 'HEALTH_ALERT':
      // Router: /profile/health-record
        context.push('/profile/health-record');
        break;

      case 'NEW_MESSAGE':
      // Router: /chat/details/:chatId
      // Lưu ý: Router chat cần query params (name, avatar),
      // nhưng từ notif chỉ có ID. ChatDetailScreen cần xử lý trường hợp thiếu name.
        context.push('/chat/details/${item.relatedId}');
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10),
          child: AppBar(
            title: Text('Thông báo', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87)),
            backgroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            centerTitle: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            actions: [
              if (_notifications.isNotEmpty) ...[
                IconButton(
                  tooltip: 'Đánh dấu đã đọc hết',
                  icon: const Icon(Icons.done_all_rounded, color: Colors.black87),
                  onPressed: _markAllAsRead,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.black87),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  offset: const Offset(0, 50),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete_all',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all_rounded, color: Colors.orange[600], size: 22),
                          const SizedBox(width: 12),
                          Text(
                            'Xóa hiển thị',
                            style: GoogleFonts.inter(
                              color: Colors.orange[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete_all') {
                      _deleteAllNotifications();
                    }
                  },
                ),
              ],
            ],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("Chưa có thông báo nào", style: GoogleFonts.inter(color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final item = _notifications[index];
            return Dismissible(
              key: Key(item.id.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 32),
              ),
              onDismissed: (direction) => _deleteItem(item.id, index),
              child: _buildNotificationItem(item),
            );
          },
        ),
      ),
    );
  }

  // --- [UPDATED] GIAO DIỆN ITEM CHO BỆNH NHÂN ---
  Widget _buildNotificationItem(NotificationModel item) {
    IconData icon;
    Color color;

    switch (item.type) {
      case 'APPOINTMENT_CONFIRMED':
        icon = Icons.event_available_rounded; color = Colors.teal; break;
      case 'APPOINTMENT_CANCELLED':
        icon = Icons.event_busy_rounded; color = Colors.red; break;
      case 'APPOINTMENT_COMPLETED':
        icon = Icons.rate_review_rounded; color = Colors.purple; break;

      case 'NEW_PRESCRIPTION': // Đơn thuốc mới
        icon = Icons.medication_rounded; color = Colors.green; break;

      case 'HEALTH_ALERT': // Cảnh báo sức khỏe
        icon = Icons.monitor_heart_rounded; color = Colors.redAccent; break;

      case 'NEW_MESSAGE':
        icon = Icons.chat_bubble_rounded; color = Colors.blue; break;

      default:
        icon = Icons.notifications_rounded; color = Colors.grey; break;
    }

    return Card(
      // 1. Sửa Elevation: Giữ 0 cho đã đọc (phẳng), 2 cho chưa đọc (nổi) để phân biệt độ sâu
      elevation: item.isRead ? 0.5 : 2,

      // 2. [FIX QUAN TRỌNG]: Luôn để màu trắng, không dùng Colors.transparent
      color: Colors.white,
      surfaceTintColor: Colors.white, // Thêm dòng này để tránh bị ám màu trên Android mới

      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // 3. Viền: Có thể bỏ border khi đã đọc để nhìn thoáng hơn, hoặc giữ nguyên
        side: item.isRead ? BorderSide.none : BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _onNotificationTap(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                // Làm nhạt icon đi một chút nếu đã đọc (tùy chọn), ở đây tôi giữ nguyên
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            // Chữ đã đọc thì font thường, chưa đọc thì in đậm
                            style: GoogleFonts.inter(
                              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 15,
                              color: item.isRead ? Colors.black87 : Colors.black, // Màu chữ nhẹ hơn chút xíu nếu cần
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Logic chấm đỏ vẫn giữ nguyên
                        if (!item.isRead)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            width: 8, height: 8,
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.timeDisplay,
                      style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}