"use client";

import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import { format } from "date-fns";
import { vi } from "date-fns/locale";
import {
    User,
    Mail,
    Phone,
    Calendar,
    Clock,
    MapPin,
    Stethoscope,
    FileText,
    DollarSign,
    Activity,
    MessageSquare,
    CheckCircle2,
    XCircle,
    AlertCircle
} from "lucide-react";

interface AppointmentDetailModalProps {
    appointment: any;
    open: boolean;
    onClose: () => void;
}

export function AppointmentDetailModal({ appointment, open, onClose }: AppointmentDetailModalProps) {
    if (!appointment) return null;

    const getStatusConfig = (status: string) => {
        const configs: any = {
            pending: {
                color: "bg-yellow-100 text-yellow-700 border-yellow-300",
                label: "Chờ xác nhận",
                icon: Clock
            },
            confirmed: {
                color: "bg-blue-100 text-blue-700 border-blue-300",
                label: "Đã xác nhận",
                icon: CheckCircle2
            },
            completed: {
                color: "bg-green-100 text-green-700 border-green-300",
                label: "Hoàn thành",
                icon: CheckCircle2
            },
            cancelled: {
                color: "bg-red-100 text-red-700 border-red-300",
                label: "Đã hủy",
                icon: XCircle
            },
            scheduled: {
                color: "bg-indigo-100 text-indigo-700 border-indigo-300",
                label: "Đã lên lịch",
                icon: Calendar
            }
        };
        return configs[status] || configs.pending;
    };

    const statusConfig = getStatusConfig(appointment.status);
    const StatusIcon = statusConfig.icon;

    return (
        <Dialog open={open} onOpenChange={onClose}>
            <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto" aria-describedby="appointment-detail-description">
                <DialogHeader className="space-y-3 border-b pb-4">
                    <div className="flex items-center justify-between">
                        <DialogTitle className="text-2xl">Chi tiết Lịch hẹn #{appointment.id}</DialogTitle>
                        <Badge className={`${statusConfig.color} border flex items-center gap-1 px-3 py-1`}>
                            <StatusIcon className="h-4 w-4" />
                            {statusConfig.label}
                        </Badge>
                    </div>
                    <DialogDescription id="appointment-detail-description" className="sr-only">
                        Xem chi tiết thông tin lịch hẹn của bệnh nhân {appointment.patient_name}
                    </DialogDescription>
                </DialogHeader>

                <div className="space-y-6 py-4">
                    {/* Appointment Time & Date */}
                    <Card className="border-2 border-blue-100">
                        <CardContent className="pt-6 space-y-4">
                            <h3 className="font-semibold text-lg text-blue-700 flex items-center gap-2">
                                <Calendar className="h-5 w-5" />
                                Thời gian khám
                            </h3>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="flex items-center gap-3 p-3 bg-gradient-to-br from-blue-50 to-cyan-50 rounded-lg border border-blue-200">
                                    <Calendar className="h-5 w-5 text-blue-600" />
                                    <div>
                                        <p className="text-xs text-blue-600 font-semibold">Ngày khám</p>
                                        <p className="text-sm font-medium text-gray-700">
                                            {appointment.appointment_date
                                                ? format(new Date(appointment.appointment_date), 'dd/MM/yyyy', { locale: vi })
                                                : 'Chưa xác định'}
                                        </p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-3 p-3 bg-gradient-to-br from-indigo-50 to-purple-50 rounded-lg border border-indigo-200">
                                    <Clock className="h-5 w-5 text-indigo-600" />
                                    <div>
                                        <p className="text-xs text-indigo-600 font-semibold">Giờ khám</p>
                                        <p className="text-sm font-medium text-gray-700">
                                            {appointment.appointment_date
                                                ? format(new Date(appointment.appointment_date), 'HH:mm', { locale: vi })
                                                : 'Chưa xác định'}
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Patient Information */}
                    <Card className="border-2 border-purple-100">
                        <CardContent className="pt-6 space-y-4">
                            <h3 className="font-semibold text-lg text-purple-700 flex items-center gap-2">
                                <User className="h-5 w-5" />
                                Thông tin Bệnh nhân
                            </h3>
                            <div className="grid grid-cols-1 gap-4">
                                <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                    <User className="h-5 w-5 text-gray-500" />
                                    <div>
                                        <p className="text-xs text-gray-500">Họ và tên</p>
                                        <p className="text-sm font-medium">{appointment.patient_name || 'N/A'}</p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                    <Mail className="h-5 w-5 text-gray-500" />
                                    <div>
                                        <p className="text-xs text-gray-500">Email</p>
                                        <p className="text-sm font-medium">{appointment.patient_email || 'N/A'}</p>
                                    </div>
                                </div>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Doctor Information */}
                    <Card className="border-2 border-teal-100">
                        <CardContent className="pt-6 space-y-4">
                            <h3 className="font-semibold text-lg text-teal-700 flex items-center gap-2">
                                <Stethoscope className="h-5 w-5" />
                                Thông tin Bác sĩ
                            </h3>
                            <div className="grid grid-cols-1 gap-4">
                                <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                    <Stethoscope className="h-5 w-5 text-gray-500" />
                                    <div>
                                        <p className="text-xs text-gray-500">Bác sĩ</p>
                                        <p className="text-sm font-medium">BS. {appointment.doctor_name || 'N/A'}</p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                    <Mail className="h-5 w-5 text-gray-500" />
                                    <div>
                                        <p className="text-xs text-gray-500">Email bác sĩ</p>
                                        <p className="text-sm font-medium">{appointment.doctor_email || 'N/A'}</p>
                                    </div>
                                </div>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Appointment Details */}
                    <Card className="border-2 border-green-100">
                        <CardContent className="pt-6 space-y-4">
                            <h3 className="font-semibold text-lg text-green-700 flex items-center gap-2">
                                <FileText className="h-5 w-5" />
                                Chi tiết lịch hẹn
                            </h3>
                            <div className="space-y-3">
                                {appointment.appointment_type && (
                                    <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                        <Activity className="h-5 w-5 text-gray-500" />
                                        <div>
                                            <p className="text-xs text-gray-500">Loại khám</p>
                                            <p className="text-sm font-medium">{appointment.appointment_type}</p>
                                        </div>
                                    </div>
                                )}
                                {appointment.notes && (
                                    <div className="p-4 bg-gradient-to-br from-blue-50 to-cyan-50 rounded-lg border border-blue-200">
                                        <div className="flex items-start gap-2 mb-2">
                                            <MessageSquare className="h-4 w-4 text-blue-600 mt-0.5" />
                                            <p className="text-xs text-blue-600 font-semibold">Ghi chú</p>
                                        </div>
                                        <p className="text-sm text-gray-700 leading-relaxed">{appointment.notes}</p>
                                    </div>
                                )}
                                {appointment.cancellation_reason && (
                                    <div className="p-4 bg-gradient-to-br from-red-50 to-orange-50 rounded-lg border border-red-200">
                                        <div className="flex items-start gap-2 mb-2">
                                            <AlertCircle className="h-4 w-4 text-red-600 mt-0.5" />
                                            <p className="text-xs text-red-600 font-semibold">Lý do hủy</p>
                                        </div>
                                        <p className="text-sm text-gray-700 leading-relaxed">{appointment.cancellation_reason}</p>
                                    </div>
                                )}
                            </div>
                        </CardContent>
                    </Card>

                    {/* Timestamps */}
                    {(appointment.created_at || appointment.updated_at) && (
                        <Card className="border-2 border-gray-100">
                            <CardContent className="pt-6">
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    {appointment.created_at && (
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                            <Clock className="h-5 w-5 text-gray-500" />
                                            <div>
                                                <p className="text-xs text-gray-500">Ngày tạo</p>
                                                <p className="text-sm font-medium">
                                                    {format(new Date(appointment.created_at), 'dd/MM/yyyy HH:mm', { locale: vi })}
                                                </p>
                                            </div>
                                        </div>
                                    )}
                                    {appointment.updated_at && (
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                            <Clock className="h-5 w-5 text-gray-500" />
                                            <div>
                                                <p className="text-xs text-gray-500">Cập nhật lần cuối</p>
                                                <p className="text-sm font-medium">
                                                    {format(new Date(appointment.updated_at), 'dd/MM/yyyy HH:mm', { locale: vi })}
                                                </p>
                                            </div>
                                        </div>
                                    )}
                                </div>
                            </CardContent>
                        </Card>
                    )}
                </div>

                <div className="flex justify-end gap-2 pt-4 border-t">
                    <Button type="button" variant="outline" onClick={onClose}>
                        Đóng
                    </Button>
                </div>
            </DialogContent>
        </Dialog>
    );
}
