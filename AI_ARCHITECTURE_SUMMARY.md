# 🏥 HEALTH IOT - DUAL-FLOW AI ARCHITECTURE

## 📊 KIẾN TRÚC HỆ THỐNG

```
┌─────────────┐         MQTT          ┌──────────────────┐
│   ESP32     │ ─────────────────────→ │   HiveMQ Cloud   │
│  (Sensors)  │   Port 8883 (TLS)     │   MQTT Broker    │
└─────────────┘                        └──────────────────┘
                                              ↓
                                        Subscribe (QoS 1)
                                              ↓
                                    ┌─────────────────────┐
                                    │  Backend Node.js    │
                                    │  ────────────────   │
                                    │  MQTT Service       │
                                    │  ├─ Medical Data    │
                                    │  └─ ECG Data        │
                                    │                     │
                                    │  🤖 AI MODELS       │
                                    │  ├─ MLP (Vitals)    │
                                    │  └─ CNN (ECG)       │
                                    └─────────────────────┘
                                              ↓
                                        Socket.IO Emit
                                              ↓
                        ┌─────────────────────┴─────────────────────┐
                        ↓                                           ↓
                  medical_data_new                            ecg_data_new
                        ↓                                           ↓
                    ┌───────────────────────────────────────────────────┐
                    │        Flutter App (Socket.IO Client)            │
                    │  ──────────────────────────────────────────────  │
                    │  Socket Service → MQTT Service (Gateway)         │
                    │                      ↓                            │
                    │         StreamControllers (Broadcast)            │
                    │         ├─ healthStream                          │
                    │         └─ ecgStream                             │
                    │                      ↓                            │
                    │         Patient Dashboard (StreamBuilder)        │
                    │         ├─ Real-time Vitals Display             │
                    │         └─ Professional ECG Chart                │
                    └───────────────────────────────────────────────────┘
```

## 🤖 LUỒNG 1: AI DIAGNOSIS - MEDICAL DATA (MLP Model)

### Input Features (9 dimensions):
```javascript
[
  spo2,           // Oxygen Saturation (%)
  temperature,    // Body Temperature (°C)
  heart_rate,     // Heart Rate (BPM)
  derived_map,    // Mean Arterial Pressure = (SBP + 2*DBP)/3
  age,            // Age (years)
  weight_kg,      // Weight (kg)
  height_m,       // Height (m)
  derived_bmi,    // BMI = Weight / Height²
  gender_encoded  // Gender (0=Female, 1=Male)
]
```

### Processing Pipeline:
1. **Data Collection**: ESP32 → HiveMQ → Backend MQTT Service
2. **User Profile**: Query database (gender, birth_year, weight, height)
3. **Feature Engineering**: Calculate MAP, BMI, Age
4. **Normalization**: StandardScaler với scaler_mlp.json
5. **AI Prediction**: TensorFlow.js MLP Model
6. **Risk Classification**: 
   - Low Risk (Normal)
   - Medium Risk (Warning)
   - High Risk (Danger)
   - Very High Risk (Critical)
7. **Database**: Save to `health_records` + `ai_diagnoses`
8. **Alert**: Socket.IO → Flutter (nếu risk ≥ Medium)

### Output Format:
```javascript
{
  model: "MLP",
  result: "High Risk",
  riskLabel: "High Risk",
  confidence: "87.5",
  severity: "DANGER",
  recordId: 12345,
  riskEncoded: 3
}
```

## 🫀 LUỒNG 2: AI DIAGNOSIS - ECG DATA (CNN Model)

### Input:
- **Shape**: [1, 100, 1] (100 data points từ ESP32 ADC)
- **Sampling Rate**: 125 Hz
- **Duration**: ~0.8 giây

### Processing Pipeline:
1. **Data Collection**: ESP32 → HiveMQ → Backend MQTT Service
2. **Preprocessing**:
   - Padding/Truncate về 100 points
   - Z-Score Normalization: `(x - mean) / std`
3. **AI Prediction**: TensorFlow.js CNN Model
4. **ECG Classification**:
   - **N**: Normal (Bình thường)
   - **S**: Supraventricular (Trên thất) - WARNING
   - **V**: Ventricular (Thất) - DANGER
   - **F**: Fusion (Hòa trộn) - DANGER
5. **Database**: Save to `ecg_readings` + `ai_diagnoses`
6. **Alert**: Socket.IO → Flutter (nếu V hoặc F)

### Output Format:
```javascript
{
  model: "ECG",
  result: "Ventricular (Thất)",
  confidence: "92.3",
  severity: "DANGER",
  ecgId: 67890,
  recommendation: "Cần khám ngay lập tức!"
}
```

## 📁 FILE STRUCTURE

### Backend:
```
HealthAI_Server/
├── config/
│   ├── aiModels.js          # TensorFlow.js model loader
│   └── mqtt.js              # HiveMQ configuration
├── models/
│   ├── tfjs_mlp_model/      # MLP Binary Classifier
│   ├── tfjs_ecg_model/      # CNN 4-class ECG Classifier
│   ├── scaler_mlp.json      # StandardScaler cho MLP
│   ├── scaler_ecg.json      # Z-Score params cho ECG
│   └── risk_encoder.json    # Label encoder
├── services/
│   ├── mqtt_service.js      # ✅ MQTT subscriber + AI integration
│   └── predict_service.js   # ✅ AI diagnosis functions
└── app.js                   # Server entry point
```

