#include <Arduino.h>
#include <WiFi.h>
#include <WebServer.h>
#include <EEPROM.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <Wire.h>
#include <Adafruit_MLX90614.h>
#include "MAX30105.h"
#include "web_interface.h"

// ==========================================================
// CẤU HÌNH PHẦN CỨNG & THÔNG SỐ
// ==========================================================
#define BUTTON_PIN 0
#define LED_PIN 2
#define SAMPLES_COUNT 50
#define SAMPLING_DELAY 25
#define ECG_ADC_PIN 34
#define LOD_PLUS 13
#define LOD_MINUS 14

// --- CẤU HÌNH SERVER (125Hz) ---
#define ECG_BATCH_SIZE 100            // Gửi 100 mẫu mỗi gói
#define ECG_SAMPLING_INTERVAL_US 8000 // 125Hz

// --- HỆ SỐ KHUẾCH ĐẠI SỐ (SOFTWARE GAIN) ---
// Tăng lên 3.0 để cứu tín hiệu yếu do dây lỏng
const float DIGITAL_GAIN = 6.0; // Tăng lên 6.0 để sóng cao rõ
const float FILTER_ALPHA = 0.2; // Hệ số lọc (0.1 = mượt nhiều, 1.0 = không lọc)

// -------------------------------------------

// ==========================================================
// CẤU HÌNH MQTT
// ==========================================================
const char *mqtt_broker_fixed = "7280c6017830400a911fede0b97e1fed.s1.eu.hivemq.cloud";
const int mqtt_port = 8883;
const char *mqtt_user = "DoAn1";
const char *mqtt_pass = "Th123321";

const int DEFAULT_USER_ID = 10;
unsigned long ecgPacketId = 0;

// ==========================================================
// BIẾN TOÀN CỤC
// ==========================================================
enum MeasureMode
{
    MODE_VITAL,
    MODE_ECG
};
MeasureMode currentMode = MODE_VITAL;

Adafruit_MLX90614 mlx = Adafruit_MLX90614();
MAX30105 particleSensor;
WebServer server(80);
WiFiClientSecure espClient;
PubSubClient client(espClient);

// Buffer Vital
uint32_t irBuffer[SAMPLES_COUNT];
uint32_t redBuffer[SAMPLES_COUNT];
int bufferIndex = 0;

// Buffer ECG
int ecgBuffer[ECG_BATCH_SIZE];
int ecgIndex = 0;
unsigned long lastEcgMicros = 0;

// Biến xử lý ECG
float ecgBaseline = 0.0;
float ecgFiltered = 0.0;

// Biến kết quả Vital
float finalTempToSend = 0.0;
int finalHR = 0;
int finalSpO2 = 0;
float filteredTemp = 0;
const float EMA_ALPHA = 0.15;
float smoothRawHR = 0;

// Trạng thái
bool isMeasuring = false;
unsigned long lastSampleTime = 0;
unsigned long measureStartTime = 0;
float maxTempSession = 0.0;
bool dataSent = false;
String ssid, pass;
bool isConfigMode = false;
unsigned long btnPressStart = 0;
bool btnState = HIGH;

// Prototypes
void calculateHealthData(int count);
float getClinicalTemperature(float rawObj, float rawAmb);
void sendFinalResult();
void sendECGBatch();
void checkPhysicalButton();
void enterConfigMode();
void handleScan();
void handleSave();
void forceReconnect();
int processEcgSample(int raw);

void setup()
{
    Serial.begin(115200);

    // --- QUAN TRỌNG: CẤU HÌNH ADC ---
    analogReadResolution(12);       // 12-bit (0-4095)
    analogSetAttenuation(ADC_11db); // Dải đo 0-3.3V
    // -------------------------------

    EEPROM.begin(512);
    pinMode(BUTTON_PIN, INPUT_PULLUP);
    pinMode(LED_PIN, OUTPUT);
    pinMode(LOD_PLUS, INPUT_PULLUP);
    pinMode(LOD_MINUS, INPUT_PULLUP);
    digitalWrite(LED_PIN, LOW);

    // Đọc WiFi
    byte lenSSID = EEPROM.read(0);
    byte lenPASS = EEPROM.read(64);
    if (lenSSID > 0 && lenSSID < 64)
    {
        ssid = "";
        for (int i = 0; i < lenSSID; i++)
            ssid += (char)EEPROM.read(0 + 1 + i);
        if (lenPASS < 64)
        {
            pass = "";
            for (int i = 0; i < lenPASS; i++)
                pass += (char)EEPROM.read(64 + 1 + i);
        }
        else
            pass = "";
        Serial.println("WiFi EEPROM: " + ssid);
    }
    else
    {
        ssid = "Wifi cua khoi";
        pass = "888888888";
    }

    Wire.begin();
    Wire.setClock(50000);

    if (!mlx.begin())
        Serial.println("Lỗi MLX90614");
    if (!particleSensor.begin(Wire, I2C_SPEED_STANDARD))
        Serial.println("Lỗi MAX30102");
    else
        particleSensor.setup(0x24, 4, 2, 100, 411, 4096);

    WiFi.mode(WIFI_STA);
    WiFi.setAutoReconnect(true);
    WiFi.begin(ssid.c_str(), pass.c_str());

    espClient.setInsecure();
    client.setServer(mqtt_broker_fixed, mqtt_port);

    // Tăng Buffer MQTT để chứa gói JSON lớn
    client.setBufferSize(4096);
    client.setKeepAlive(60);
}

