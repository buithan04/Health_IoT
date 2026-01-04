# 🎯 HỆ THỐNG SENSOR VALIDATION VÀ NOTIFICATION

## 📌 Tóm Tắt

Đã triển khai **hệ thống validation và cảnh báo toàn diện** để đảm bảo:
✅ **Chỉ chẩn đoán khi dữ liệu thực sự đúng và đủ**  
✅ **Người dùng luôn được thông báo về vấn đề sensor**  
✅ **Lưu trữ lịch sử để phân tích và troubleshoot**

---

## 🚀 Các Thành Phần Đã Triển Khai

### 1️⃣ **Database Schema**
- **Bảng mới**: `sensor_warnings` (31 tables total)
- **Migration file**: `database/migrations/002_add_sensor_warnings_table.sql`
- **Indexes**: GIN index cho JSONB queries, indexes cho user_id, device_id, created_at, resolved

**Schema**:
```sql
CREATE TABLE sensor_warnings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(50),
    warning_type VARCHAR(50) NOT NULL, -- 'vital_signs', 'ecg_signal'
    severity VARCHAR(20) DEFAULT 'warning', -- 'info', 'warning', 'error', 'critical'
    message TEXT NOT NULL,
    details TEXT,
    sensor_data JSONB, -- Problematic sensor readings
    resolved BOOLEAN DEFAULT FALSE,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Status**: ✅ Migrated successfully

---

### 2️⃣ **Server-Side Validation**

#### A. MLP (Vital Signs) Validation
**File**: `services/predict_service.js` (lines 78-90)

**Rules**:
```javascript
- SpO2: Must be 1-100%
- Heart Rate: Must be 1-250 bpm  
- Temperature: Must be 30-45°C
```

**Behavior**:
- ❌ **Rejects diagnosis** if any vital sign is invalid
- 🔔 **Throws error** with descriptive message
- Example: `"Cannot diagnose with invalid vital signs: Invalid SpO2: 0%, Invalid HR: 0 bpm"`

#### B. ECG Signal Validation  
**File**: `services/predict_service.js` (lines 219-238)

**Checks**:
```javascript
1. Flat Line Check: All datapoints same value → REJECT
2. Saturation Check: >80% max values (2047/2046) → REJECT  
3. Empty Data Check: No datapoints → REJECT
```

**Behavior**:
- ❌ **Rejects diagnosis** if signal quality poor
- 🔔 **Throws error** with specific issue
- Example: `"ECG signal saturated: 100/100 points maxed out"`

**Status**: ✅ Validation implemented in both models

---

### 3️⃣ **Error Handling & Notifications**

#### A. MQTT Service Updates
**File**: `services/mqtt_service.js`

**New Method**: `saveSensorWarning(warningData)` (lines 90-120)
- Saves validation errors to database
- Returns warning ID and timestamp
- Handles errors gracefully

**Updated Handlers**:

**handleMedicalData** (lines 323-364):
```javascript
catch (aiError) {
    if (aiError.message.includes('Invalid')) {
        // 1. Save to database
        await this.saveSensorWarning({
            user_id, device_id,
            warning_type: 'vital_signs',
            severity: 'warning',
            message: 'Dữ liệu cảm biến không hợp lệ...',
            details: aiError.message,
            sensor_data: { spo2, heart_rate, temperature, sys_bp, dia_bp }
        });
        
        // 2. Emit Socket.IO event
        io.to(`user_${user_id}`).emit('sensor_warning', {
            type: 'vital_signs',
            message: 'Dữ liệu cảm biến không hợp lệ. Vui lòng kiểm tra thiết bị.',
            details: aiError.message,
            data: { spo2, heart_rate, temperature },
            timestamp: new Date(),
            severity: 'warning'
        });
        
        // 3. Publish MQTT warning to ESP32
        this.client.publish(`health/device/${device_id}/warning`, JSON.stringify({
            type: 'sensor_error',
            message: 'Sensor data invalid',
            details: aiError.message,
            timestamp: new Date()
        }));
    }
}
```

**handleECGData** (lines 505-554):
- Similar structure for ECG validation errors
- Saves ECG-specific sensor data (packet_id, datapoints_count, sample_values)
- Severity escalates to 'error' if saturated

**Status**: ✅ Complete notification pipeline

---

### 4️⃣ **REST API Endpoints**

**File**: `routes/sensor_warnings.js`

**Endpoints**:

1. **GET `/api/sensor-warnings`** - Get warnings list
   - Query params: `limit`, `offset`, `warning_type`, `severity`, `resolved`, `device_id`
   - Returns: Paginated warnings + total count
   - Auth: Required (JWT)

2. **GET `/api/sensor-warnings/summary`** - Get statistics
   - Query params: `days` (default: 7)
   - Returns: Count by type/severity, recent unresolved warnings
   - Auth: Required (JWT)

3. **PATCH `/api/sensor-warnings/:id/resolve`** - Mark as resolved
   - Sets `resolved = true`, `resolved_at = NOW()`
   - Auth: Required (JWT, owner only)

4. **DELETE `/api/sensor-warnings/:id`** - Delete warning
   - Removes from database
   - Auth: Required (JWT, owner only)

**Registered**: ✅ In `routes/index.js` as `/api/sensor-warnings`

**Status**: ✅ All endpoints implemented

---

### 5️⃣ **Socket.IO Events**

**Event**: `sensor_warning`

**Payload Structure**:
```javascript
{
  type: 'vital_signs' | 'ecg_signal',
  message: 'User-friendly Vietnamese message',
  details: 'Technical error details',
  data: {
    // Vital signs: { spo2, heart_rate, temperature }
    // ECG: { device_id, packet_id, datapoints_count }
  },
  timestamp: ISO8601 datetime,
  severity: 'info' | 'warning' | 'error' | 'critical'
}
```

**Trigger Conditions**:
- Vital signs validation fails (SpO2, HR, Temp out of range)
- ECG signal validation fails (flat line, saturated, empty)

**Delivery**: Real-time to `user_{user_id}` room

**Status**: ✅ Events emitted on validation errors

---

### 6️⃣ **MQTT Warnings to ESP32**

**Topic**: `health/device/{device_id}/warning`

**Payload**:
```json
{
  "type": "sensor_error" | "ecg_sensor_error",
  "message": "Sensor data invalid" | "ECG signal quality poor",
  "details": "Invalid SpO2: 0%",
  "timestamp": "2026-01-04T10:30:00Z"
}
```

**ESP32 Can**:
- Display warning on OLED/LCD
- Blink red LED
- Sound buzzer
- Retry sensor initialization
- Show specific error (e.g., "Check MAX30102")

**Status**: ✅ Published on validation errors

---

## 📊 Data Flow Diagram

```
ESP32 Sensor Data
      ↓ (MQTT Publish)
      ↓
