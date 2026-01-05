# 🔌 ESP32 FIRMWARE - TÀI LIỆU CHI TIẾT

> **Firmware cho thiết bị đeo IoT theo dõi sức khỏe**

---

## 📋 MỤC LỤC

- [1. Tổng Quan](#1-tổng-quan)
- [2. Hardware Configuration](#2-hardware-configuration)
- [3. Software Architecture](#3-software-architecture)
- [4. Chế Độ Đo](#4-chế-độ-đo)
- [5. MQTT Protocol](#5-mqtt-protocol)
- [6. WiFi Configuration](#6-wifi-configuration)
- [7. Xử Lý Tín Hiệu](#7-xử-lý-tín-hiệu)
- [8. API Reference](#8-api-reference)
- [9. Build & Flash](#9-build--flash)
- [10. Troubleshooting](#10-troubleshooting)

---

## 1. TỔNG QUAN

### 1.1 Thông Tin Firmware

| Thuộc tính | Giá trị |
|------------|---------|
| **Platform** | ESP32 DevKit |
| **Framework** | Arduino |
| **Build System** | PlatformIO |
| **Language** | C++ |
| **Version** | 1.0.0 |

### 1.2 Mục Đích

Firmware ESP32 thu thập dữ liệu sức khỏe từ các cảm biến và gửi lên backend qua MQTT:

✅ **Sinh hiệu (Vital Signs)**:
- Nhịp tim (Heart Rate): 60-180 BPM
- SpO2: 90-100%
- Nhiệt độ cơ thể: 35-42°C

✅ **Điện tim (ECG)**:
- Sampling rate: 125Hz
- Batch size: 100 samples/packet
- Digital gain: 6.0x
- Low-pass filter

✅ **WiFi Configuration**:
- Web portal setup tại `192.168.4.1`
- Scan và kết nối WiFi
- Lưu credentials vào EEPROM

### 1.3 Tính Năng Chính

- ✅ Tự động phát hiện chế độ đo (Vital/ECG)
- ✅ Phát hiện tuột dây điện cực thông minh (2s timeout)
- ✅ Xử lý tín hiệu số (HP/LP filter + Gain)
- ✅ Loại bỏ nhiễu flatline
- ✅ MQTT publish với TLS/SSL
- ✅ Auto-reconnect WiFi & MQTT
- ✅ Web server cấu hình WiFi

---

## 2. HARDWARE CONFIGURATION

### 2.1 Danh Sách Linh Kiện

| Linh kiện | Model | Chức năng | Interface |
|-----------|-------|-----------|-----------|
| **Microcontroller** | ESP32 DevKit | Vi điều khiển chính | - |
| **Pulse Oximeter** | MAX30102 | Nhịp tim + SpO2 | I2C |
| **Temperature Sensor** | MLX90614 | Nhiệt độ hồng ngoại | I2C |
| **ECG Sensor** | AD8232 | Điện tim | Analog (ADC) |

### 2.2 Sơ Đồ Kết Nối

```
┌─────────────────────────────────────────────────────────┐
│                      ESP32 DevKit                        │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  GPIO 21 (SDA) ─────────┬──────────────┐                │
│  GPIO 22 (SCL) ────────┐│              │                │
│                        ││              │                │
│                   ┌────▼▼────┐   ┌────▼▼────┐          │
│                   │ MAX30102 │   │ MLX90614 │          │
│                   │          │   │          │          │
│                   │ HR+SpO2  │   │   Temp   │          │
│                   └──────────┘   └──────────┘          │
│                                                           │
│  GPIO 34 (ADC1_6) ─────────> AD8232 OUTPUT              │
│  GPIO 13 (LO+)    ─────────> AD8232 LO+                 │
│  GPIO 14 (LO-)    ─────────> AD8232 LO-                 │
│                                                           │
│  GPIO 0 (BOOT)    ─────────> Button (Config Mode)       │
│  GPIO 2 (LED)     ─────────> LED Indicator              │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

### 2.3 Pin Definitions

```cpp
// Hardware Pins
#define BUTTON_PIN 0          // Boot button
#define LED_PIN 2             // Built-in LED
#define ECG_ADC_PIN 34        // AD8232 analog output
#define LOD_PLUS 13           // Lead-off detect +
#define LOD_MINUS 14          // Lead-off detect -

// I2C (Default)
#define SDA_PIN 21
#define SCL_PIN 22
```

### 2.4 ADC Configuration

```cpp
// Cấu hình ADC 12-bit
analogReadResolution(12);       // 0-4095
analogSetAttenuation(ADC_11db); // Dải đo 0-3.3V

// Độ phân giải:
// - 12-bit: 4096 levels
// - 1 level = 3.3V / 4096 ≈ 0.806 mV
```

---

## 3. SOFTWARE ARCHITECTURE

### 3.1 State Machine

```
┌──────────────────────────────────────────────────────────┐
│                   FIRMWARE STATE                          │
└──────────────────────────────────────────────────────────┘

         ┌──────────────┐
         │  POWER ON    │
         └──────┬───────┘
                │
                ▼
         ┌──────────────┐
         │  INIT SETUP  │───────> Load WiFi from EEPROM
         │              │───────> Init I2C sensors
         └──────┬───────┘───────> Connect WiFi
                │
                ▼
         ┌──────────────┐
    ┌────│  CHECK MODE  │
    │    └──────┬───────┘
    │           │
    │           ├─── Button pressed 3s ───> CONFIG MODE (Web Portal)
    │           │
    │           ├─── No lead detected ───> IDLE (Ready)
    │           │
    │           ├─── ECG leads on ────────> MODE_ECG
    │           │
    │           └─── Hand on sensor ───────> MODE_VITAL
    │           
    │    ┌──────▼───────┐
    │    │  MODE_ECG    │
    │    │              │───────> Sample 125Hz
    │    │  (60s max)   │───────> Process signal
    │    │              │───────> Batch 100 samples
    │    │              │───────> Publish MQTT
    │    └──────┬───────┘
    │           │
    │           ├─── Lead off 2s ─────────> STOP & RESET
    │           ├─── Timeout 60s ──────────> STOP & RESET
    │           └─── Complete ─────────────> IDLE
    │
    │    ┌──────▼───────┐
    │    │ MODE_VITAL   │
    │    │              │───────> Collect 50 samples
    │    │ (15s max)    │───────> Calculate HR, SpO2
    │    │              │───────> Read temperature
    │    │              │───────> Publish MQTT
    │    └──────┬───────┘
    │           │
    │           ├─── Hand removed ─────────> STOP
    │           ├─── Timeout 15s ──────────> SEND RESULT
    │           └─── Complete ─────────────> SEND RESULT
    │
    └───────────┘
```

### 3.2 Main Loop Flow

```cpp
void loop() {
    // 1. Kiểm tra button (Config mode)
    checkPhysicalButton();
    if (isConfigMode) {
        server.handleClient();
        return;
    }
    
    // 2. Kết nối MQTT
    if (!client.connected()) {
        forceReconnect();
    }
    client.loop();
    
    // 3. Phát hiện tuột dây ECG (Smart detection với 2s timeout)
    bool leadOff = checkLeadStatus();
    
    // 4. Logic bắt đầu đo
    if (!isMeasuring && !dataSent) {
        detectMeasurementStart();
    }
    
    // 5. Thu thập mẫu
    if (isMeasuring) {
        if (currentMode == MODE_VITAL) {
            collectVitalSamples();
        } else if (currentMode == MODE_ECG) {
            collectEcgSamples();
        }
    }
    
    // 6. Timeout check
    checkTimeout();
}
```

---

## 4. CHẾ ĐỘ ĐO

### 4.1 MODE_VITAL (SpO2 + Temperature)

#### 4.1.1 Trigger Condition
```cpp
// Điều kiện bắt đầu:
// - Không có dây ECG
// - Nhiệt độ > 34°C (tay đặt lên sensor)
// - Signal IR > 7000 (có ngón tay)

if (temp > 34.0 && irValue > 7000) {
    currentMode = MODE_VITAL;
    isMeasuring = true;
}
```

#### 4.1.2 Data Collection
```cpp
#define SAMPLES_COUNT 50      // Số mẫu cần thu
#define SAMPLING_DELAY 25     // 25ms/sample → 40Hz

uint32_t irBuffer[SAMPLES_COUNT];
uint32_t redBuffer[SAMPLES_COUNT];
int bufferIndex = 0;

// Thu thập
if (millis() - lastSampleTime > SAMPLING_DELAY) {
    uint32_t ir = particleSensor.getIR();
    uint32_t red = particleSensor.getRed();
    
    if (ir > 7000) {  // Có tín hiệu
        irBuffer[bufferIndex] = ir;
        redBuffer[bufferIndex] = red;
        bufferIndex++;
    }
}
```

#### 4.1.3 Calculation
```cpp
void calculateHealthData(int count) {
    long irSum = 0;
    long redSum = 0;
    int irMax = irBuffer[0], irMin = irBuffer[0];
    
    // Tính min/max/average
    for (int i = 0; i < count; i++) {
        irSum += irBuffer[i];
        redSum += redBuffer[i];
        if (irBuffer[i] > irMax) irMax = irBuffer[i];
        if (irBuffer[i] < irMin) irMin = irBuffer[i];
    }
    
    float irAC = irMax - irMin;
    float irDC = irSum / count;
    float redDC = redSum / count;
    
    // SpO2 (Beer-Lambert Law)
    float R = (irAC / irDC) / (redDC / irDC);
    finalSpO2 = 110 - 25 * R;
    
    // Heart Rate (từ peaks)
    int hr = detectHeartRate(irBuffer, count);
    smoothRawHR = 0.7 * smoothRawHR + 0.3 * hr;
    finalHR = (int)smoothRawHR;
    
    // Temperature
    finalTempToSend = maxTempSession;
}
```

#### 4.1.4 MQTT Publish
```json
{
  "device_id": "ESP32",
  "userID": 10,
  "heart_rate": 75,
  "spo2": 98,
  "temperature": 36.5,
  "timestamp": "2024-01-05T10:30:00Z"
}
```

**Topic**: `iot/vital/{userId}`

### 4.2 MODE_ECG (Electrocardiogram)

#### 4.2.1 Trigger Condition
```cpp
// Điều kiện bắt đầu:
// - Cả 2 dây LO+ và LO- đều LOW (có tiếp xúc)
// - Giữ ổn định 200ms

if (digitalRead(LOD_PLUS) == LOW && 
    digitalRead(LOD_MINUS) == LOW) {
    delay(200);  // Đợi ổn định
    
    if (digitalRead(LOD_PLUS) == LOW && 
        digitalRead(LOD_MINUS) == LOW) {
        currentMode = MODE_ECG;
        isMeasuring = true;
    }
}
```

#### 4.2.2 Sampling Configuration
```cpp
#define ECG_BATCH_SIZE 100          // 100 samples/packet
#define ECG_SAMPLING_INTERVAL_US 8000  // 8000µs = 125Hz

// Sampling loop
if (micros() - lastEcgMicros >= ECG_SAMPLING_INTERVAL_US) {
    lastEcgMicros = micros();
    
    int rawVal = analogRead(ECG_ADC_PIN);
    int processedVal = processEcgSample(rawVal);
    
    ecgBuffer[ecgIndex] = processedVal;
    ecgIndex++;
    
    if (ecgIndex >= ECG_BATCH_SIZE) {
        sendECGBatch();
        ecgIndex = 0;
    }
}
```

#### 4.2.3 Lead-Off Detection (Smart)
```cpp
// Phát hiện tuột dây thông minh với timeout 2s
bool leadOff = (digitalRead(LOD_PLUS) == HIGH || 
                digitalRead(LOD_MINUS) == HIGH);

static unsigned long leadOffTimer = 0;

if (leadOff) {
    if (leadOffTimer == 0) {
        leadOffTimer = millis();  // Bắt đầu đếm
    }
    
    // Tuột dây quá 2s → Dừng đo
    if (millis() - leadOffTimer > 2000) {
        Serial.println(">>> Lead off > 2s → STOP");
        isMeasuring = false;
        ecgIndex = 0;
        leadOffTimer = 0;
    }
} else {
    // Dây ổn định lại → Reset timer
    if (leadOffTimer > 0) {
        leadOffTimer = 0;
    }
}
```

#### 4.2.4 MQTT Publish
```json
{
  "device_id": "ESP32",
  "packet_id": 0,
  "userID": 10,
  "dataPoints": [2048, 2050, 2045, ..., 2100]  // 100 values
}
```

**Topic**: `device/ecg_data`

---

## 5. MQTT PROTOCOL

### 5.1 Broker Configuration

```cpp
// HiveMQ Cloud
const char *mqtt_broker = "7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud";
const int mqtt_port = 8883;        // TLS/SSL
const char *mqtt_user = "DoAn1";
const char *mqtt_pass = "Th123321";

WiFiClientSecure espClient;
PubSubClient client(espClient);

// Setup
espClient.setInsecure();  // Skip certificate verification
client.setServer(mqtt_broker, mqtt_port);
client.setBufferSize(4096);  // Tăng buffer cho JSON lớn
client.setKeepAlive(60);     // 60s keepalive
```

### 5.2 Connection & Reconnect

```cpp
void forceReconnect() {
    Serial.print("Connecting to MQTT...");
    
    String clientId = "ESP32-" + String(random(0xffff), HEX);
    
    if (client.connect(clientId.c_str(), mqtt_user, mqtt_pass)) {
        Serial.println("connected!");
        
        // Subscribe to control topic
        String controlTopic = "iot/control/" + String(DEFAULT_USER_ID);
        client.subscribe(controlTopic.c_str());
    } else {
        Serial.print("failed, rc=");
        Serial.println(client.state());
    }
}
```

### 5.3 Topics

| Topic | Type | QoS | Payload |
|-------|------|-----|---------|
| `iot/vital/{userId}` | Publish | 1 | Vital signs JSON |
| `device/ecg_data` | Publish | 1 | ECG batch JSON |
| `iot/control/{userId}` | Subscribe | 1 | Control commands |

### 5.4 QoS Level

**QoS 1 (At least once)**:
- Đảm bảo message được gửi ít nhất 1 lần
- Có thể bị duplicate (backend phải xử lý)
- Phù hợp cho dữ liệu sức khỏe

---

## 6. WIFI CONFIGURATION

### 6.1 Web Portal Setup

#### 6.1.1 Trigger Config Mode
```cpp
// Nhấn giữ button 3 giây
void checkPhysicalButton() {
    bool current = digitalRead(BUTTON_PIN);
    
    if (current == LOW && btnState == HIGH) {
        btnPressStart = millis();
    }
    
    if (current == LOW && (millis() - btnPressStart > 3000)) {
        enterConfigMode();
    }
    
    btnState = current;
}
```

#### 6.1.2 Access Point Mode
```cpp
void enterConfigMode() {
    Serial.println(">>> ENTER CONFIG MODE");
    isConfigMode = true;
    
    // Tạo Access Point
    WiFi.softAP("ESP32_Config", "12345678");
    IPAddress IP = WiFi.softAPIP();
    
    Serial.print("AP IP: ");
    Serial.println(IP);  // 192.168.4.1
    
    // Start web server
    server.on("/", handleRoot);
    server.on("/scan", handleScan);
    server.on("/save", handleSave);
    server.begin();
}
```

#### 6.1.3 Web Interface
```html
<!-- Web portal tại 192.168.4.1 -->
<!DOCTYPE html>
<html>
<head>
    <title>ESP32 WiFi Config</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
    <h1>ESP32 WiFi Configuration</h1>
    
    <button onclick="scanWiFi()">Scan WiFi</button>
    <div id="networks"></div>
    
    <form action="/save" method="POST">
        <label>SSID:</label>
        <input type="text" name="ssid" id="ssid">
        
        <label>Password:</label>
        <input type="password" name="password">
        
        <button type="submit">Save & Reboot</button>
    </form>
    
    <script>
        function scanWiFi() {
            fetch('/scan')
                .then(r => r.text())
                .then(networks => {
                    document.getElementById('networks').innerHTML = networks;
                });
        }
    </script>
</body>
</html>
```

### 6.2 EEPROM Storage

```cpp
// Lưu WiFi credentials
void saveWiFiToEEPROM(String ssid, String password) {
    // SSID (address 0-63)
    EEPROM.write(0, ssid.length());
    for (int i = 0; i < ssid.length(); i++) {
        EEPROM.write(1 + i, ssid[i]);
    }
    
    // Password (address 64-127)
    EEPROM.write(64, password.length());
    for (int i = 0; i < password.length(); i++) {
        EEPROM.write(65 + i, password[i]);
    }
    
    EEPROM.commit();
}

// Đọc WiFi credentials
void loadWiFiFromEEPROM() {
    byte lenSSID = EEPROM.read(0);
    byte lenPASS = EEPROM.read(64);
    
    if (lenSSID > 0 && lenSSID < 64) {
        ssid = "";
        for (int i = 0; i < lenSSID; i++) {
            ssid += (char)EEPROM.read(1 + i);
        }
        
        password = "";
        for (int i = 0; i < lenPASS; i++) {
            password += (char)EEPROM.read(65 + i);
        }
    }
}
```

---

## 7. XỬ LÝ TÍN HIỆU

### 7.1 ECG Signal Processing

#### 7.1.1 Signal Chain
```
RAW ADC → High-Pass → Low-Pass → Gain → Clamp → Output
(0-4095)    (DC Removal)  (Smoothing)  (6.0x)  (0-4095)
```

#### 7.1.2 Processing Code
```cpp
// Tham số
const float DIGITAL_GAIN = 6.0;     // Khuếch đại 6 lần
const float FILTER_ALPHA = 0.2;     // Hệ số lọc LP

float ecgBaseline = 0.0;            // Baseline HP filter
float ecgFiltered = 0.0;            // Output LP filter

int processEcgSample(int raw) {
    // 1. Khởi tạo baseline
    if (ecgBaseline == 0.0f) {
        ecgBaseline = raw;
    }
    
    // 2. High-pass filter (DC removal)
    // y[n] = 0.995 * y[n-1] + 0.005 * x[n]
    ecgBaseline = (0.995f * ecgBaseline) + (0.005f * raw);
    float hp = raw - ecgBaseline;
    
    // 3. Low-pass filter (Smoothing)
    // y[n] = α * x[n] + (1-α) * y[n-1]
    ecgFiltered = (FILTER_ALPHA * hp) + 
                  ((1.0 - FILTER_ALPHA) * ecgFiltered);
    
    // 4. Gain amplification
    float amplified = ecgFiltered * DIGITAL_GAIN;
    
    // 5. Shift to center (2048)
    int out = (int)amplified + 2048;
    
    // 6. Clamp (0-4095)
    if (out < 0) out = 0;
    if (out > 4095) out = 4095;
    
    return out;
}
```

#### 7.1.3 Noise Rejection (Flatline Detection)
```cpp
void sendECGBatch() {
    StaticJsonDocument<3072> doc;
    
    // ... tạo JSON ...
    
    int flatlineCount = 0;
    for (int i = 1; i < ECG_BATCH_SIZE; i++) {
        if (ecgBuffer[i] == ecgBuffer[i-1]) {
            flatlineCount++;
        }
    }
    
    // Nếu > 50% mẫu bị trùng → Nhiễu bậc thang
    if (flatlineCount > (ECG_BATCH_SIZE / 2)) {
        Serial.println(">>> FLATLINE DETECTED → SKIP");
        return;  // Không publish
    }
    
    client.publish("device/ecg_data", buffer);
}
```

### 7.2 Temperature Calibration

```cpp
// Công thức hiệu chỉnh nhiệt độ lâm sàng
float getClinicalTemperature(float objTemp, float ambTemp) {
    // Offset dựa trên môi trường
    float offset = (ambTemp < 25) ? 1.5 : 
                   (ambTemp < 30) ? 1.0 : 0.5;
    
    float clinical = objTemp + offset;
    
    // EMA filter
    if (filteredTemp == 0) {
        filteredTemp = clinical;
    } else {
        filteredTemp = (EMA_ALPHA * clinical) + 
                       ((1.0 - EMA_ALPHA) * filteredTemp);
    }
    
    return filteredTemp;
}
```

---

## 8. API REFERENCE

### 8.1 Main Functions

#### 8.1.1 Setup
```cpp
void setup()
```
- Khởi tạo Serial, GPIO, I2C
- Load WiFi từ EEPROM
- Kết nối WiFi
- Init MQTT client

#### 8.1.2 Loop
```cpp
void loop()
```
- Main loop xử lý state machine
- Button check, MQTT reconnect
- Sampling logic

### 8.2 Measurement Functions

#### 8.2.1 Calculate Health Data
```cpp
void calculateHealthData(int count)
```
- Tính HR, SpO2 từ buffer
- Smooth filter
- Update finals

#### 8.2.2 Send Final Result
```cpp
void sendFinalResult()
```
- Tạo JSON vital signs
- Publish MQTT

#### 8.2.3 Send ECG Batch
```cpp
void sendECGBatch()
```
- Tạo JSON ECG data
- Flatline detection
- Publish MQTT

### 8.3 Signal Processing

#### 8.3.1 Process ECG Sample
```cpp
int processEcgSample(int raw)
```
**Input**: Raw ADC value (0-4095)  
**Output**: Processed value (0-4095)  
**Filters**: HP → LP → Gain → Clamp

### 8.4 WiFi Functions

#### 8.4.1 Enter Config Mode
```cpp
void enterConfigMode()
```
- Start AP mode
- Launch web server

#### 8.4.2 Handle Scan
```cpp
void handleScan()
```
- Scan available WiFi networks
- Return JSON list

#### 8.4.3 Handle Save
```cpp
void handleSave()
```
- Save WiFi credentials to EEPROM
- Reboot ESP32

---

## 9. BUILD & FLASH

### 9.1 PlatformIO Configuration

```ini
; platformio.ini
[env:esp32dev]
platform = espressif32
board = esp32dev
framework = arduino
monitor_speed = 115200
lib_ldf_mode = deep+

lib_deps =
    knolleary/PubSubClient @ ^2.8
    bblanchon/ArduinoJson @ ^6.21.3
    adafruit/Adafruit MLX90614 Library @ ^2.1.3
    sparkfun/SparkFun MAX3010x Pulse and Proximity Sensor Library @ ^1.1.2
```

### 9.2 Build Commands

```bash
# Build
pio run

# Upload
pio run -t upload

# Monitor serial
pio device monitor

# Clean
pio run -t clean
```

### 9.3 Serial Monitor Output

```
Connecting to WiFi...
WiFi connected! IP: 192.168.1.100
Connecting to MQTT...connected!

>>> BAT DAU DO ECG...

========== [SENT DATA] ==========
Packet ID : 0
Amp       : 350
=================================

========== [SENT DATA] ==========
Packet ID : 1
Amp       : 380
=================================

>>> PHAT HIEN DEO DAY -> BAT DAU DO ECG...
>>> XAC NHAN: TUOT DAY QUA 2 GIAY -> DUNG DO!
```

---

## 10. TROUBLESHOOTING

### 10.1 WiFi Issues

**Không kết nối được WiFi**:
```cpp
// Solution: Check credentials
Serial.println(ssid);
Serial.println(password);

// Hoặc vào Config Mode để setup lại
```

**WiFi bị mất kết nối**:
```cpp
// ESP32 tự động reconnect với:
WiFi.setAutoReconnect(true);
```

### 10.2 MQTT Issues

**MQTT không connect**:
```cpp
// Check return code
if (!client.connect(...)) {
    Serial.print("Failed, rc=");
    Serial.println(client.state());
    
    // rc = -2: Network failed
    // rc = -4: Timeout
    // rc = 5: Authentication failed
}
```

**Message quá lớn**:
```cpp
// Tăng buffer size
client.setBufferSize(4096);  // Default: 256
```

### 10.3 Sensor Issues

**MAX30102 không phát hiện**:
```cpp
// Check I2C connection
Wire.begin();
Wire.setClock(50000);  // Giảm tốc độ I2C

// Check address
// MAX30102: 0x57
// MLX90614: 0x5A
```

**ECG bị nhiễu**:
```cpp
// Tăng DIGITAL_GAIN nếu sóng quá thấp
const float DIGITAL_GAIN = 6.0;  // Thử 8.0 hoặc 10.0

// Giảm FILTER_ALPHA để lọc mượt hơn
const float FILTER_ALPHA = 0.1;  // Default: 0.2
```

**Flatline liên tục**:
```cpp
// Kiểm tra dây điện cực
// - Đảm bảo dán chặt
// - Làm ướt vùng da
// - Thay dây mới nếu bị hỏng
```

---

**✅ Hoàn thành tài liệu ESP32 Firmware!**
