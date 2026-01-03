// lib/service/mqtt_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:app_iot/models/patient/health_model.dart';
import 'package:app_iot/core/api/api_client.dart';

/// MQTT Service - Connect directly to HiveMQ Cloud
/// Strategy: Real-time MQTT data with API fallback
class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  // --- MQTT Client ---
  MqttServerClient? _client;
  bool isConnected = false;

  // --- Configuration (HiveMQ Cloud) ---
  // TODO: Replace with your actual HiveMQ credentials
  final String _broker = 'YOUR_HIVEMQ_HOST.hivemq.cloud'; // e.g., 'abc123.s1.eu.hivemq.cloud'
  final int _port = 8883; // TLS port
  final String _username = 'YOUR_HIVEMQ_USERNAME';
  final String _password = 'YOUR_HIVEMQ_PASSWORD';
  final String _topic = 'health/sensors/#';

  // --- Stream Controller ---
  final StreamController<HealthMetric> _healthStreamController = 
      StreamController<HealthMetric>.broadcast();
  Stream<HealthMetric> get healthStream => _healthStreamController.stream;

  // --- Fallback Timer ---
  Timer? _fallbackTimer;
  DateTime? _lastMqttMessage;
  final ApiClient _apiClient = ApiClient();

  /// Connect to HiveMQ Cloud
  Future<void> connect() async {
    if (isConnected) return;

    // Check if MQTT credentials are configured
    if (_broker == 'YOUR_HIVEMQ_HOST.hivemq.cloud' || 
        _username == 'YOUR_HIVEMQ_USERNAME' ||
        _password == 'YOUR_HIVEMQ_PASSWORD') {
      print('⚠️ MQTT not configured (credentials missing). Skipping MQTT connection.');
      print('ℹ️ Health data will be fetched from API instead.');
      return;
    }

    try {
      print('🔌 Connecting to HiveMQ Cloud...');

      // Create client with unique ID
      final clientId = 'flutter_patient_${DateTime.now().millisecondsSinceEpoch}';
      _client = MqttServerClient.withPort(_broker, clientId, _port);

      // Configure
      _client!.logging(on: false);
      _client!.keepAlivePeriod = 60;
      _client!.autoReconnect = true;
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onSubscribed = _onSubscribed;
      _client!.pongCallback = _pong;

      // Setup TLS for secure connection
      _client!.secure = true;
      _client!.securityContext = SecurityContext.defaultContext;

      // Connect message
      final connMessage = MqttConnectMessage()
          .authenticateAs(_username, _password)
          .withClientIdentifier(clientId)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      _client!.connectionMessage = connMessage;

      // Connect
      await _client!.connect();

      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        print('✅ MQTT Connected to HiveMQ');
        isConnected = true;

        // Subscribe to health sensors topic
        _subscribe();

        // Listen for messages
        _client!.updates!.listen(_onMessage);

        // Start fallback timer (check every 10 seconds)
        _startFallbackTimer();
      } else {
        print('❌ MQTT Connection failed: ${_client!.connectionStatus}');
        _connectFailed();
      }
    } catch (e) {
      print('❌ MQTT Connect error: $e');
      _connectFailed();
    }
  }

  /// Subscribe to health sensor topics
  void _subscribe() {
    if (_client == null || !isConnected) return;

    print('📡 Subscribing to: $_topic');
    _client!.subscribe(_topic, MqttQos.atLeastOnce);
  }

  /// Handle incoming MQTT messages
  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final message in messages) {
      final topic = message.topic;
      final payload = MqttPublishPayload.bytesToStringAsString(
        (message.payload as MqttPublishMessage).payload.message,
      );

      print('📩 MQTT message on $topic: $payload');

      try {
        // Parse JSON
        final data = jsonDecode(payload) as Map<String, dynamic>;

        // Convert to HealthMetric
        final metric = HealthMetric(
          heartRate: (data['heart_rate'] ?? data['heartRate'] ?? 0).toString(),
          spo2: (data['spo2'] ?? data['oxygen'] ?? 0).toString(),
          temperature: (data['temperature'] ?? data['temp'] ?? 0.0).toString(),
          bloodPressure: '${data['bp_systolic'] ?? data['systolic'] ?? 0}/${data['bp_diastolic'] ?? data['diastolic'] ?? 0}',
          timestamp: DateTime.now(),
        );

        // Emit to stream
        _healthStreamController.add(metric);
        _lastMqttMessage = DateTime.now();

        print('✅ MQTT data emitted: HR=${metric.heartRate}, SpO2=${metric.spo2}');
      } catch (e) {
        print('❌ Error parsing MQTT message: $e');
      }
    }
  }

  /// Start fallback timer - fetch from API if no MQTT data for 10+ seconds
  void _startFallbackTimer() {
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      // If no MQTT message in last 10 seconds, fetch from API
      if (_lastMqttMessage == null || 
          DateTime.now().difference(_lastMqttMessage!).inSeconds > 10) {
        print('⏰ No MQTT data for 10s, fetching from API...');
        await _fetchLatestFromApi();
      }
    });
  }

  /// Fallback: Fetch latest data from API
  Future<void> _fetchLatestFromApi() async {
    try {
      final response = await _apiClient.get('/mqtt/latest');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'] as Map<String, dynamic>;

          final metric = HealthMetric(
            heartRate: (data['heart_rate'] ?? 0).toString(),
            spo2: (data['spo2'] ?? 0).toString(),
            temperature: (data['temperature'] ?? 0.0).toString(),
            bloodPressure: '${data['blood_pressure_systolic'] ?? 0}/${data['blood_pressure_diastolic'] ?? 0}',
            timestamp: DateTime.parse(data['received_at'] ?? DateTime.now().toIso8601String()),
          );

          _healthStreamController.add(metric);
          print('✅ API fallback data loaded: HR=${metric.heartRate}');
        }
      } else if (response.statusCode == 404) {
        // No health data available yet - this is normal for new users
        print('ℹ️ No health data available yet');
      } else {
        print('⚠️ API fallback failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API fallback error: $e');
    }
  }

  // --- Connection Callbacks ---
  void _onConnected() {
    print('✅ MQTT Connected callback');
    isConnected = true;
  }

  void _onDisconnected() {
    print('⚠️ MQTT Disconnected');
    isConnected = false;
  }

  void _onSubscribed(String topic) {
    print('✅ Subscribed to: $topic');
  }

  void _pong() {
    // Keepalive pong received
  }

  void _connectFailed() {
    isConnected = false;
    // Still start fallback to use API
    _startFallbackTimer();
  }

  /// Disconnect
  void disconnect() {
    _fallbackTimer?.cancel();
    _client?.disconnect();
    isConnected = false;
    print('❌ MQTT Disconnected');
  }

  /// Dispose
  void dispose() {
    disconnect();
    _healthStreamController.close();
  }
}