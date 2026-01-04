// config/aiModels.js
const tf = require('@tensorflow/tfjs-node');
const fs = require('fs').promises;
const path = require('path');

console.log(`TensorFlow.js backend (đã set): ${tf.getBackend()}`);

// Biến này sẽ giữ các model/scaler đã tải
const models = {};

/**
 * Hàm trợ giúp (Cách 10 - Sửa lỗi cấu trúc trả về)
 * Tải và vá lỗi mô hình Keras 3 bằng cách đọc file thủ công.
 *
 * @param {string} modelJsonPath Đường dẫn HỆ THỐNG TỆP (KHÔNG có 'file://')
 * @returns {tf.io.IOHandler} Một IOHandler chứa đầy đủ dữ liệu đã vá lỗi.
 */
const createManualPatchedHandler = async (modelJsonPath) => {
    console.log(`[Manual Handler] Bắt đầu xử lý: ${modelJsonPath}`);
    const modelDir = path.dirname(modelJsonPath);

    try {
        // 1. Tự đọc và parse tệp model.json
        const jsonText = await fs.readFile(modelJsonPath, 'utf8');
        const originalArtifacts = JSON.parse(jsonText);

        // 2. THỰC HIỆN VÁ LỖI TOPOLOGY (Patch 1: batch_shape)
        const topology = originalArtifacts.modelTopology;
        if (!topology || !topology.model_config || !topology.model_config.config) {
            throw new Error("Cấu trúc modelTopology không hợp lệ.");
        }
        const modelConfig = topology.model_config.config;

        if (modelConfig.layers && modelConfig.layers[0]?.config?.batch_shape) {
            console.log(`[Manual Handler] ...Patch 1: Sửa 'batch_shape' -> 'batchInputShape'`);
            const inputLayerConfig = modelConfig.layers[0].config;
            inputLayerConfig.batchInputShape = inputLayerConfig.batch_shape;
            delete inputLayerConfig.batch_shape;
        }

        // 3. XỬ LÝ WEIGHTS MANIFEST (Hỗ trợ nhiều nhóm manifest)
        // Thay vì chỉ lấy [0], ta gộp tất cả các nhóm lại.
        const manifests = originalArtifacts.weightsManifest;
        if (!manifests || !Array.isArray(manifests)) {
            throw new Error("JSON không chứa weightsManifest hợp lệ.");
        }

        let allWeightSpecs = [];
        let allWeightPaths = [];

        // Gom tất cả specs và paths từ mọi manifest entry
        manifests.forEach(group => {
            if (group.weights) allWeightSpecs.push(...group.weights);
            if (group.paths) allWeightPaths.push(...group.paths);
        });

        // === BẢN VÁ 2: Sửa lỗi tiền tố tên trọng số trên danh sách tổng ===
        const modelName = modelConfig.name;
        if (modelName) {
            console.log(`[Manual Handler] ...Patch 2: Chuẩn hóa tên trọng số (Model: ${modelName})`);
            const prefix = modelName + '/';
            let patchedCount = 0;
            for (const spec of allWeightSpecs) {
                if (spec.name.startsWith(prefix)) {
                    spec.name = spec.name.substring(prefix.length);
                    patchedCount++;
                }
            }
            console.log(`[Manual Handler] ...Đã vá ${patchedCount} trọng số.`);
        }

        // 4. TẢI VÀ GHÉP TẤT CẢ CÁC FILE BINARY
        // Chuyển đổi đường dẫn tương đối thành tuyệt đối
        const absoluteWeightPaths = allWeightPaths.map(p => path.join(modelDir, p));
        console.log(`[Manual Handler] ...Đang tải ${absoluteWeightPaths.length} tệp sharded weights...`);

        // Đọc tất cả các file vào bộ nhớ
        const buffers = await Promise.all(absoluteWeightPaths.map(p => fs.readFile(p)));

        // Nối các buffer lại thành một khối duy nhất
        const combinedBuffer = Buffer.concat(buffers);

        // Chuyển đổi Node.js Buffer sang ArrayBuffer (TFJS cần cái này)
        // Lưu ý: Ta copy bộ nhớ để đảm bảo tính an toàn (slice)
        const weightData = combinedBuffer.buffer.slice(
            combinedBuffer.byteOffset,
            combinedBuffer.byteOffset + combinedBuffer.byteLength
        );

        console.log(`[Manual Handler] ...Tổng dung lượng weights: ${(weightData.byteLength / 1024 / 1024).toFixed(2)} MB.`);

        // 5. Trả về IOHandler
        return {
            load: async () => ({
                modelTopology: topology,
                weightSpecs: allWeightSpecs, // Sử dụng danh sách đã gộp và vá tên
                weightData: weightData,

                format: originalArtifacts.format,
                generatedBy: originalArtifacts.generatedBy,
                convertedBy: originalArtifacts.convertedBy,
                trainingConfig: originalArtifacts.trainingConfig,
            })
        };

    } catch (e) {
        console.error(`[Manual Handler] LỖI: ${modelJsonPath}`, e);
        throw e;
    }
};


