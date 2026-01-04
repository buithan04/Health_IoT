# Flutter MQTT Integration - Quick Guide

## 📱 Đã tạo sẵn cho bạn

### Files mới:
1. **`lib/service/mqtt_service_new.dart`** - MQTT service kết nối HiveMQ
2. **`lib/presentation/patient/health_monitor_screen.dart`** - UI hiển thị dữ liệu real-time

## 🚀 Cách sử dụng

### 1. Thay thế MQTT service cũ

**Option A: Rename file mới**
```bash
cd lib/service
mv mqtt_service.dart mqtt_service.old.dart
mv mqtt_service_new.dart mqtt_service.dart
```

**Option B: Copy nội dung**
- Copy nội dung từ `mqtt_service_new.dart`
- Paste vào `mqtt_service.dart`

### 2. Thêm màn hình vào routes

Mở file routing của bạn và thêm:

```dart
import 'package:app_iot/presentation/patient/health_monitor_screen.dart';

// Trong routes:
'/health-monitor': (context) => const HealthMonitorScreen(),
```

Hoặc với GoRouter:

```dart
GoRoute(
  path: '/health-monitor',
  builder: (context, state) => const HealthMonitorScreen(),
),
```

### 3. Thêm navigation button

Thêm button ở màn hình chính:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, '/health-monitor');
    // hoặc: context.push('/health-monitor');
  },
  child: const Text('Theo dõi sức khỏe Real-time'),
)
```

### 4. Chạy app

```bash
flutter pub get
flutter run
```

## 📊 Tính năng

### ✅ Đã implement:

1. **Kết nối HiveMQ Cloud**
   - Tự động kết nối khi vào màn hình
   - Auto-reconnect khi mất kết nối
   - Hiển thị trạng thái kết nối

2. **Hiển thị Medical Data**
   - Nhịp tim (HR)
   - SpO2
   - Nhiệt độ
   - Thời gian cập nhật

3. **Hiển thị ECG**
   - Biểu đồ real-time
   - Packet ID tracking
   - Số điểm dữ liệu

4. **UI/UX**
   - Live indicator
   - Pull to refresh
   - Connection status
   - Empty states

## 💡 Cách hoạt động

### Khi có dữ liệu mới:
```
ESP32 → HiveMQ → App
              ↓
        Update UI ngay lập tức
```

### Khi không có dữ liệu mới:
```
App → Hiển thị dữ liệu cũ (currentHealthData/currentECGData)
```

### Đồng bộ với Backend:
```
HiveMQ (packet_id: 54065)
    ↓
    ├─→ Backend: Lưu DB, chẩn đoán, cảnh báo
    └─→ App: Hiển thị UI real-time

Cùng packet_id = Cùng 1 bộ dữ liệu!
```

## 🎨 Customize

### Thay đổi màu sắc:

```dart
// Trong _buildMetricTile
color: Colors.red,  // Đổi thành màu bạn thích
```

### Thêm metrics khác:

```dart
// Trong _buildMedicalDataCard
_buildMetricTile(
  icon: Icons.new_icon,
  iconColor: Colors.purple,
  label: 'Metric mới',
  value: '${data.newMetric}',
),
```

### Thay đổi ECG chart style:

```dart
// Trong LineChartBarData
color: Colors.blue,  // Đổi màu đường
barWidth: 2.0,       // Đổi độ dày
isCurved: true,      // Làm mượt đường
```

## 🔔 Socket.IO Alerts (Optional)

Nếu muốn nhận cảnh báo từ backend, thêm vào `socket_service.dart`:

```dart
socket.on('health_alert', (data) {
  // Hiển thị notification
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('⚠️ ${data['type']}'),
      content: Text(data['message']),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
});
```

## 📦 Dependencies đã có sẵn

```yaml
dependencies:
  mqtt_client: ^10.3.1    ✅
  fl_chart: ^1.1.1        ✅
  socket_io_client: ^3.1.2 ✅
```

## 🐛 Troubleshooting

### Không kết nối được MQTT?

```dart
// Check logs:
flutter run --verbose

// Bạn sẽ thấy:
🔌 Connecting to HiveMQ Cloud...
✅ MQTT Connected to HiveMQ
✅ Subscribed to: device/medical_data
```

### Không nhận được dữ liệu?

1. Check ESP32 đang publish không
2. Test bằng MQTTX client
3. Check topics đúng không

### UI không update?

```dart
// Ensure setState được gọi:
_mqttService.healthStream.listen((metric) {
  setState(() {  // ← Phải có!
    _currentHealth = metric;
  });
});
```

## ✨ Next Steps

1. Thêm history charts (7 ngày, 30 ngày)
2. Export data to PDF
3. Share với bác sĩ
4. Push notifications
5. Offline mode với local storage

---

**Hoàn thành!** 🎉

Test ngay:
```bash
flutter run
```