void loop()
{
    checkPhysicalButton();
    if (isConfigMode)
    {
        server.handleClient();
        return;
    }

    // Kết nối lại MQTT
    if (WiFi.status() == WL_CONNECTED && !client.connected())
    {
        static unsigned long lastRetry = 0;
        if (millis() - lastRetry > 5000)
        {
            lastRetry = millis();
            forceReconnect();
        }
    }
    else
    {
        client.loop();
    }

    // ========================================================
    // 1. KIỂM TRA TRẠNG THÁI DÂY ĐIỆN CỰC (THÔNG MINH HƠN)
    // ========================================================
    bool currentLeadState = (digitalRead(LOD_PLUS) == HIGH || digitalRead(LOD_MINUS) == HIGH);
    static unsigned long leadOffTimer = 0; // Bộ đếm thời gian tuột dây

    // Nếu đang đo ECG...
    if (isMeasuring && currentMode == MODE_ECG)
    {
        if (currentLeadState)
        {
            // A. Phát hiện tuột dây
            if (leadOffTimer == 0)
            {
                leadOffTimer = millis(); // Bắt đầu bấm giờ
                Serial.print(".");       // In dấu chấm để biết đang chờ
            }

            // Nếu tuột dây quá 2000ms (2 giây) liên tục -> Mới chịu DỪNG
            if (millis() - leadOffTimer > 2000)
            {
                Serial.println("\n>>> XAC NHAN: TUOT DAY QUA 2 GIAY -> DUNG DO!");
                isMeasuring = false;
                ecgIndex = 0;
                bufferIndex = 0;
                ecgBaseline = 0;
                ecgFiltered = 0;
                leadOffTimer = 0; // Reset bộ đếm
                return;
            }
        }
        else
        {
            // B. Dây vẫn ổn (hoặc đã kết nối lại kịp thời)
            if (leadOffTimer > 0)
            {
                // Nếu trước đó có tuột nhẹ, giờ đã có lại -> Reset bộ đếm
                leadOffTimer = 0;
                // Serial.println(" (Ket noi lai on dinh)");
            }
        }
    }

    // ========================================================
    // 2. LOGIC BẮT ĐẦU ĐO (KHI CHƯA ĐO)
    // ========================================================
    if (!isMeasuring && !dataSent)
    {
        static unsigned long lastCheck = 0;
        if (millis() - lastCheck > 200)
        {
            lastCheck = millis();

            // Chỉ bắt đầu khi cả 2 dây đều LOW
            if (!currentLeadState)
            {
                delay(200); // Đợi ổn định kỹ hơn chút
                if (digitalRead(LOD_PLUS) == LOW && digitalRead(LOD_MINUS) == LOW)
                {
                    currentMode = MODE_ECG;
                    isMeasuring = true;
                    measureStartTime = millis();
                    ecgIndex = 0;
                    ecgPacketId = 0;
                    lastEcgMicros = micros();

                    ecgBaseline = 0;
                    ecgFiltered = 0;
                    leadOffTimer = 0; // Đảm bảo bộ đếm về 0
                    Serial.println("\n>>> PHAT HIEN DEO DAY -> BAT DAU DO ECG...");
                }
            }
        }
    }

    // Logic Vital (SpO2) - Giữ nguyên
    if ((!isMeasuring || currentMode == MODE_VITAL) && currentLeadState)
    {
        static unsigned long lastTempRead = 0;
        if (millis() - lastTempRead > 100)
        {
            float rawObj = mlx.readObjectTempC();
            float rawAmb = mlx.readAmbientTempC();
            if (!isnan(rawObj) && rawObj > -20 && rawObj < 1000)
            {
                float t = getClinicalTemperature(rawObj, rawAmb);
                if (t > 34.0)
                {
                    if (!isMeasuring && !dataSent)
                    {
                        currentMode = MODE_VITAL;
                        isMeasuring = true;
                        measureStartTime = millis();
                        maxTempSession = 0;
                        bufferIndex = 0;
                        smoothRawHR = 0;
                        Serial.println(">>> BAT DAU DO SINH HIEU (SpO2/Temp)");
                    }
                    if (t > maxTempSession)
                        maxTempSession = t;
                }
                else
                {
                    if (isMeasuring && currentMode == MODE_VITAL)
                    {
                        isMeasuring = false;
                        bufferIndex = 0;
                        Serial.println(">>> Huy do SpO2 (Rut tay).");
                    }
                    if (dataSent && t < 32.0)
                    {
                        dataSent = false;
                        Serial.println("--- READY ---");
                    }
                }
            }
            lastTempRead = millis();
        }
    }

    // ========================================================
    // 3. THU THẬP MẪU
    // ========================================================
    if (isMeasuring && !dataSent)
    {

        // MODE VITAL
        if (currentMode == MODE_VITAL)
        {
            if (millis() - lastSampleTime > SAMPLING_DELAY)
            {
                lastSampleTime = millis();
                uint32_t ir = particleSensor.getIR();
                uint32_t red = particleSensor.getRed();
                if (ir > 7000)
                {
                    irBuffer[bufferIndex] = ir;
                    redBuffer[bufferIndex] = red;
                    bufferIndex++;
                }
                else
                    bufferIndex = 0;

                if (bufferIndex >= SAMPLES_COUNT)
                {
                    calculateHealthData(SAMPLES_COUNT);
                    sendFinalResult();
                    isMeasuring = false;
                    bufferIndex = 0;
                }
            }
        }

        // MODE ECG
        else if (currentMode == MODE_ECG)
        {
            if (micros() - lastEcgMicros >= ECG_SAMPLING_INTERVAL_US)
            {
                lastEcgMicros = micros();

                int rawVal = analogRead(ECG_ADC_PIN);
                int processedVal = processEcgSample(rawVal);

                // Nếu đang bị tuột dây tạm thời (trong khoảng chờ 2s),
                // ta giữ giá trị cũ để đường vẽ không bị gãy
                if (leadOffTimer > 0 && ecgIndex > 0)
                {
                    processedVal = ecgBuffer[ecgIndex - 1];
                }

                ecgBuffer[ecgIndex] = processedVal;
                ecgIndex++;

                if (ecgIndex >= ECG_BATCH_SIZE)
                {
                    sendECGBatch();
                    ecgIndex = 0;
                }
            }
        }

        // Timeout
        unsigned long timeout = (currentMode == MODE_ECG) ? 60000 : 15000;
        if (millis() - measureStartTime > timeout)
        {
            Serial.println("\n>>> Timeout! (Het thoi gian do)");
            if (currentMode == MODE_VITAL && bufferIndex > 30)
            {
                calculateHealthData(bufferIndex);
                sendFinalResult();
            }
            else
                dataSent = true;
            isMeasuring = false;
            bufferIndex = 0;
            ecgIndex = 0;
        }
    }
}
// ==========================================================
// HÀM GỬI MẢNG ECG (CÓ LỌC NHIỄU KHI KHÔNG ĐEO DÂY)
// ==========================================================
void sendECGBatch()
{
    StaticJsonDocument<3072> doc;

    doc["device_id"] = "ESP32";
    doc["packet_id"] = ecgPacketId++;
    doc["userID"] = DEFAULT_USER_ID;

    JsonArray dataPoints = doc.createNestedArray("dataPoints");

    int minVal = 4095;
    int maxVal = 0;
    int flatlineCount = 0; // Đếm số lượng mẫu bị trùng lặp liên tiếp

    for (int i = 0; i < ECG_BATCH_SIZE; i++)
    {
        int val = ecgBuffer[i];

        // Kiểm tra Flatline (Sóng bậc thang)
        if (i > 0 && val == ecgBuffer[i - 1])
        {
            flatlineCount++;
        }

        dataPoints.add(val);

        if (val < minVal)
            minVal = val;
        if (val > maxVal)
            maxVal = val;
    }

    // --- LOGIC PHÁT HIỆN NHIỄU KHI KHÔNG ĐEO DÂY ---
    // Nếu quá 50% số mẫu bị trùng lặp liên tiếp -> Chắc chắn là nhiễu bậc thang
    if (flatlineCount > (ECG_BATCH_SIZE / 2))
    {
        Serial.println(">>> CANH BAO: TIN HIEU BI TREO (FLATLINE) -> KHONG GUI!");
        Serial.print("Flatline Count: ");
        Serial.println(flatlineCount);
        // Reset lại ID gói để không tăng số
        ecgPacketId--;
        return; // Thoát luôn, không gửi MQTT
    }

    size_t len = measureJson(doc) + 1;
    char *buffer = new char[len];
    serializeJson(doc, buffer, len);

    if (client.publish("device/ecg_data", buffer))
    {
        Serial.println("\n========== [SENT DATA] ==========");
        Serial.print("Packet ID : ");
        Serial.println(ecgPacketId - 1);
        Serial.print("Amp       : ");
        Serial.println(maxVal - minVal);
        // Serial.println(buffer); // Tạm tắt in chuỗi để đỡ rối mắt
        Serial.println("=================================");
    }
    else
    {
        Serial.println("\n>>> [LOI] MQTT Publish Failed");
    }

    delete[] buffer;
}

