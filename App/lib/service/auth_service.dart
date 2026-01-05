import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../models/common/user_model.dart';
import '../service/socket_service.dart';

class AuthService {
  final ApiClient _apiClient;
  AuthService(this._apiClient);

  // Các key lưu trữ
  static const String keyToken = 'auth_token';
  static const String keyLoginTime = 'login_timestamp';
  static const String keyUserRole = 'user_role';
  static const String keyIsFirstLaunch = 'is_first_launch'; // Key quan trọng

  // 1. Đăng nhập & Lưu Session
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(body);

        // --- LƯU SESSION LOCAL ---
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(keyToken, authResponse.token);
        await prefs.setString(keyUserRole, authResponse.role.name);
        await prefs.setString('userId', authResponse.userId);
        await prefs.setString('userName', authResponse.userName);
        // Lưu thời điểm đăng nhập hiện tại
        await prefs.setInt(keyLoginTime, DateTime.now().millisecondsSinceEpoch);

        // Đảm bảo set isFirstLaunch = false khi đã login thành công (phòng hờ)
        await prefs.setBool(keyIsFirstLaunch, false);

        _apiClient.setToken(authResponse.token);
        print("✅ Login Success. Role: ${authResponse.role}");
        return authResponse;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Lỗi không xác định');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  // 2. Kiểm tra Session (Logic cốt lõi)
  Future<Map<String, dynamic>> checkSession() async {
    final prefs = await SharedPreferences.getInstance();

    // Check 1: Lần đầu mở app?
    // Nếu chưa có key này (null) => Là lần đầu.
    final isFirstLaunch = prefs.getBool(keyIsFirstLaunch) ?? true;

    if (isFirstLaunch) {
      return {'status': 'first_launch'};
    }

    // Check 2: Đã đăng nhập chưa?
    final token = prefs.getString(keyToken);
    final loginTime = prefs.getInt(keyLoginTime);
    final roleStr = prefs.getString(keyUserRole);

    if (token == null || loginTime == null) {
      // Đã từng mở app nhưng chưa đăng nhập hoặc đã logout
      return {'status': 'logged_out'};
    }

    // Check 3: Token có hết hạn 7 ngày không?
    final dateLogin = DateTime.fromMillisecondsSinceEpoch(loginTime);
    final dateNow = DateTime.now();
    final difference = dateNow.difference(dateLogin).inDays;

    if (difference >= 7) {
      // Hết hạn -> Xóa token local để logout
      await _clearLocalData();
      return {'status': 'expired'};
    }

    // Check 4: Token hợp lệ -> Set token để gọi API
    _apiClient.setToken(token);

    final role = roleStr == 'doctor' ? UserRole.doctor : UserRole.patient;
    return {
      'status': 'valid',
      'role': role
    };
  }

  // 3. Đánh dấu đã mở App lần đầu xong (Gọi khi Splash Animation kết thúc)
  Future<void> markAppLaunched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsFirstLaunch, false);
  }

  // 4. Logout
  Future<void> logout() async {
    print("👋 [AUTH SERVICE] Đang đăng xuất...");
    try {
      await _apiClient.post('/auth/logout', {});
    } catch (e) {
      print("   ⚠️ Lỗi gọi API logout: $e");
    }

    // Xóa dữ liệu local (Token, LoginTime)
    await _clearLocalData();

    // Ngắt Socket
    SocketService().disconnect();
  }

  // Hàm phụ trợ xóa data (LƯU Ý: KHÔNG XÓA keyIsFirstLaunch)
  Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyToken);
    await prefs.remove(keyLoginTime);
    await prefs.remove(keyUserRole);
    await prefs.remove('userId');
    await prefs.remove('userName');
    await _apiClient.removeToken();
  }

  // ... Các hàm API khác (register, forgotPassword...) giữ nguyên như cũ
  Future<void> register(String fullName, String email, String password) async {
    final response = await _apiClient.post('/auth/register', {'fullName': fullName, 'email': email, 'password': password});
    if (response.statusCode != 201) throw Exception(jsonDecode(response.body)['error'] ?? 'Đăng ký thất bại');
  }
  Future<void> forgotPassword(String email) async => await _apiClient.post('/auth/forgot-password', {'email': email});
  Future<void> verifyOtp(String email, String otp) async {
    final response = await _apiClient.post('/auth/verify-otp', {'email': email, 'otp': otp});
    if (response.statusCode != 200) throw Exception('OTP không hợp lệ');
  }
  Future<void> resetPassword(String email, String newPassword, String otp) async {
    final response = await _apiClient.post('/auth/reset-password', {'email': email, 'newPassword': newPassword, 'otp': otp});
    if (response.statusCode != 200) throw Exception('Lỗi đổi mật khẩu');
  }
  Future<Map<String, dynamic>> changePassword(String oldPass, String newPass) async {
    final response = await _apiClient.post('/auth/change-password', {'oldPassword': oldPass, 'newPassword': newPass});
    return jsonDecode(response.body);
  }
}