import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_config.dart'; // Import file config

class ApiClient {
  // ----------------------------------------------------------
  // 1. SINGLETON
  // ----------------------------------------------------------
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal();

  // ----------------------------------------------------------
  // 2. CẤU HÌNH & BIẾN (QUAN TRỌNG)
  // ----------------------------------------------------------

  // Cấu hình IP: Đổi 10.0.2.2 thành IP máy tính nếu chạy máy thật
  static const String _baseUrl = AppConfig.apiUrl;

  String? _token;
  final String _storageKey = 'auth_token';

  // ==========================================================
  // 👇 PHẦN QUAN TRỌNG: MỞ KHOÁ CHO CHAT_SERVICE DÙNG 👇
  // ==========================================================

  // 1. Cho phép ChatService lấy đường dẫn server
  String get baseUrl => _baseUrl;

  // 2. Cho phép ChatService lấy Token (Hàm này sửa lỗi getToken undefined)
  Future<String?> getToken() async {
    if (_token == null) {
      await _loadTokenFromStorage();
    }
    return _token;
  }

  // ==========================================================

  // Tự động load token từ ổ cứng
  Future<void> _loadTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_storageKey);
    if (_token != null) {
      print("♻️ [ApiClient] Đã load Token: $_token");
    }
  }

  // Gọi hàm này khi Login xong
  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(_storageKey, token);
      print("💾 [ApiClient] Đã lưu Token mới");
    } else {
      await prefs.remove(_storageKey);
      print("👋 [ApiClient] Đã xóa Token (Logout)");
    }
  }

  // Helper lấy header
  Future<Map<String, String>> _getHeaders() async {
    await _loadTokenFromStorage(); // Đảm bảo có token trước khi request
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // ----------------------------------------------------------
  // 3. CÁC HÀM GỌI API (GET, POST, PUT)
  // ----------------------------------------------------------
  Future<http.Response> get(String endpoint) async {
    final Uri url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    try {
      return await http.get(url, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout: Không thể kết nối server'),
      );
    } catch (e) {
      throw Exception('Lỗi GET: $e');
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final Uri url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    try {
      return await http.post(url, headers: headers, body: jsonEncode(body)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout: Không thể kết nối server'),
      );
    } catch (e) {
      throw Exception('Lỗi POST: $e');
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final Uri url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    try {
      return await http.put(url, headers: headers, body: jsonEncode(body)).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Timeout: Không thể kết nối server'),
      );
    } catch (e) {
      throw Exception('Lỗi PUT: $e');
    }
  }

  // --- [MỚI] Hàm DELETE (Sửa lỗi tại đây) ---
  // Thêm vào ApiClient nếu chưa có
  Future<http.Response> delete(String endpoint) async {
    final Uri url = Uri.parse('$_baseUrl$endpoint');
    Map<String, String> headers = {'Content-Type': 'application/json; charset=UTF-8'};
    if (_token != null) headers['Authorization'] = 'Bearer $_token';

    try {
      return await http.delete(url, headers: headers);
    } catch (e) {
      throw Exception('Lỗi DELETE: $e');
    }
  }

  Future<void> removeToken() async {
    _token = null; // Xóa biến tạm
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey); // Xóa đúng key 'auth_token'
    print("👋 [ApiClient] Đã xóa Token (Logout)");
  }
}