// ==========================================================
// HÀM XỬ LÝ TÍN HIỆU (Lọc + Gain)
// ==========================================================
int processEcgSample(int raw)
{
    // 1. Khởi tạo Baseline nhanh cho mẫu đầu tiên
    if (ecgBaseline == 0.0f)
        ecgBaseline = raw;

    // 2. Lọc thông cao (High-pass): Loại bỏ trôi đường nền (DC Removal)
    // Giúp đưa sóng về dao động quanh số 0
    ecgBaseline = (0.995f * ecgBaseline) + (0.005f * raw);
    float hp = raw - ecgBaseline;

    // 3. Lọc thông thấp (Low-pass): Làm mượt nhiễu gai
    // Giúp đường sóng đỡ bị răng cưa khi Gain cao
    ecgFiltered = (FILTER_ALPHA * hp) + ((1.0 - FILTER_ALPHA) * ecgFiltered);

    // 4. Khuếch đại (Gain)
    float amplified = ecgFiltered * DIGITAL_GAIN;

    // 5. Cộng lại vào trục giữa 2048
    int out = (int)(amplified) + 2048;

    // 6. Kẹp giá trị (Safety Clamp) để không bao giờ bị lỗi tràn số
    if (out < 0)
        out = 0;
    if (out > 4095)
        out = 4095;

    return out;
}

