import 'package:flutter/material.dart';
import 'package:health_iot/core/utils/permission_helper.dart';
import 'package:permission_handler/permission_handler.dart';

/// Camera Preview Screen - Hiển thị trước khi bắt đầu cuộc gọi
/// Giống Messenger: Người dùng thấy mình trước khi gọi
class CameraPreviewScreen extends StatefulWidget {
  final String remoteUserName;
  final String? remoteUserAvatar;
  final bool isVideoCall;
  final VoidCallback onStartCall;
  final VoidCallback onCancel;

  const CameraPreviewScreen({
    super.key,
    required this.remoteUserName,
    this.remoteUserAvatar,
    required this.isVideoCall,
    required this.onStartCall,
    required this.onCancel,
  });

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  bool _permissionsGranted = false;
  bool _isCheckingPermissions = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _isCheckingPermissions = true);
    
    final granted = await PermissionHelper.requestCallPermissions();
    
    if (mounted) {
      setState(() {
        _permissionsGranted = granted;
        _isCheckingPermissions = false;
      });
    }

    if (!granted) {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cần quyền truy cập'),
        content: const Text(
          'Ứng dụng cần quyền truy cập Camera và Microphone để thực hiện cuộc gọi. '
          'Vui lòng cấp quyền trong Cài đặt.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Close preview screen too
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
              _checkPermissions(); // Re-check after opening settings
            },
            child: const Text('Mở Cài đặt'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onCancel();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: _isCheckingPermissions
              ? _buildLoadingView()
              : _permissionsGranted
                  ? _buildPreviewView()
                  : _buildPermissionDeniedView(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Đang kiểm tra quyền truy cập...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 80,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 24),
            const Text(
              'Không có quyền truy cập',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ứng dụng cần quyền Camera và Microphone để thực hiện cuộc gọi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await openAppSettings();
                _checkPermissions();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Mở Cài đặt'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewView() {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;
    
    // Responsive sizing
    final iconSize = isDesktop ? 100.0 : 80.0;
    final avatarRadius = isDesktop ? 25.0 : 20.0;
    final avatarIconSize = isDesktop ? 25.0 : 20.0;
    final titleFontSize = isDesktop ? 22.0 : 18.0;
    final messageFontSize = isDesktop ? 18.0 : 16.0;
    final indicatorFontSize = isDesktop ? 18.0 : 16.0;
    final buttonFontSize = isDesktop ? 20.0 : 18.0;
    final buttonIconSize = isDesktop ? 28.0 : 24.0;
    final topPadding = isDesktop ? 20.0 : 16.0;
    final containerMargin = isDesktop ? 24.0 : 16.0;
    final bottomPadding = isDesktop ? 60.0 : 40.0;
    
    return Column(
      children: [
        // Top bar
        Padding(
          padding: EdgeInsets.all(topPadding),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onCancel,
                icon: Icon(Icons.close, color: Colors.white, size: isDesktop ? 32 : 28),
              ),
              const Spacer(),
              Text(
                'Gọi đến ${widget.remoteUserName}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              SizedBox(width: isDesktop ? 56 : 48), // Balance the close button
            ],
          ),
        ),

        // Preview area (fake camera preview - ZegoCloud will handle real one)
        Expanded(
          child: Container(
            margin: EdgeInsets.all(containerMargin),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
            ),
            child: Stack(
              children: [
                // Camera icon as placeholder
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.isVideoCall 
                            ? Icons.videocam 
                            : Icons.mic,
                        size: iconSize,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      SizedBox(height: isDesktop ? 20 : 16),
                      Text(
                        widget.isVideoCall
                            ? 'Camera sẽ bật khi cuộc gọi bắt đầu'
                            : 'Microphone sẽ bật khi cuộc gọi bắt đầu',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: messageFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Remote user avatar overlay
                Positioned(
                  bottom: isDesktop ? 20 : 16,
                  left: isDesktop ? 20 : 16,
                  child: Container(
                    padding: EdgeInsets.all(isDesktop ? 16 : 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: avatarRadius,
                          backgroundImage: widget.remoteUserAvatar != null &&
                                  widget.remoteUserAvatar!.isNotEmpty
                              ? NetworkImage(widget.remoteUserAvatar!)
                              : null,
                          child: widget.remoteUserAvatar == null ||
                                  widget.remoteUserAvatar!.isEmpty
                              ? Icon(Icons.person, size: avatarIconSize)
                              : null,
                        ),
                        SizedBox(width: isDesktop ? 16 : 12),
                        Text(
                          widget.remoteUserName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: messageFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Call type indicator
        Padding(
          padding: EdgeInsets.symmetric(vertical: isDesktop ? 20 : 16),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 28 : 20,
              vertical: isDesktop ? 16 : 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isVideoCall ? Icons.videocam : Icons.phone,
                  color: Colors.white,
                  size: isDesktop ? 24 : 20,
                ),
                SizedBox(width: isDesktop ? 12 : 8),
                Text(
                  widget.isVideoCall ? 'Cuộc gọi video' : 'Cuộc gọi thoại',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: indicatorFontSize,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Start Call Button
        Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: ElevatedButton(
            onPressed: widget.onStartCall,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A7EA4),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 60 : 48,
                vertical: isDesktop ? 20 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 36 : 30),
              ),
              elevation: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isVideoCall ? Icons.videocam : Icons.phone,
                  size: buttonIconSize,
                ),
                SizedBox(width: isDesktop ? 16 : 12),
                Text(
                  'Bắt đầu gọi',
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
