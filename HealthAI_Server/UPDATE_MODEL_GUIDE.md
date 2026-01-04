# 🔄 HƯỚNG DẪN CẬP NHẬT MODEL MỚI

## Khi train xong, làm theo các bước sau:

### 📥 BƯỚC 1: DOWNLOAD FILES TỪ COLAB/KAGGLE

Sau khi chạy xong Cell 8 trong notebook `BMP_SPO2_TEMP.ipynb`, download 3 items:

```
✅ Cần download:
1. Folder: tfjs_mlp_model/
   - model.json
   - group1-shard1of1.bin (hoặc nhiều shard)
   
2. File: scaler_mlp.json
3. File: risk_encoder.json
```

---

### 🔄 BƯỚC 2: THAY THẾ FILES TRÊN SERVER

**Copy đè lên thư mục:**
```
E:\Fluter\HealthAI_Server\models\
```

**Chi tiết:**
1. **Xóa folder cũ**: `tfjs_mlp_model/`
2. **Copy folder mới**: `tfjs_mlp_model/` (từ download)
3. **Đè file**: `scaler_mlp.json`
4. **Đè file**: `risk_encoder.json`

---

### ✅ BƯỚC 3: KIỂM TRA SỐ FEATURES

**QUAN TRỌNG**: Xác nhận model mới dùng bao nhiêu features!

Chạy lệnh này để kiểm tra:

```powershell
cd e:\Fluter\HealthAI_Server\models
node -e "const scaler = require('./scaler_mlp.json'); console.log('Number of features:', scaler.mean.length); console.log('Features:', scaler.mean.length);"
```

**Nếu kết quả = 9 features** (đã thêm Gender_encoded):
- Phải sửa backend để gửi 9 features thay vì 8
- Xem BƯỚC 4 bên dưới

**Nếu kết quả = 8 features** (giữ nguyên):
- Không cần sửa code backend
- Skip BƯỚC 4, nhảy thẳng BƯỚC 5

---

### 🔧 BƯỚC 4: CẬP NHẬT BACKEND (NẾU DÙNG 9 FEATURES)

**Sửa file:** `e:\Fluter\HealthAI_Server\services\predict_service.js`

**Tìm dòng ~85-95** (inputRaw array) và thêm `gender_encoded` vào cuối:

```javascript
// TRƯỚC (8 features):
const inputRaw = [
    spo2,           // Oxygen Saturation
    temperature,    // Body Temperature
    heart_rate,     // Heart Rate
    derived_map,    // Derived_MAP
    age,            // Age
    weight_kg,      // Weight (kg)
    height_m,       // Height (m)
    derived_bmi     // Derived_BMI
];

// SAU (9 features):
const inputRaw = [
    spo2,           // Oxygen Saturation
    temperature,    // Body Temperature
    heart_rate,     // Heart Rate
    derived_map,    // Derived_MAP
    age,            // Age
    weight_kg,      // Weight (kg)
    height_m,       // Height (m)
    derived_bmi,    // Derived_BMI
    gender_encoded  // Gender_encoded (ĐÃ THÊM)
];
```

**Và sửa shape của tensor:**
```javascript
// Đổi từ:
const inputTensor = tf.tensor2d([inputScaled], [1, 8]);

// Thành:
const inputTensor = tf.tensor2d([inputScaled], [1, 9]);
```

---

### 🔄 BƯỚC 5: RESTART SERVER

**Stop server hiện tại** (nếu đang chạy):
```powershell
# Trong terminal đang chạy server, nhấn Ctrl+C
```

**Start lại server:**
```powershell
cd e:\Fluter\HealthAI_Server
npm start
```

**Xem log khởi động**, phải có dòng:
```
✅ TensorFlow.js backend: tensorflow
Đang tải mô hình và scalers...
Tải MLP model thành công.
```

---

### 🧪 BƯỚC 6: TEST MODEL MỚI

Chạy script test:

```powershell
cd e:\Fluter\HealthAI_Server
node test_ai_diagnosis.js
```

**Kỳ vọng kết quả tốt hơn:**
- Case 1 (bình thường) → Low Risk
- Case 2, 3, 4 (bất thường) → High Risk
- Confidence không phải 100% (khoảng 70-95%)
- Severity phân loại đúng (NORMAL/WARNING/DANGER)

---

### 🐛 TROUBLESHOOTING

**Nếu lỗi "expected shape [null,X] but got array with shape [1,Y]":**
- Model mới có X features
- Backend đang gửi Y features
- Quay lại BƯỚC 3-4 để sửa số features cho khớp

**Nếu server không start:**
```powershell
# Kiểm tra file model.json có hợp lệ không
cd e:\Fluter\HealthAI_Server\models\tfjs_mlp_model
Get-Content model.json | ConvertFrom-Json
```

**Nếu vẫn predict 100% High Risk:**
- Model có thể vẫn chưa train tốt
- Kiểm tra Test Accuracy trong notebook (phải > 85%)
- Xem lại Classification Report có balanced không

---

### 📊 BƯỚC 7: CẬP NHẬT CHECK SCRIPT

Cập nhật check_ai_input.js để test với 9 features (nếu cần):

```powershell
cd e:\Fluter\HealthAI_Server
node check_ai_input.js
```

---

## ✅ HOÀN TẤT!

Khi nào train xong, ping tôi và làm theo checklist này. 
Tôi sẽ hỗ trợ nếu gặp vấn đề!