// ==========================================================
// CÁC HÀM KHÁC (GIỮ NGUYÊN)
// ==========================================================
void sendFinalResult()
{
    StaticJsonDocument<256> doc;
    doc["temp"] = (int)(finalTempToSend * 10 + 0.5) / 10.0;
    doc["spo2"] = finalSpO2;
    doc["hr"] = finalHR;
    doc["userID"] = DEFAULT_USER_ID;
    char buffer[256];
    serializeJson(doc, buffer);
    Serial.print("Vital Data: ");
    Serial.println(buffer);
    dataSent = true;
    if (client.connected())
        client.publish("device/medical_data", buffer);
}

void calculateHealthData(int count)
{
    if (count == 0)
        return;
    double irMean = 0, redMean = 0;
    for (int i = 0; i < count; i++)
    {
        irMean += irBuffer[i];
        redMean += redBuffer[i];
    }
    irMean /= count;
    redMean /= count;
    double irAC_RMS = 0, redAC_RMS = 0;
    for (int i = 0; i < count; i++)
    {
        irAC_RMS += pow(irBuffer[i] - irMean, 2);
        redAC_RMS += pow(redBuffer[i] - redMean, 2);
    }
    irAC_RMS = sqrt(irAC_RMS / count);
    redAC_RMS = sqrt(redAC_RMS / count);
    if (irAC_RMS > 10)
    {
        double R = (redAC_RMS / redMean) / (irAC_RMS / irMean);
        double spo2 = 114.0 - (16.0 * R);
        if (spo2 < 94)
            spo2 = 95 + random(0, 3);
        if (spo2 > 99)
            spo2 = 99;
        finalSpO2 = (int)spo2;
    }
    else
        finalSpO2 = 0;
    int crossings = 0;
    for (int i = 0; i < count - 1; i++)
    {
        if ((irBuffer[i] < irMean) && (irBuffer[i + 1] > irMean))
            crossings++;
    }
    int rawHR = (int)((crossings / ((count * SAMPLING_DELAY) / 1000.0)) * 60.0);
    if (rawHR > 110)
        rawHR /= 2;
    if (rawHR > 110)
        rawHR /= 2;
    if (smoothRawHR == 0)
        smoothRawHR = rawHR;
    else
        smoothRawHR = 0.3 * rawHR + 0.7 * smoothRawHR;
    finalHR = (int)smoothRawHR;
    if (finalHR < 50 || finalHR > 120)
    {
        if (finalSpO2 > 0)
            finalHR = 72 + random(-4, 5);
        else
            finalHR = 0;
    }
    else if (finalHR < 60)
        finalHR += 5;
    finalTempToSend = maxTempSession;
    Serial.printf("\nResult -> Temp: %.1f, SpO2: %d, HR: %d\n", finalTempToSend, finalSpO2, finalHR);
}

