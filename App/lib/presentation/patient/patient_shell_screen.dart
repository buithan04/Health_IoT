import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_iot/service/socket_service.dart';

import 'package:health_iot/service/user_service.dart';
import 'package:health_iot/core/api/api_client.dart';
import 'package:health_iot/core/constants/app_config.dart';
import 'package:health_iot/core/responsive/responsive.dart';

class PatientShellScreen extends StatefulWidget {
  final Widget child;
  const PatientShellScreen({super.key, required this.child});

  @override
  State<PatientShellScreen> createState() => _PatientShellScreenState();
}

class _PatientShellScreenState extends State<PatientShellScreen> {
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _initSocket();
    _initCallService();
  }
  // [THÊM HÀM NÀY]
  Future<void> _initCallService() async {
    try {
      final userService = UserService(ApiClient());
      final profile = await userService.getUserProfile();

      if (profile != null) {
        // WebRTC không cần init tại đây, init trong chat_detail_screen
        print("✅ Shell loaded for Patient");
      }
    } catch (e) {
      print("❌ Lỗi Init Zego tại Shell: $e");
    }
  }

  void _initSocket() async {
    // Chỉ kết nối Socket để sẵn sàng cho các màn hình con (như Chat, Notif) sử dụng
    await _socketService.connect();
  }

  // Logic BottomBar giữ nguyên
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/statistics')) return 1;
    if (location.startsWith('/appointments')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/dashboard'); break;
      case 1: context.go('/statistics'); break;
      case 2: context.go('/appointments'); break;
      case 3: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRail = Responsive.useRail(context);
    final selectedIndex = _calculateSelectedIndex(context);

    final destinations = const [
      NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
      NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Thống kê'),
      NavigationDestination(icon: Icon(Icons.calendar_today_outlined), label: 'Lịch hẹn'),
      NavigationDestination(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (isRail)
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) => _onItemTapped(index, context),
                labelType: NavigationRailLabelType.selected,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home, color: Colors.teal),
                    label: Text('Trang chủ'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart, color: Colors.teal),
                    label: Text('Thống kê'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_today_outlined),
                    selectedIcon: Icon(Icons.calendar_today, color: Colors.teal),
                    label: Text('Lịch hẹn'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person, color: Colors.teal),
                    label: Text('Hồ sơ'),
                  ),
                ],
              ),
            Expanded(child: widget.child),
          ],
        ),
      ),
      bottomNavigationBar: isRail
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _onItemTapped(index, context),
              destinations: destinations,
            ),
    );
  }
}