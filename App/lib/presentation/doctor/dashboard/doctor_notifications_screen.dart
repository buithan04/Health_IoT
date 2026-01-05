import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_iot/service/notification_service.dart';
import 'package:health_iot/models/common/notification_model.dart';
import 'package:health_iot/service/socket_service.dart';

class DoctorNotificationsScreen extends StatefulWidget {
  const DoctorNotificationsScreen({super.key});

  @override
  State<DoctorNotificationsScreen> createState() => _DoctorNotificationsScreenState();
}

class _DoctorNotificationsScreenState extends State<DoctorNotificationsScreen> {
  // Dùng chung Service với bệnh nhân (API /notifications)
  final NotificationService _notifService = NotificationService();
  final SocketService _socketService = SocketService();

  StreamSubscription? _subscription;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _socketService.connect();
    _loadNotifications();
    _listenRealtime();
  }

  Future<void> _markAllAsRead() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    // 1. Cập nhật UI ngay lập tức
    setState(() {
      for (final n in unread) {
        n.isRead = true;
      }
    });

    // 2. Gọi API tối ưu
    await _notifService.markAllAsRead();
  }

  void _listenRealtime() {
    _subscription = _socketService.notificationStream.listen((data) {
      if (mounted) {
        try {
          final newNotif = NotificationModel.fromJson(data);
          setState(() {
            final exists = _notifications.any((item) => item.id == newNotif.id);
            if (!exists) {
              _notifications.insert(0, newNotif);
            }
          });
        } catch (e) {
          print("Socket parse error: $e");
        }
      }
    });
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await _notifService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- [MỚI] HÀM XÓA THÔNG BÁO ---
  Future<void> _deleteItem(int id, int index) async {
    // 1. Lưu lại item để khôi phục nếu lỗi (Undo)
    final removedItem = _notifications[index];

    // 2. Xóa trên giao diện ngay lập tức cho mượt
    setState(() => _notifications.removeAt(index));

    // 3. Gọi API xóa
    final success = await _notifService.deleteNotification(id);

    // 4. Nếu API lỗi -> Khôi phục lại
    if (!success && mounted) {
      setState(() => _notifications.insert(index, removedItem));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể xóa thông báo, vui lòng thử lại.')),
      );
    }
  }

  Future<void> _onTapNotification(NotificationModel notif) async {
    if (!notif.isRead) {
      setState(() => notif.isRead = true);
      _notifService.markAsRead(notif.id);
    }
    if (notif.relatedId.isEmpty) return;

    switch (notif.type) {
      case 'NEW_REQUEST':
      case 'APPOINTMENT_CANCELLED':
      case 'APPOINTMENT_CONFIRMED':
        context.push('/doctor/appointment-details/${notif.relatedId}');
        break;
      case 'NEW_MESSAGE':
      case 'MISSED_CALL':
        context.push('/doctor/chat/details/${notif.relatedId}');
        break;
      case 'NEW_REVIEW':
        context.push('/doctor/profile/reviews');
        break;
      default: break;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10),
          child: AppBar(
            title: Text('Thông báo', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18)),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            actions: [
              if (_notifications.isNotEmpty)
                IconButton(
                  tooltip: 'Đánh dấu đã đọc hết',
                  icon: const Icon(Icons.done_all_rounded, color: Colors.black87, size: 22),
                  onPressed: _markAllAsRead,
                ),
            ],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
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
            Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("Không có thông báo nào", style: GoogleFonts.inter(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final item = _notifications[index];

            // --- [FIX] THÊM DISMISSIBLE ĐỂ VUỐT XÓA ---
            return Dismissible(
              key: Key(item.id.toString()), // Key duy nhất để Flutter biết xóa cái nào
              direction: DismissDirection.endToStart, // Chỉ cho phép vuốt từ phải sang trái
              background: Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
              ),
              onDismissed: (direction) => _deleteItem(item.id, index),
              child: _NotificationItem(
                notification: item,
                onTap: () => _onTapNotification(item),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationItem({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    Color bgColor;

    switch (notification.type) {
      case 'NEW_REQUEST':
        icon = Icons.calendar_today_rounded; color = Colors.orange; bgColor = Colors.orange.shade50; break;
      case 'APPOINTMENT_CANCELLED':
        icon = Icons.event_busy_rounded; color = Colors.red; bgColor = Colors.red.shade50; break;
      case 'APPOINTMENT_CONFIRMED':
        icon = Icons.check_circle_rounded; color = Colors.teal; bgColor = Colors.teal.shade50; break;
      case 'NEW_MESSAGE':
        icon = Icons.chat_bubble_rounded; color = Colors.blue; bgColor = Colors.blue.shade50; break;
      case 'NEW_REVIEW':
        icon = Icons.star_rounded; color = Colors.amber; bgColor = Colors.amber.shade50; break;
      default:
        icon = Icons.notifications_rounded; color = Colors.grey.shade700; bgColor = Colors.grey.shade100;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue.shade50.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        border: notification.isRead ? null : Border.all(color: Colors.blue.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 22),
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
                              notification.title,
                              style: GoogleFonts.inter(
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                                fontSize: 15,
                                color: const Color(0xFF1E293B),
                              ),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              width: 8, height: 8,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13, height: 1.4),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.timeDisplay,
                        style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}