### Frontend (CLEANED):
```
doan2/lib/
├── service/
│   ├── mqtt_service.dart    # ✅ Socket.IO gateway (KHÔNG connect HiveMQ)
│   └── socket_service.dart  # ✅ Socket.IO client + event listeners
├── presentation/patient/dashboard/
│   └── patient_dashboard_screen.dart  # ✅ Professional ECG chart
└── models/patient/
    └── health_model.dart    # HealthMetric data model
```

## 🔧 CHANGES MADE

### ✅ Backend Integration:
1. **MQTT Service**: Added `predictService` import
2. **Medical Data Handler**: 
   - Call `processVitals()` for AI diagnosis
   - Send `ai_medical_alert` via Socket.IO
3. **ECG Data Handler**:
   - Call `processECG()` for AI diagnosis  
   - Send `ai_ecg_alert` via Socket.IO
4. **Predict Service**: Fixed return format with `riskEncoded` & `recommendation`

### ✅ Frontend Cleanup:
1. **MQTT Service**: 
   - ❌ REMOVED: Direct HiveMQ connection
   - ❌ REMOVED: MQTT client, topics, authentication
   - ✅ KEPT: StreamControllers for dashboard
   - ✅ NEW: `handleSocketMedicalData()` & `handleSocketECGData()`
2. **Dependencies**:
   - ❌ REMOVED: `mqtt_client: ^10.3.1`
   - ✅ KEPT: `socket_io_client: ^3.1.2`
3. **ECG Display**:
   - ✅ Professional processing (zero-centering, smoothing)
   - ✅ Medical-grade grid (200ms, 1mV intervals)
   - ✅ Color: #00E676 (professional green)
   - ✅ Range: ±3.5mV, 125Hz sampling

## 🚀 DEPLOYMENT CHECKLIST

### Backend:
- [ ] Verify AI models loaded: Check logs for "✅ TensorFlow.js backend"
- [ ] ESP32 sending `user_id`: Required for AI diagnosis
- [ ] Database tables: `health_records`, `ecg_readings`, `ai_diagnoses`
- [ ] Socket.IO emitting: `medical_data_new`, `ecg_data_new`, `ai_medical_alert`, `ai_ecg_alert`

### Frontend:
- [x] Remove old MQTT service (DONE)
- [x] Update `mqtt_service.dart` to Socket.IO gateway (DONE)
- [x] Professional ECG chart (DONE)
- [ ] Run `flutter pub get` to remove mqtt_client
- [ ] Hot restart app

### ESP32:
- [ ] Add `user_id` field to published data:
  ```cpp
  doc["user_id"] = 10; // Before serializeJson()
  ```

## 📊 EXPECTED LOGS

### Backend (Normal Flow):
```
✅ MQTT Connected successfully to HiveMQ Cloud
📩 NEW Medical data: HR=75, SpO2=98, Temp=36.5°C
🤖 [AI] Running MLP diagnosis for medical data...
✅ [AI-MLP] Diagnosis: Low Risk (94.2% confidence)
📊 NEW ECG data: Packet 12345, 100 points
🤖 [AI] Running ECG diagnosis (CNN Model)...
✅ [AI-ECG] Diagnosis: Normal (Bình thường) (98.7% confidence)
```

### Backend (Alert Flow):
```
🤖 [AI] Running MLP diagnosis for medical data...
✅ [AI-MLP] Diagnosis: High Risk (87.5% confidence)
🚨 Sending AI alert: High Risk
💓 [SOCKET] Real-time Medical Data emitted
```

### Frontend:
```
✅ [SOCKET] Connected Successfully!
💓 [SOCKET] Real-time Medical Data: HR=75, SpO2=98, Temp=36.5°C
✅ Medical data forwarded to dashboard
📊 [SOCKET] Real-time ECG Data: Packet 12345
✅ ECG data forwarded to dashboard
```

## 🎯 ADVANTAGES

1. **✅ No TLS Issues**: Flutter không cần connect HiveMQ trực tiếp
2. **✅ Centralized AI**: Backend xử lý AI, lightweight app
3. **✅ Single Connection**: Socket.IO cho cả data + alerts + chat
4. **✅ Professional ECG**: Medical-grade visualization
5. **✅ Dual AI Diagnosis**: MLP (vitals) + CNN (ECG)
6. **✅ Real-time Alerts**: Instant notification khi có vấn đề
7. **✅ Clean Architecture**: Separation of concerns

## 📝 NEXT STEPS

1. **ESP32**: Add `user_id` to enable AI diagnosis
2. **Testing**: Verify AI models với real sensor data
3. **Frontend**: Hiển thị AI diagnosis results trong dashboard
4. **Optimization**: Batch processing nếu cần tăng tốc
