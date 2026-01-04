# AI DIAGNOSIS VALIDATION ISSUES - ESP32 FIX REQUIRED

## 🔴 Vấn đề phát hiện (Jan 4, 2026)

### 1. VITAL Model - Chẩn đoán SAI với vital signs = 0

**Dữ liệu từ ESP32:**
```json
{
  "spo2": 0,           ← SpO2 = 0% (người chết!)
  "heart_rate": 0,     ← HR = 0 bpm (không có nhịp tim!)
  "temperature": 29.4  ← Nhiệt độ quá thấp (bình thường 36-37°C)
}
```

**Kết quả AI:** "Low Risk" 97.5% confidence → **SAI HOÀN TOÀN**

**Nguyên nhân:** ESP32 sensor chưa đọc được data, trả về giá trị mặc định 0.

### 2. ECG Model - 100% Fusion cho mọi trường hợp

**Pattern ECG từ ESP32:**
- Toàn giá trị `2047` (max ADC 11-bit) hoặc `0`
- Không có sóng ECG thực tế
- Pattern: `[2047, 2047, 2047... → 0, 0, 0...]`

**Kết quả AI:** 100% "Fusion (Hòa trộn)" mọi lúc → **Model overfitting**

## ✅ Giải pháp đã áp dụng (Server-side)

### 1. Input Validation - predict_service.js

**MLP Model (Vitals):**
```javascript
// REJECT invalid vital signs
if (spo2 <= 0 || spo2 > 100) → Error
if (heart_rate <= 0 || heart_rate > 250) → Error  
if (temperature < 30 || temperature > 45) → Error
```

**ECG Model:**
```javascript
// REJECT invalid ECG patterns
- All same value (flat line)
- >80% max values (saturated signal)
- Empty dataPoints
```

### 2. Graceful Error Handling - mqtt_service.js

```javascript
catch (aiError) {
    if (error.message.includes('Invalid')) {
        console.warn('⚠️ Skipping diagnosis - invalid input');
        // Không crash server, chỉ skip diagnosis
    }
}
```

## 🔧 YÊU CẦU FIX ESP32

### 1. Kiểm tra MAX30102 (SpO2 & HR sensor)

```cpp
// Verify sensor initialization
if (!particleSensor.begin()) {
    Serial.println("❌ MAX30102 not found!");
}

// Check if data is valid before sending
if (heartRate > 0 && heartRate < 250 && spo2 > 0 && spo2 <= 100) {
    // Send to MQTT
} else {
    Serial.println("⚠️ Invalid vital signs - skipping");
}
```

### 2. Kiểm tra MLX90614 (Temperature sensor)

```cpp
float temp = mlx.readObjectTempC();

// Validate temperature range
if (temp < 30 || temp > 45) {
    Serial.println("⚠️ Invalid temperature - using ambient");
    temp = mlx.readAmbientTempC();
}
```

### 3. Kiểm tra AD8232 (ECG sensor)

```cpp
// Check for signal saturation
int maxCount = 0;
for (int i = 0; i < 100; i++) {
    if (ecgData[i] >= 2040) maxCount++; // Near max
}

if (maxCount > 80) {
    Serial.println("⚠️ ECG signal saturated - check electrodes!");
    return; // Don't send
}

// Check for flat line
if (min == max) {
    Serial.println("⚠️ ECG flat line - check connection!");
    return;
}
```

### 4. MQTT Payload cần gửi

**Medical Data (device/medical_data):**
```json
{
  "temp": 36.5,      ← MUST be 30-45°C
  "spo2": 98,        ← MUST be 1-100%
  "hr": 75,          ← MUST be 1-250 bpm
  "device_id": "ESP32"
}
```

**ECG Data (device/ecg_data):**
```json
{
  "device_id": "ESP32",
  "packetId": 12345,
  "dataPoints": [100 ECG values], ← NOT all 2047 or all 0!
  "avgHR": 75
}
```

## 📊 Validation Rules

### Vital Signs
| Parameter | Valid Range | Invalid Action |
|-----------|-------------|----------------|
| SpO2 | 1-100% | Skip diagnosis |
| Heart Rate | 1-250 bpm | Skip diagnosis |
| Temperature | 30-45°C | Skip diagnosis |

### ECG Signal
| Check | Rule | Invalid Action |
|-------|------|----------------|
| Flat line | All same value | Skip diagnosis |
| Saturated | >80% max values | Skip diagnosis |
| Empty | No data points | Skip diagnosis |

## 🎯 Expected Behavior (After Fix)

### ✅ Valid Data → Normal Diagnosis
```
📩 NEW Medical data: HR=75, SpO2=98, Temp=36.5°C, User=10
🤖 [AI] Running MLP diagnosis...
✅ [AI-MLP] DIAGNOSIS COMPLETED
   Risk Level: Low Risk
   Confidence: 85.2%
```

### ⚠️ Invalid Data → Skip Diagnosis
```
📩 NEW Medical data: HR=0, SpO2=0, Temp=29.4°C, User=10
⚠️ [AI] Skipping diagnosis - invalid input: Invalid SpO2: 0%
```

## 📝 Testing Checklist

- [ ] MAX30102 đọc được HR và SpO2 (không phải 0)
- [ ] MLX90614 đọc được nhiệt độ 35-38°C
- [ ] AD8232 ECG signal có sóng (không flat, không saturated)
- [ ] MQTT gửi data đúng format
- [ ] Server log hiển thị "✅ DIAGNOSIS COMPLETED" (không có ⚠️ warning)
- [ ] Database lưu input_data với giá trị hợp lệ

## 🔗 References

- **Validation Code:** `services/predict_service.js` (lines 78-90, 219-238)
- **Error Handling:** `services/mqtt_service.js` (lines 289-297, 420-428)
- **Database Migration:** `database/migrations/001_add_ai_diagnosis_input_output.sql`

---
**Created:** Jan 4, 2026  
**Priority:** HIGH  
**Status:** Server-side validation implemented, ESP32 fix pending