const loadAllModels = async () => {
    try {
        console.log("Đang tải mô hình và scalers (sử dụng @tensorflow/tfjs-node)...");

        // --- 1. Định nghĩa đường dẫn HỆ THỐNG TỆP (KHÔNG 'file://') ---
        const ecgModelPath = path.join(__dirname, '../models/tfjs_ecg_model/model_ecg.json');
        const mlpModelPath = path.join(__dirname, '../models/tfjs_mlp_model/model_mlp.json');

        // Đường dẫn Scaler
        const scalerEcgPath = path.join(__dirname, '../models/scaler_ecg.json');
        const scalerMlpPath = path.join(__dirname, '../models/scaler_mlp.json');
        const encoderPath = path.join(__dirname, '../models/risk_encoder.json');

        console.log("Đường dẫn model ECG:", ecgModelPath);
        console.log("Đường dẫn model MLP:", mlpModelPath);

        // --- TẢI TUẦN TỰ (Vẫn là cách an toàn nhất) ---
        console.log("--- Bắt đầu tải (Tuần tự) ---");
        console.log("1. Đang tải scalers và encoder (Song song)...");
        const [
            scalerEcgData,
            scalerMlpData,
            encoderData
        ] = await Promise.all([
            fs.readFile(scalerEcgPath, 'utf8'),
            fs.readFile(scalerMlpPath, 'utf8'),
            fs.readFile(encoderPath, 'utf8')
        ]);
        models.scaler_ecg = JSON.parse(scalerEcgData);
        models.scaler_mlp = JSON.parse(scalerMlpData);
        models.risk_encoder = JSON.parse(encoderData);
        console.log("Tải scalers/encoder thành công.");

        // 2. Tải Model ECG
        // (LƯU Ý: await createManualPatchedHandler vì nó là hàm async)
        console.log("2. Đang tải mô hình ECG...");
        const ecgHandler = await createManualPatchedHandler(ecgModelPath);
        models.model_ecg = await tf.loadLayersModel(ecgHandler);
        console.log("Tải ECG model thành công.");

        // 3. Tải Model MLP
        console.log("3. Đang tải mô hình MLP...");
        const mlpHandler = await createManualPatchedHandler(mlpModelPath);
        models.model_mlp = await tf.loadLayersModel(mlpHandler);
        console.log("Tải MLP model thành công.");

        console.log("--- Tải mô hình và scalers THÀNH CÔNG! ---");

    } catch (error) {
        console.error("LỖI TẢI MÔ HÌNH:", error);
        throw error;
    }
};

// Hàm để các services khác có thể lấy model
const getModels = () => models;

module.exports = {
    loadAllModels,
    getModels
};