MQTT Service (mqtt_service.js)
      ↓
Predict Service Validation (predict_service.js)
      ├─ VALID ✅
      │   ↓
      │   AI Diagnosis → Save to ai_diagnoses
      │   ↓
      │   Socket.IO: 'ai_medical_alert' / 'ai_ecg_alert'
      │
      └─ INVALID ❌
          ↓
          1️⃣ Save sensor_warnings to DB
          2️⃣ Socket.IO: 'sensor_warning' event → Flutter App
          3️⃣ MQTT Publish: warning → ESP32
          ↓
Flutter App
      ├─ Realtime: Show toast/notification
      ├─ Dashboard: Update sensor status widget
      └─ History: API call to view past warnings
          
ESP32
      └─ LED/Display/Buzzer: Alert user to check sensors
```

---

## 🧪 Testing

### Database Test
**File**: `test_sensor_warnings.js`

**Run**: `node test_sensor_warnings.js`

**Tests**:
- ✅ Database schema (sensor_warnings table exists)
- ⏳ API endpoints (requires JWT token)
- ⏳ Socket.IO events (requires running server + client)
- ⏳ MQTT warnings (requires ESP32 publishing invalid data)

**Current Status**: Database ready, no warnings yet (waiting for invalid sensor data)

---

## 📱 Flutter App Integration

**Document**: `SENSOR_WARNINGS_FLUTTER_GUIDE.md`

**Includes**:
- Socket.IO event listeners
- REST API usage examples
- UI/UX recommendations
- Dart data models
- Implementation checklist

**Status**: ✅ Complete guide provided

---

## 🔒 Validation Rules Reference

### Vital Signs
| Parameter | Valid Range | Example Invalid | Error Message |
|-----------|-------------|-----------------|---------------|
| SpO2 | 1-100% | 0 | Invalid SpO2: 0% |
| Heart Rate | 1-250 bpm | 0 | Invalid HR: 0 bpm |
| Temperature | 30-45°C | 29.4 | Invalid Temp: 29.4°C |

### ECG Signal
| Check | Condition | Example | Error Message |
|-------|-----------|---------|---------------|
| Flat Line | All same value | [2047, 2047, ...] | Invalid ECG pattern: All datapoints are same |
| Saturation | >80% maxed | 90/100 points = 2047 | ECG signal saturated: 90/100 points maxed out |
| Empty | Length = 0 | [] | Insufficient ECG datapoints |

---

## 🎯 Next Steps

### For Testing:
1. ✅ **Restart server** with updated code
   ```bash
   cd HealthAI_Server
   npm start
   ```

2. ⏳ **Wait for invalid sensor data** from ESP32
   - Server will log: `⚠️ [AI] Skipping diagnosis - invalid input: ...`
   - Database will receive sensor_warnings records
   - Socket.IO will emit events

3. ⏳ **Test Socket.IO** in Flutter app
   - Listen for `sensor_warning` events
   - Display toast/notification
   - Update dashboard widget

4. ⏳ **Test REST API** in Flutter app
   - GET `/api/sensor-warnings` - View history
   - GET `/api/sensor-warnings/summary` - Dashboard stats
   - PATCH `/api/sensor-warnings/:id/resolve` - Mark as fixed

### For ESP32:
1. **Fix sensor initialization** (Priority: HIGH)
   - Reference: `AI_DIAGNOSIS_VALIDATION_ISSUES.md`
   - Check MAX30102 (SpO2 + HR)
   - Check MLX90614 (Temperature)
   - Check AD8232 (ECG)

2. **Subscribe to warnings**
   ```cpp
   mqtt.subscribe("health/device/ESP32_001/warning");
   ```

3. **Handle warnings**
   ```cpp
   void callback(char* topic, byte* payload, unsigned int length) {
     if (strcmp(topic, "health/device/ESP32_001/warning") == 0) {
       // Parse JSON payload
       // Blink LED red
       // Show message on OLED
       // Retry sensor init
     }
   }
   ```

---

## 📝 Files Modified/Created

### Modified:
- ✅ `services/mqtt_service.js` - Added saveSensorWarning(), updated error handlers
- ✅ `routes/index.js` - Registered sensor_warnings routes

### Created:
- ✅ `database/migrations/002_add_sensor_warnings_table.sql` - Database schema
- ✅ `routes/sensor_warnings.js` - REST API endpoints
- ✅ `test_sensor_warnings.js` - Testing script
- ✅ `SENSOR_WARNINGS_FLUTTER_GUIDE.md` - Flutter integration guide
- ✅ `SENSOR_WARNINGS_SUMMARY.md` - This summary document

---

## ✅ System Status

| Component | Status | Notes |
|-----------|--------|-------|
| Database Schema | ✅ Ready | sensor_warnings table migrated |
| Validation Logic | ✅ Implemented | MLP + ECG validation rules |
| Error Handling | ✅ Complete | Graceful degradation |
| Database Logging | ✅ Implemented | saveSensorWarning() method |
| Socket.IO Events | ✅ Implemented | sensor_warning event |
| MQTT Warnings | ✅ Implemented | Publishes to ESP32 |
| REST API | ✅ Complete | 4 endpoints + auth |
| Flutter Guide | ✅ Complete | Full documentation |
| Testing Script | ✅ Ready | Needs JWT token for API tests |
| Server Restart | ⏳ Pending | Apply changes |
| ESP32 Fixes | ⏳ Pending | Sensor initialization |
| Flutter Implementation | ⏳ Pending | Socket.IO + API integration |

---

## 🎓 Key Benefits

1. **Patient Safety** ✅
   - No incorrect AI diagnoses from bad sensor data
   - Clear warnings when sensors malfunction
   
2. **User Experience** ✅
   - Realtime notifications via Socket.IO
   - Historical view of sensor issues
   - Clear messages in Vietnamese
   
3. **Debugging** ✅
   - Full sensor data saved in JSONB
   - Timestamps for incident analysis
   - Device ID tracking
   
4. **Hardware Integration** ✅
   - ESP32 receives warnings via MQTT
   - Can self-diagnose and retry
   - Visual/audio feedback to user

5. **Scalability** ✅
   - Indexed database for fast queries
   - Pagination support
   - Filter by type/severity/device

---

## 📞 Support

**Issues?**
- Check server logs: `console.log` output shows validation errors
- Check database: `SELECT * FROM sensor_warnings ORDER BY created_at DESC LIMIT 10`
- Check Socket.IO: Verify client connection and listener setup
- Check MQTT: Verify ESP32 subscribed to `health/device/{device_id}/warning`

**Questions?**
- Review `SENSOR_WARNINGS_FLUTTER_GUIDE.md` for Flutter implementation
- Review `AI_DIAGNOSIS_VALIDATION_ISSUES.md` for ESP32 sensor fixes
- Run `node test_sensor_warnings.js` to verify database

---

🎉 **Hệ thống đã sẵn sàng! Người dùng sẽ luôn biết khi nào data không đủ tốt để chẩn đoán!** 🎉
