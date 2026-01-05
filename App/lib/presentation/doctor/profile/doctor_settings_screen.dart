import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorSettingsScreen extends StatefulWidget {
  const DoctorSettingsScreen({super.key});

  @override
  State<DoctorSettingsScreen> createState() => _DoctorSettingsScreenState();
}

class _DoctorSettingsScreenState extends State<DoctorSettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // Màu nền xám nhẹ hiện đại
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Cài đặt & Tài khoản',
          style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Chung'),
            _buildSettingsGroup([
              _buildSwitchItem(
                icon: Icons.notifications_outlined,
                title: 'Thông báo',
                value: _notificationsEnabled,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
              _buildDivider(),
              _buildNavItem(
                icon: Icons.language_outlined,
                title: 'Ngôn ngữ',
                value: 'Tiếng Việt',
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionTitle('Bảo mật'),
            _buildSettingsGroup([
              _buildNavItem(
                icon: Icons.lock_outline,
                title: 'Đổi mật khẩu',
                onTap: () {
                  // [CẬP NHẬT] Chuyển sang trang riêng thay vì Dialog
                  // Đảm bảo bạn đã khai báo route này trong GoRouter
                  context.push('/doctor/profile/settings/change-password');
                },
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionTitle('Hỗ trợ'),
            _buildSettingsGroup([
              _buildNavItem(
                icon: Icons.help_outline,
                title: 'Trợ giúp & FAQ',
                onTap: () {},
              ),
              _buildDivider(),
              _buildNavItem(
                icon: Icons.info_outline,
                title: 'Về ứng dụng',
                value: 'v1.0.0',
                onTap: () {},
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.teal.shade700, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ),
            if (value != null)
              Text(
                value,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
              ),
            if (value != null) const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.orange.shade700, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 60);
  }
}