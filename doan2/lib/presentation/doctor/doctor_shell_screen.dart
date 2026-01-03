import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_iot/service/socket_service.dart';

import 'package:app_iot/service/user_service.dart';
import 'package:app_iot/core/api/api_client.dart';
import 'package:app_iot/core/constants/app_config.dart';
import 'package:app_iot/core/responsive/responsive.dart';

class DoctorShellScreen extends StatefulWidget {
  final Widget child;
  const DoctorShellScreen({super.key, required this.child});

  @override
  State<DoctorShellScreen> createState() => _DoctorShellScreenState();
}

class _DoctorShellScreenState extends State<DoctorShellScreen> {
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
        print("✅ Shell loaded for Doctor");
      }
    } catch (e) {
      print("❌ Lỗi Init Zego tại Shell: $e");
    }
  }

  void _initSocket() async {
    // Chỉ kết nối Socket để đó, không lắng nghe sự kiện hiện thông báo nữa
    await _socketService.connect();
  }

  @override
  void dispose() {
    // Không cần hủy stream vì không đăng ký lắng nghe ở đây nữa
    super.dispose();
  }

  // --- Logic BottomBar giữ nguyên ---
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/doctor/dashboard')) return 0;
    if (location.startsWith('/doctor/schedule')) return 1;
    if (location.startsWith('/doctor/analytics')) return 2;
    if (location.startsWith('/doctor/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/doctor/dashboard'); break;
      case 1: context.go('/doctor/schedule'); break;
      case 2: context.go('/doctor/analytics'); break;
      case 3: context.go('/doctor/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRail = Responsive.useRail(context);
    final selectedIndex = _calculateSelectedIndex(context);

    const barDestinations = [
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard, color: Colors.teal),
        label: 'Tổng quan',
      ),
      NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month, color: Colors.teal),
        label: 'Lịch khám',
      ),
      NavigationDestination(
        icon: Icon(Icons.analytics_outlined),
        selectedIcon: Icon(Icons.analytics, color: Colors.teal),
        label: 'Thống kê',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person, color: Colors.teal),
        label: 'Hồ sơ',
      ),
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
                leading: const SizedBox(height: 8),
                indicatorColor: Colors.teal.shade50,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard, color: Colors.teal),
                    label: Text('Tổng quan'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    selectedIcon: Icon(Icons.calendar_month, color: Colors.teal),
                    label: Text('Lịch khám'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.analytics_outlined),
                    selectedIcon: Icon(Icons.analytics, color: Colors.teal),
                    label: Text('Thống kê'),
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
              backgroundColor: Colors.white,
              elevation: 10,
              indicatorColor: Colors.teal.shade100,
              destinations: barDestinations,
            ),
    );
  }
}