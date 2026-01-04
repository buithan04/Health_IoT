"use client";

import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
    Pill,
    Tag,
    Building2,
    DollarSign,
    Package,
    FileText,
    BookOpen,
} from "lucide-react";

interface MedicationDetailModalProps {
    medication: any;
    open: boolean;
    onClose: () => void;
}

export function MedicationDetailModal({
    medication,
    open,
    onClose,
}: MedicationDetailModalProps) {
    if (!medication) return null;

    return (
        <Dialog open={open} onOpenChange={onClose}>
            <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <div className="flex items-center gap-3">
                        <div className="h-12 w-12 rounded-full bg-gradient-to-br from-green-100 to-teal-100 flex items-center justify-center">
                            <Pill className="h-6 w-6 text-green-600" />
                        </div>
                        <div>
                            <DialogTitle className="text-2xl">{medication.name}</DialogTitle>
                            <DialogDescription className="sr-only">
                                Thông tin chi tiết về thuốc {medication.name}
                            </DialogDescription>
                            <div className="flex items-center gap-2 mt-1">
                                <Badge className="bg-green-100 text-green-700 border-green-300">
                                    {medication.category || 'Chưa phân loại'}
                                </Badge>
                                {medication.is_active !== false && (
                                    <Badge variant="outline" className="text-xs border-blue-300 text-blue-700">
                                        Đang hoạt động
                                    </Badge>
                                )}
                            </div>
                        </div>
                    </div>
                </DialogHeader>

                <div className="space-y-4 mt-4">
                    {/* Basic Information */}
                    <Card className="border-2 border-blue-200 bg-blue-50/50">
                        <CardHeader className="pb-3">
                            <CardTitle className="text-lg flex items-center gap-2 text-blue-900">
                                <FileText className="h-5 w-5" />
                                Thông tin cơ bản
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="grid grid-cols-2 gap-4">
                                {medication.registration_number && (
                                    <div>
                                        <div className="flex items-center gap-2 mb-1">
                                            <FileText className="h-4 w-4 text-blue-600" />
                                            <span className="text-sm font-semibold text-blue-900">Số đăng ký:</span>
                                        </div>
                                        <p className="text-sm ml-6">{medication.registration_number}</p>
                                    </div>
                                )}
                                {medication.active_ingredient && (
                                    <div>
                                        <div className="flex items-center gap-2 mb-1">
                                            <BookOpen className="h-4 w-4 text-blue-600" />
                                            <span className="text-sm font-semibold text-blue-900">Hoạt chất:</span>
                                        </div>
                                        <p className="text-sm ml-6">{medication.active_ingredient}</p>
                                    </div>
                                )}
                                {medication.unit && (
                                    <div>
                                        <div className="flex items-center gap-2 mb-1">
                                            <Package className="h-4 w-4 text-blue-600" />
                                            <span className="text-sm font-semibold text-blue-900">Đơn vị:</span>
                                        </div>
                                        <p className="text-sm ml-6">{medication.unit}</p>
                                    </div>
                                )}
                                {medication.usage_route && (
                                    <div>
                                        <div className="flex items-center gap-2 mb-1">
                                            <Tag className="h-4 w-4 text-blue-600" />
                                            <span className="text-sm font-semibold text-blue-900">Đường dùng:</span>
                                        </div>
                                        <p className="text-sm ml-6">{medication.usage_route}</p>
                                    </div>
                                )}
                                {medication.manufacturer && (
                                    <div>
                                        <div className="flex items-center gap-2 mb-1">
                                            <Building2 className="h-4 w-4 text-blue-600" />
                                            <span className="text-sm font-semibold text-blue-900">Nhà sản xuất:</span>
                                        </div>
                                        <p className="text-sm ml-6">{medication.manufacturer}</p>
                                    </div>
                                )}
                                {medication.price && (
                                    <div>
                                        <div className="flex items-center gap-2 mb-1">
                                            <DollarSign className="h-4 w-4 text-blue-600" />
                                            <span className="text-sm font-semibold text-blue-900">Giá:</span>
                                        </div>
                                        <p className="text-sm ml-6 font-medium text-green-700">
                                            {medication.price.toLocaleString('vi-VN')} VNĐ
                                        </p>
                                    </div>
                                )}
                            </div>
                        </CardContent>
                    </Card>

                    {/* Stock Information */}
                    <Card className="border-2 border-purple-200 bg-purple-50/50">
                        <CardHeader className="pb-3">
                            <CardTitle className="text-lg flex items-center gap-2 text-purple-900">
                                <Package className="h-5 w-5" />
                                Tồn kho
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <span className="text-sm font-semibold text-purple-900">Số lượng hiện tại:</span>
                                    <p className="text-2xl font-bold text-purple-700 mt-1">
                                        {medication.stock || 0}
                                    </p>
                                </div>
                                <div>
                                    <span className="text-sm font-semibold text-purple-900">Tồn kho tối thiểu:</span>
                                    <p className="text-2xl font-bold text-purple-700 mt-1">
                                        {medication.min_stock || 0}
                                    </p>
                                </div>
                            </div>
                            {medication.stock <= medication.min_stock && (
                                <div className="mt-3 p-3 bg-yellow-100 border border-yellow-300 rounded">
                                    <p className="text-sm font-medium text-yellow-900">
                                        ⚠️ Cảnh báo: Tồn kho thấp, cần nhập thêm
                                    </p>
                                </div>
                            )}
                        </CardContent>
                    </Card>

                    {/* Description */}
                    {(medication.packing_specification || medication.description) && (
                        <Card className="border-2 border-green-200 bg-green-50/50">
                            <CardHeader className="pb-3">
                                <CardTitle className="text-lg flex items-center gap-2 text-green-900">
                                    <FileText className="h-5 w-5" />
                                    Quy cách đóng gói
                                </CardTitle>
                            </CardHeader>
                            <CardContent>
                                <p className="text-sm">{medication.packing_specification || medication.description}</p>
                            </CardContent>
                        </Card>
                    )}

                    {/* Usage Instructions */}
                    {(medication.usage_instruction || medication.usage_instructions) && (
                        <Card className="border-2 border-orange-200 bg-orange-50/50">
                            <CardHeader className="pb-3">
                                <CardTitle className="text-lg flex items-center gap-2 text-orange-900">
                                    <BookOpen className="h-5 w-5" />
                                    Hướng dẫn sử dụng
                                </CardTitle>
                            </CardHeader>
                            <CardContent>
                                <p className="text-sm whitespace-pre-wrap">
                                    {medication.usage_instruction || medication.usage_instructions}
                                </p>
                            </CardContent>
                        </Card>
                    )}
                </div>
            </DialogContent>
        </Dialog>
    );
}