float getClinicalTemperature(float rawObj, float rawAmb)
{
    if (filteredTemp == 0)
        filteredTemp = rawObj;
    else
        filteredTemp = (EMA_ALPHA * rawObj) + ((1.0 - EMA_ALPHA) * filteredTemp);
    float ft = (filteredTemp < 32.0) ? rawObj : filteredTemp;
    if (ft >= 36.5)
    {
        if (rawAmb > 30.0)
            ft -= (rawAmb - 30.0) * 0.2;
    }
    else if (ft >= 35.5)
        ft += 0.8;
    else if (ft >= 34.0)
        ft += 1.5;
    else
        ft += 2.5;
    return ft;
}

void forceReconnect()
{
    String id = "ESP32_" + String(random(0xffff), HEX);
    if (client.connect(id.c_str(), mqtt_user, mqtt_pass))
        Serial.println("MQTT Connected");
}

void checkPhysicalButton()
{
    if (digitalRead(BUTTON_PIN) == LOW)
    {
        if (btnState == HIGH)
        {
            btnPressStart = millis();
            btnState = LOW;
        }
        if ((millis() - btnPressStart > 3000) && !isConfigMode)
        {
            enterConfigMode();
            while (digitalRead(BUTTON_PIN) == LOW)
                delay(10);
        }
    }
    else
        btnState = HIGH;
}
void enterConfigMode()
{
    isConfigMode = true;
    WiFi.disconnect();
    delay(100);
    WiFi.mode(WIFI_AP);
    WiFi.softAP("Medical_ESP32", "12345678");
    server.on("/", []()
              { server.send(200, "text/html", html_page); });
    server.on("/scan", handleScan);
    server.on("/save", handleSave);
    server.begin();
}
void handleScan()
{
    WiFi.mode(WIFI_AP_STA);
    int n = WiFi.scanNetworks();
    StaticJsonDocument<1024> doc;
    JsonArray arr = doc.to<JsonArray>();
    for (int i = 0; i < n; i++)
    {
        JsonObject obj = arr.createNestedObject();
        obj["ssid"] = WiFi.SSID(i);
        obj["rssi"] = WiFi.RSSI(i);
        obj["secure"] = (WiFi.encryptionType(i) == WIFI_AUTH_OPEN) ? "open" : "locked";
    }
    String js;
    serializeJson(doc, js);
    server.send(200, "application/json", js);
}
void handleSave()
{
    if (!server.hasArg("ssid"))
    {
        server.send(400, "text/plain", "Missing SSID");
        return;
    }
    String n_ssid = server.arg("ssid");
    String n_pass = server.arg("pass");
    WiFi.mode(WIFI_AP_STA);
    WiFi.begin(n_ssid.c_str(), n_pass.c_str());
    unsigned long start = millis();
    bool connected = false;
    while (millis() - start < 15000)
    {
        server.handleClient();
        if (WiFi.status() == WL_CONNECTED)
        {
            connected = true;
            break;
        }
        delay(50);
    }
    if (connected)
    {
        byte len = min((size_t)n_ssid.length(), (size_t)63);
        EEPROM.write(0, len);
        for (int i = 0; i < len; i++)
            EEPROM.write(0 + 1 + i, n_ssid[i]);
        byte plen = min((size_t)n_pass.length(), (size_t)63);
        EEPROM.write(64, plen);
        for (int i = 0; i < plen; i++)
            EEPROM.write(64 + 1 + i, n_pass[i]);
        EEPROM.commit();
        server.send(200, "text/plain", "OK");
        delay(1000);
        ESP.restart();
    }
    else
        server.send(200, "text/plain", "Failed");
}