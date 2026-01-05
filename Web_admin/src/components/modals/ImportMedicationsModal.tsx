"use client";

import { useState, useRef } from "react";
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogDescription,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Upload, FileSpreadsheet, CheckCircle2, XCircle, AlertCircle, Download } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import * as XLSX from 'xlsx';
import { apiCall } from "@/utils/api";
import { toast } from "sonner";

interface ImportMedicationsModalProps {
    open: boolean;
    onClose: () => void;
    onSuccess: () => void;
}

export function ImportMedicationsModal({
    open,
    onClose,
    onSuccess,
}: ImportMedicationsModalProps) {
    const [file, setFile] = useState<File | null>(null);
    const [isUploading, setIsUploading] = useState(false);
    const [result, setResult] = useState<any>(null);
    const fileInputRef = useRef<HTMLInputElement>(null);

    const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
        const selectedFile = e.target.files?.[0];
        if (selectedFile) {
            // Validate file type
            const fileType = selectedFile.name.split('.').pop()?.toLowerCase();
            if (!['xlsx', 'xls', 'csv'].includes(fileType || '')) {
                toast.error('Vui lòng chọn file Excel (.xlsx, .xls) hoặc CSV');
                return;
            }
            setFile(selectedFile);
            setResult(null);
        }
    };

    const downloadTemplate = () => {
        // Download the CSV template file
        const link = document.createElement('a');
        link.href = '/templates/danh_sach_thuoc_mau.csv';
        link.download = 'danh_sach_thuoc_mau.csv';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        toast.success('Đã tải xuống file mẫu CSV với 50 loại thuốc');
    };

    const handleImport = async () => {
        if (!file) {
            toast.error('Vui lòng chọn file để import');
            return;
        }

        setIsUploading(true);
        setResult(null);

        try {
            // Read Excel/CSV file with UTF-8 encoding
            const data = await file.arrayBuffer();
            const workbook = XLSX.read(data, {
                type: 'array',
                codepage: 65001 // UTF-8
            });
            const sheetName = workbook.SheetNames[0];
            const worksheet = workbook.Sheets[sheetName];
            const jsonData = XLSX.utils.sheet_to_json(worksheet);

            if (jsonData.length === 0) {
                toast.error('File Excel không có dữ liệu');
                setIsUploading(false);
                return;
            }

            console.log('First row keys:', Object.keys(jsonData[0] as any));
            console.log('First row data:', jsonData[0]);

            // Validate and transform data - dynamic key matching
            const medications = jsonData.map((row: any) => {
                const keys = Object.keys(row);

                // Find name field - try all possible variations
                const nameKey = keys.find(k =>
                    k.includes('Tên') || k.includes('tên') || k === 'name' ||
                    k.includes('TÃªn') || k.includes('Ten')
                ) || '';
                const name = nameKey && row[nameKey] ? row[nameKey].toString().trim() : '';

                // Find price field
                const priceKey = keys.find(k =>
                    k.includes('Giá') || k.includes('giá') || k === 'price' ||
                    k.includes('GiÃ¡') || k.includes('Gia')
                ) || '';
                const priceValue = priceKey && row[priceKey] ? parseFloat(row[priceKey]) : 0;

                return {
                    name,
                    registration_number: (() => {
                        const k = keys.find(k => k.includes('Số') || k.includes('số') || k === 'registration_number');
                        return k && row[k] ? row[k].toString().trim() : '';
                    })(),
                    category: (() => {
                        const k = keys.find(k => k.includes('Danh') || k.includes('danh') || k === 'category');
                        return k && row[k] ? row[k].toString().trim() : '';
                    })(),
                    manufacturer: (() => {
                        const k = keys.find(k => k.includes('Nhà') || k.includes('nhà') || k === 'manufacturer');
                        return k && row[k] ? row[k].toString().trim() : '';
                    })(),
                    unit: (() => {
                        const k = keys.find(k => k.includes('Đơn') || k.includes('đơn') || k === 'unit');
                        return k && row[k] ? row[k].toString().trim() : 'Viên';
                    })(),
                    usage_route: (() => {
                        const k = keys.find(k => k.includes('Đường') || k.includes('đường') || k === 'usage_route');
                        return k && row[k] ? row[k].toString().trim() : 'Uống';
                    })(),
                    packing_specification: (() => {
                        const k = keys.find(k => k.includes('Quy') || k.includes('quy') || k === 'packing_specification');
                        return k && row[k] ? row[k].toString().trim() : '';
                    })(),
                    price: priceValue,
                    usage_instruction: (() => {
                        const k = keys.find(k => k.includes('Hướng') || k.includes('hướng') || k === 'usage_instruction');
                        return k && row[k] ? row[k].toString().trim() : '';
                    })(),
                    is_active: (() => {
                        const k = keys.find(k => k.includes('Trạng') || k.includes('trạng') || k === 'is_active' || k === 'status');
                        return k && row[k] ? row[k].toString().includes('Hoạt') : true;
                    })()
                };
            });

            console.log('Mapped medications sample:', medications[0]);

            // Validate required fields - name phải có và price phải > 0
            const invalidRows = medications.filter(m => !m.name || m.name === '' || !m.price || m.price <= 0);
            if (invalidRows.length > 0) {
                toast.error(`Có ${invalidRows.length} dòng thiếu tên hoặc giá`);
                setIsUploading(false);
                return;
            }

            // Call API to import
            const response = await apiCall('/admin/medications/import', 'POST', { medications });

            setResult(response);

            if (response.imported > 0) {
                toast.success(`Đã import thành công ${response.imported}/${response.total} thuốc`, {
                    duration: 5000
                });
                onSuccess();
            } else {
                toast.error('Không import được thuốc nào');
            }
        } catch (error: any) {
            console.error('Import error:', error);
            toast.error(error.message || 'Lỗi khi import dữ liệu');
        } finally {
            setIsUploading(false);
        }
    };

    const handleClose = () => {
        setFile(null);
        setResult(null);
        onClose();
    };

    return (
        <Dialog open={open} onOpenChange={handleClose}>
            <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <div className="flex items-center gap-3">
                        <div className="h-12 w-12 rounded-full bg-gradient-to-br from-green-100 to-teal-100 flex items-center justify-center">
                            <FileSpreadsheet className="h-6 w-6 text-green-600" />
                        </div>
                        <div>
                            <DialogTitle className="text-2xl">Import Thuốc từ Excel</DialogTitle>
                            <DialogDescription>
                                Tải lên file Excel chứa danh sách thuốc cần import
                            </DialogDescription>
                        </div>
                    </div>
                </DialogHeader>

                <div className="space-y-4 mt-4">
                    {/* Download Template */}
                    <Card className="border-2 border-blue-200 bg-blue-50/50">
                        <CardContent className="pt-6">
                            <div className="flex items-start justify-between gap-4">
                                <div className="flex-1">
                                    <h3 className="font-semibold text-blue-900 mb-2">File mẫu Excel</h3>
                                    <p className="text-sm text-blue-700 mb-3">
                                        Tải xuống file mẫu để xem định dạng dữ liệu đúng
                                    </p>
                                    <ul className="text-xs text-blue-600 space-y-1 mb-3">
                                        <li>• <strong>Tên thuốc</strong>: Tên thuốc (bắt buộc)</li>
                                        <li>• <strong>Hoạt chất</strong>: Hoạt chất chính</li>
                                        <li>• <strong>Số đăng ký</strong>: Số đăng ký lưu hành</li>
                                        <li>• <strong>Danh mục</strong>: Danh mục thuốc</li>
                                        <li>• <strong>Nhà sản xuất</strong>: Công ty sản xuất</li>
                                        <li>• <strong>Đơn vị</strong>: Đơn vị (Viên, Vỉ, Hộp...)</li>
                                        <li>• <strong>Đường dùng</strong>: Cách dùng (Uống, Tiêm...)</li>
                                        <li>• <strong>Quy cách đóng gói</strong>: Quy cách</li>
                                        <li>• <strong>Giá (VNĐ)</strong>: Giá bán (bắt buộc)</li>
                                        <li>• <strong>Hướng dẫn sử dụng</strong>: Cách sử dụng</li>
                                        <li>• <strong>Trạng thái</strong>: Hoạt động / Tạm ngưng</li>
                                    </ul>
                                </div>
                                <Button
                                    onClick={downloadTemplate}
                                    variant="outline"
                                    className="border-blue-300 text-blue-700 hover:bg-blue-100"
                                >
                                    <Download className="h-4 w-4 mr-2" />
                                    Tải mẫu
                                </Button>
                            </div>
                        </CardContent>
                    </Card>

                    {/* File Upload */}
                    <Card className="border-2 border-dashed border-gray-300 hover:border-green-400 transition-colors">
                        <CardContent className="pt-6">
                            <input
                                ref={fileInputRef}
                                type="file"
                                accept=".xlsx,.xls,.csv"
                                onChange={handleFileSelect}
                                className="hidden"
                            />
                            <div
                                onClick={() => fileInputRef.current?.click()}
                                className="cursor-pointer text-center py-8"
                            >
                                <Upload className="h-12 w-12 mx-auto mb-3 text-gray-400" />
                                {file ? (
                                    <div>
                                        <p className="font-semibold text-green-600 mb-1">{file.name}</p>
                                        <p className="text-sm text-muted-foreground">
                                            {(file.size / 1024).toFixed(2)} KB
                                        </p>
                                    </div>
                                ) : (
                                    <div>
                                        <p className="font-semibold mb-1">Click để chọn file</p>
                                        <p className="text-sm text-muted-foreground">
                                            Hỗ trợ file .xlsx, .xls, .csv
                                        </p>
                                    </div>
                                )}
                            </div>
                        </CardContent>
                    </Card>

                    {/* Import Result */}
                    {result && (
                        <Card className={`border-2 ${result.imported > 0 ? 'border-green-200 bg-green-50/50' : 'border-red-200 bg-red-50/50'}`}>
                            <CardContent className="pt-6">
                                <div className="flex items-start gap-3 mb-4">
                                    {result.imported > 0 ? (
                                        <CheckCircle2 className="h-6 w-6 text-green-600 shrink-0 mt-0.5" />
                                    ) : (
                                        <XCircle className="h-6 w-6 text-red-600 shrink-0 mt-0.5" />
                                    )}
                                    <div className="flex-1">
                                        <h3 className={`font-semibold mb-2 ${result.imported > 0 ? 'text-green-900' : 'text-red-900'}`}>
                                            Kết quả Import
                                        </h3>
                                        <div className="flex gap-3 mb-3">
                                            <Badge className="bg-blue-100 text-blue-700 border-blue-300">
                                                Tổng: {result.total}
                                            </Badge>
                                            <Badge className="bg-green-100 text-green-700 border-green-300">
                                                Thành công: {result.imported}
                                            </Badge>
                                            {result.errors && result.errors.length > 0 && (
                                                <Badge className="bg-red-100 text-red-700 border-red-300">
                                                    Lỗi: {result.errors.length}
                                                </Badge>
                                            )}
                                        </div>
                                        {result.errors && result.errors.length > 0 && (
                                            <div className="mt-3 space-y-2">
                                                <p className="text-sm font-medium text-red-900">Chi tiết lỗi:</p>
                                                <div className="max-h-40 overflow-y-auto space-y-1">
                                                    {result.errors.map((err: any, idx: number) => (
                                                        <div key={idx} className="flex items-start gap-2 text-xs text-red-700 bg-white p-2 rounded">
                                                            <AlertCircle className="h-3 w-3 shrink-0 mt-0.5" />
                                                            <span><strong>{err.name}:</strong> {err.error}</span>
                                                        </div>
                                                    ))}
                                                </div>
                                            </div>
                                        )}
                                    </div>
                                </div>
                            </CardContent>
                        </Card>
                    )}

                    {/* Actions */}
                    <div className="flex justify-end gap-3 pt-4 border-t">
                        <Button variant="outline" onClick={handleClose}>
                            Đóng
                        </Button>
                        <Button
                            onClick={handleImport}
                            disabled={!file || isUploading}
                            className="bg-green-600 hover:bg-green-700"
                        >
                            {isUploading ? (
                                <>
                                    <div className="h-4 w-4 mr-2 border-2 border-white border-t-transparent rounded-full animate-spin" />
                                    Đang import...
                                </>
                            ) : (
                                <>
                                    <Upload className="h-4 w-4 mr-2" />
                                    Import
                                </>
                            )}
                        </Button>
                    </div>
                </div>
            </DialogContent>
        </Dialog>
    );
}
