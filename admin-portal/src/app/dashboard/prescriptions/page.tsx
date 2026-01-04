"use client";

import { useState } from "react";
import { apiCall } from "@/utils/api";
import { useQuery } from "@tanstack/react-query";
import {
    Pill,
    Search,
    Filter,
    Eye,
    FileText,
    Loader2,
    RefreshCw,
    User,
    Stethoscope,
    Calendar,
    Package
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { format } from "date-fns";
import { vi } from "date-fns/locale";
import { PrescriptionDetailModal } from "@/components/modals/PrescriptionDetailModal";

export default function PrescriptionsPage() {
    const [searchQuery, setSearchQuery] = useState("");
    const [selectedPrescription, setSelectedPrescription] = useState<any>(null);
    const [showDetailModal, setShowDetailModal] = useState(false);

    const { data: prescriptions, isLoading, refetch } = useQuery({
        queryKey: ['allPrescriptions'],
        queryFn: async () => {
            const res = await apiCall('/admin/prescriptions');
            return res?.prescriptions || [];
        }
    });

    const filteredPrescriptions = prescriptions?.filter((prescription: any) => {
        return !searchQuery ||
            prescription.patient_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            prescription.doctor_name?.toLowerCase().includes(searchQuery.toLowerCase());
    });

    const stats = {
        total: prescriptions?.length || 0,
        thisMonth: prescriptions?.filter((p: any) => {
            const date = new Date(p.prescribed_date);
            const now = new Date();
            return date.getMonth() === now.getMonth() && date.getFullYear() === now.getFullYear();
        }).length || 0,
        avgMedications: prescriptions?.length > 0
            ? Math.round(prescriptions.reduce((sum: number, p: any) =>
                sum + (p.medication_count || 0), 0) / prescriptions.length)
            : 0
    };

    if (isLoading) {
        return (
            <div className="flex items-center justify-center h-[calc(100vh-100px)]">
                <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
            </div>
        );
    }

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight bg-gradient-to-r from-orange-600 to-red-600 bg-clip-text text-transparent">
                        Quản lý Đơn thuốc
                    </h1>
                    <p className="text-muted-foreground mt-2">
                        Quản lý và theo dõi tất cả đơn thuốc đã kê
                    </p>
                </div>
                <div className="flex items-center gap-3">
                    <Button onClick={() => refetch()} variant="outline" size="icon">
                        <RefreshCw className="h-4 w-4" />
                    </Button>
                </div>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <Card className="border-2 border-orange-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Tổng đơn thuốc</p>
                                <p className="text-2xl font-bold">{stats.total}</p>
                            </div>
                            <Pill className="h-8 w-8 text-orange-600" />
                        </div>
                    </CardContent>
                </Card>
                <Card className="border-2 border-red-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Tháng này</p>
                                <p className="text-2xl font-bold">{stats.thisMonth}</p>
                            </div>
                            <Calendar className="h-8 w-8 text-red-600" />
                        </div>
                    </CardContent>
                </Card>
                <Card className="border-2 border-purple-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">TB thuốc/đơn</p>
                                <p className="text-2xl font-bold">{stats.avgMedications}</p>
                            </div>
                            <Package className="h-8 w-8 text-purple-600" />
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Search */}
            <Card className="border-2">
                <CardContent className="pt-6">
                    <div className="relative">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                        <Input
                            placeholder="Tìm kiếm theo tên bệnh nhân hoặc bác sĩ..."
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            className="pl-10"
                        />
                    </div>
                </CardContent>
            </Card>

            {/* Prescriptions List */}
            <Card className="border-2">
                <CardHeader className="border-b bg-gradient-to-r from-orange-50 to-red-50">
                    <CardTitle>Danh sách Đơn thuốc</CardTitle>
                    <CardDescription>Hiển thị {filteredPrescriptions?.length || 0} đơn thuốc</CardDescription>
                </CardHeader>
                <CardContent className="pt-6">
                    <div className="space-y-4">
                        {filteredPrescriptions?.length === 0 ? (
                            <div className="text-center py-12">
                                <Pill className="h-12 w-12 mx-auto text-gray-300 mb-3" />
                                <p className="text-sm text-muted-foreground">Không tìm thấy đơn thuốc nào</p>
                            </div>
                        ) : (
                            filteredPrescriptions?.map((prescription: any) => (
                                <div key={prescription.id} className="flex flex-col md:flex-row items-start gap-4 p-4 rounded-lg border-2 hover:border-orange-300 hover:bg-orange-50/50 transition-all">
                                    <div className="h-12 w-12 rounded-full bg-gradient-to-br from-orange-100 to-red-100 flex items-center justify-center shrink-0">
                                        <FileText className="h-6 w-6 text-orange-600" />
                                    </div>

                                    <div className="flex-1 space-y-2 min-w-0">
                                        <div className="flex items-start justify-between gap-4">
                                            <div>
                                                <div className="flex items-center gap-2 mb-1">
                                                    <Badge className="bg-orange-100 text-orange-700 border-orange-300 border">
                                                        Đơn #{prescription.id}
                                                    </Badge>
                                                    <Badge variant="outline" className="text-xs">
                                                        {prescription.medication_count || 0} thuốc
                                                    </Badge>
                                                </div>
                                                <h3 className="font-semibold text-lg">{prescription.patient_name}</h3>
                                            </div>
                                            <Button
                                                variant="outline"
                                                size="sm"
                                                onClick={() => {
                                                    setSelectedPrescription(prescription);
                                                    setShowDetailModal(true);
                                                }}
                                            >
                                                <Eye className="h-3 w-3 mr-1" />
                                                Chi tiết
                                            </Button>
                                        </div>

                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm">
                                            <div className="flex items-center gap-2 text-muted-foreground">
                                                <User className="h-4 w-4" />
                                                <span className="truncate">{prescription.patient_email}</span>
                                            </div>
                                            <div className="flex items-center gap-2 text-muted-foreground">
                                                <Stethoscope className="h-4 w-4" />
                                                <span className="truncate">BS. {prescription.doctor_name}</span>
                                            </div>
                                            <div className="flex items-center gap-2 text-muted-foreground">
                                                <Calendar className="h-4 w-4" />
                                                <span>
                                                    {prescription.created_at ?
                                                        format(new Date(prescription.created_at), 'dd/MM/yyyy HH:mm', { locale: vi })
                                                        : 'N/A'}
                                                </span>
                                            </div>
                                        </div>

                                        {prescription.diagnosis && (
                                            <div className="mt-2 p-3 bg-blue-50 border border-blue-200 rounded">
                                                <p className="text-sm font-medium text-blue-900">Chẩn đoán:</p>
                                                <p className="text-sm text-blue-700 mt-1">{prescription.diagnosis}</p>
                                            </div>
                                        )}

                                        {prescription.notes && (
                                            <div className="mt-2 p-3 bg-gray-50 border border-gray-200 rounded">
                                                <p className="text-sm font-medium text-gray-900">Ghi chú:</p>
                                                <p className="text-sm text-gray-700 mt-1">{prescription.notes}</p>
                                            </div>
                                        )}
                                    </div>
                                </div>
                            ))
                        )}
                    </div>
                </CardContent>
            </Card>

            {/* Prescription Detail Modal */}
            <PrescriptionDetailModal
                prescription={selectedPrescription}
                open={showDetailModal}
                onClose={() => {
                    setShowDetailModal(false);
                    setSelectedPrescription(null);
                }}
            />
        </div>
    );
}
