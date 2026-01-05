import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../service/zego_call_service.dart';

/// ═══════════════════════════════════════════════════════════════════
/// Example: Chat Detail Screen với Video/Voice Call Buttons
/// ═══════════════════════════════════════════════════════════════════

class ChatDetailScreenExample extends StatelessWidget {
  final String partnerId;
  final String partnerName;
  final String? partnerAvatar;

  const ChatDetailScreenExample({
    super.key,
    required this.partnerId,
    required this.partnerName,
    this.partnerAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: partnerAvatar != null
                  ? NetworkImage(partnerAvatar!)
                  : null,
              child: partnerAvatar == null
                  ? Text(partnerName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                partnerName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // ═══════════════════════════════════════════════════════
          // 📞 VOICE CALL BUTTON
          // ═══════════════════════════════════════════════════════
          IconButton(
            icon: const Icon(Icons.phone),
            tooltip: 'Voice Call',
            onPressed: () async {
              // Chỉ cần 1 dòng code!
              await ZegoCallService().startVoiceCall(
                context: context,
                targetUserId: partnerId,
                targetUserName: partnerName,
              );
            },
          ),

          // ═══════════════════════════════════════════════════════
          // 📹 VIDEO CALL BUTTON
          // ═══════════════════════════════════════════════════════
          IconButton(
            icon: const Icon(Icons.videocam),
            tooltip: 'Video Call',
            onPressed: () async {
              // Chỉ cần 1 dòng code!
              await ZegoCallService().startVideoCall(
                context: context,
                targetUserId: partnerId,
                targetUserName: partnerName,
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Message $index'),
                );
              },
            ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Send message
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
/// Example: Doctor List với Quick Call Button
/// ═══════════════════════════════════════════════════════════════════

class DoctorListExample extends StatelessWidget {
  const DoctorListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctors')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          final doctorId = 'doctor_$index';
          final doctorName = 'Dr. Smith $index';
          
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(doctorName),
            subtitle: const Text('Cardiologist'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick Voice Call
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () {
                    ZegoCallService().startVoiceCall(
                      context: context,
                      targetUserId: doctorId,
                      targetUserName: doctorName,
                    );
                  },
                ),
                
                // Quick Video Call
                IconButton(
                  icon: const Icon(Icons.videocam, color: Colors.blue),
                  onPressed: () {
                    ZegoCallService().startVideoCall(
                      context: context,
                      targetUserId: doctorId,
                      targetUserName: doctorName,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════
/// Example: Login Screen - Initialize ZegoCallService
/// ═══════════════════════════════════════════════════════════════════

class LoginScreenExample extends StatefulWidget {
  const LoginScreenExample({super.key});

  @override
  State<LoginScreenExample> createState() => _LoginScreenExampleState();
}

class _LoginScreenExampleState extends State<LoginScreenExample> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      // 1. Call login API
      // final response = await loginAPI(email, password);
      
      // 2. Mock data
      final userId = 'user_123';
      final userName = 'John Doe';
      final userAvatar = 'https://example.com/avatar.jpg';

      // 3. ⭐ QUAN TRỌNG: Initialize ZegoCallService sau khi login
      await ZegoCallService().initialize(
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
      );

      // 4. Navigate to home
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

/// ═══════════════════════════════════════════════════════════════════
/// Example: Profile/Settings Screen - Uninitialize when logout
/// ═══════════════════════════════════════════════════════════════════

class ProfileScreenExample extends StatelessWidget {
  const ProfileScreenExample({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // 1. ⭐ QUAN TRỌNG: Uninitialize ZegoCallService
      await ZegoCallService().uninitialize();

      // 2. Clear local data
      // await SharedPreferences.getInstance().then((prefs) => prefs.clear());

      // 3. Navigate to login
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('Edit Profile'),
          ),
          const ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}
