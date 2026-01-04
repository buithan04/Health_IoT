"use client";

import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
    FileText,
    User,
    Mail,
    Phone,
    Stethoscope,
    Calendar,
    Clock,
    Activity,
    Pill,
    ClipboardList,
    AlertCircle,
    CalendarCheck,
} from "lucide-react";
import { format } from "date-fns";
import { vi } from "date-fns/locale";

interface PrescriptionDetailModalProps {
    prescription: any;
    open: boolean;
    onClose: () => void;
}

export function PrescriptionDetailModal({
    prescription,
    open,
    onClose,
}: PrescriptionDetailModalProps) {
    if (!prescription) return null;

    return (
        <Dialog open={open} onOpenChange={onClose}>
            <DialogContent className="max-w-5xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <div className="flex items-center gap-3">
                        <div className="h-12 w-12 rounded-full bg-gradient-to-br from-orange-100 to-red-100 flex items-center justify-center">
                            <FileText className="h-6 w-6 text-orange-600" />
                        </div>
                        <div>
                            <DialogTitle className="text-2xl">Chi tiết Đơn thuốc</DialogTitle>
                            <div className="flex items-center gap-2 mt-1">
                                <Badge className="bg-orange-100 text-orange-700 border-orange-300">
                                    Đơn #{prescription.id}
                                </Badge>
                                <Badge variant="outline" className="text-xs">
                                    {prescription.items?.length || 0} thuốc
                                </Badge>
                            </div>
                        </div>
                    </div>
                </DialogHeader>

                <div className="space-y-4 mt-4">
                    {/* Prescription Date */}
                    <Card className="border-2 border-blue-200 bg-blue-50/50">
                        <CardHeader className="pb-3">
                            <CardTitle className="text-lg flex items-center gap-2 text-blue-900">
                                <Calendar className="h-5 w-5" />
                                Ngày kê đơn
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="flex items-center gap-4">
                                <div className="flex items-center gap-2">
                                    <Calendar className="h-4 w-4 text-blue-600" />
                                    <span className="font-medium">
                                        {prescription.created_at
                                            ? format(new Date(prescription.created_at), 'dd/MM/yyyy', { locale: vi })
                                            : 'N/A'}
                                    </span>
                                </div>
                                <div className="flex items-center gap-2">
                                    <Clock className="h-4 w-4 text-blue-600" />
                                    <span className="font-medium">
                                        {prescription.created_at
                                            ? format(new Date(prescription.created_at), 'HH:mm', { locale: vi })
                                            : 'N/A'}
                                    </span>
                                </div>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Patient Information */}
                    <Card className="border-2 border-purple-200 bg-purple-50/50">
                        <CardHeader className="pb-3">
                            <CardTitle className="text-lg flex items-center gap-2 text-purple-900">
                                <User className="h-5 w-5" />
                                Thông tin Bệnh nhân
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="space-y-2">
                                <div className="flex items-center gap-2">
                                    <User className="h-4 w-4 text-purple-600" />
                                    <span className="font-medium">{prescription.patient_name || 'N/A'}</span>
                                </div>
                                {prescription.patient_email && (
                                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                                        <Mail className="h-4 w-4" />
                                        <span>{prescription.patient_email}</span>
                                    </div>
                                )}
                                {prescription.patient_phone && (
                                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                                        <Phone className="h-4 w-4" />
                                        <span>{prescription.patient_phone}</span>
                                    </div>
                                )}
                            </div>
                        </CardContent>
                    </Card>

                    {/* Doctor Information */}
                    <Card className="border-2 border-teal-200 bg-teal-50/50">
                        <CardHeader className="pb-3">
                            <CardTitle className="text-lg flex items-center gap-2 text-teal-900">
                                <Stethoscope className="h-5 w-5" />
                                Bác sĩ kê đơn
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="space-y-2">
                                <div className="flex items-center gap-2">
                                    <Stethoscope className="h-4 w-4 text-teal-600" />
                                    <span className="font-medium">BS. {prescription.doctor_name || 'N/A'}</span>
                                </div>
                                {prescription.doctor_email && (
                                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                                        <Mail className="h-4 w-4" />
                                        <span>{prescription.doctor_email}</span>
                                    </div>
                                )}
                                {prescription.doctor_phone && (
                                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                                        <Phone className="h-4 w-4" />
                                        <span>{prescription.doctor_phone}</span>
                                    </div>
                                )}
                            </div>
                        </CardContent>
                    </Card>

                    {/* Clinical Information */}
                    <Card className="border-2 border-green-200 bg-green-50/50">
                        <CardHeader className="pb-3">
                            <CardTitle className="text-lg flex items-center gap-2 text-green-900">
                                <Activity className="h-5 w-5" />
                                Thông tin lâm sàng
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="space-y-3">
                                {prescription.chief_complaint && (
                                    <div>
                                        <div className="flex items-center gap-2 mb-1">
                                            <AlertCircle className="h-4 w-4 text-green-600" />
                                            <span className="text-sm font-semibold text-green-900">Lý do khám:</span>
                                        </div>
                                        <p className="text-sm ml-6">{prescription.chief_complaint}</p>
                                    </div>
                                )}
                                {prescription.clinical_findings && (
                                    <div>
                                        <div className="flex items-center gap-2 mb-1">
                                            <ClipboardList className="h-4 w-4 text-green-600" />
                                            <span className="text-sm font-semibold text-green-900">Triệu chứng:</span>
                                        </div>
                                        <p className="text-sm ml-6">{prescription.clinical_findings}</p>
                                    </div>
                                )}
                                {prescription.diagnosis && (
                                    <div>
                                        <div className="flex items-center gap-2 mb-1">
                                            <Activity className="h-4 w-4 text-green-600" />
                                            <span className="text-sm font-semibold text-green-900">Chẩn đoán:</span>
                                        </div>
                                        <p className="text-sm ml-6 font-medium">{prescription.diagnosis}</p>
                                    </div>
                                )}
                                {prescription.notes && (
                                    <div>
                                        <div className="flex items-center gap-2 mb-1">
                                            <FileText className="h-4 w-4 text-green-600" />
                                            <span className="text-sm font-semibold text-green-900">Ghi chú:</span>
                                        </div>
                                        <p className="text-sm ml-6">{prescription.notes}</p>
                                    </div>
                                )}
                                {prescription.follow_up_date && (
                                    <div>
                                        <div className="flex items-center gap-2 mb-1">
                                            <CalendarCheck className="h-4 w-4 text-green-600" />
                                            <span className="text-sm font-semibold text-green-900">Ngày tái khám:</span>
                                        </div>
                                        <p className="text-sm ml-6 font-medium">
                                            {format(new Date(prescription.follow_up_date), 'dd/MM/yyyy', { locale: vi })}
                                        </p>
                                    </div>
                                )}
                            </div>
                        </CardContent>
                    </Card>

                    {/* Medications */}
                    <Card className="border-2 border-orange-200 bg-orange-50/50">
                        <CardHeader className="pb-3">
                            <CardTitle className="text-lg flex items-center gap-2 text-orange-900">
                                <Pill className="h-5 w-5" />
                                Danh sách thuốc ({prescription.items?.length || 0})
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            {prescription.items && prescription.items.length > 0 ? (
                                <div className="space-y-3">
                                    {prescription.items.map((item: any, index: number) => (
                                        <div
                                            key={item.id}
                                            className="p-4 bg-white rounded-lg border-2 border-orange-100 hover:border-orange-300 transition-colors"
                                        >
                                            <div className="flex items-start gap-3">
                                                <div className="h-10 w-10 rounded-full bg-orange-100 flex items-center justify-center shrink-0">
                                                    <span className="text-sm font-bold text-orange-700">
                                                        {index + 1}
                                                    </span>
                                                </div>
                                                <div className="flex-1 space-y-2">
                                                    <div className="flex items-start justify-between gap-2">
                                                        <h4 className="font-semibold text-base">
                                                            {item.medication_name}
                                                        </h4>
                                                        <Badge variant="outline" className="shrink-0">
                                                            SL: {item.quantity}
                                                        </Badge>
                                                    </div>
                                                    {item.dosage_instruction && (
                                                        <div className="bg-blue-50 border border-blue-200 rounded p-3">
                                                            <p className="text-xs font-semibold text-blue-900 mb-1">
                                                                Cách dùng:
                                                            </p>
                                                            <p className="text-sm text-blue-700">
                                                                {item.dosage_instruction}
                                                            </p>
                                                        </div>
                                                    )}
                                                </div>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            ) : (
                                <div className="text-center py-8 text-muted-foreground">
                                    <Pill className="h-8 w-8 mx-auto mb-2 opacity-50" />
                                    <p className="text-sm">Không có thông tin thuốc</p>
                                </div>
                            )}
                        </CardContent>
                    </Card>
                </div>
            </DialogContent>
        </Dialog>
    );
}
