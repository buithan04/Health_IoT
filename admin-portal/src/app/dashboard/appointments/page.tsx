"use client";

import { useState } from "react";
import { apiCall } from "@/utils/api";
import { useQuery } from "@tanstack/react-query";
import {
    Calendar,
    Search,
    Filter,
    Eye,
    CheckCircle2,
    XCircle,
    Clock,
    Loader2,
    RefreshCw,
    User,
    Stethoscope,
    MessageSquare
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
import { AppointmentDetailModal } from "@/components/modals/AppointmentDetailModal";

export default function AppointmentsPage() {
    const [searchQuery, setSearchQuery] = useState("");
    const [statusFilter, setStatusFilter] = useState("all");
    const [selectedAppointment, setSelectedAppointment] = useState<any>(null);
    const [showDetailModal, setShowDetailModal] = useState(false);

    const { data: appointments, isLoading, refetch } = useQuery({
        queryKey: ['allAppointments'],
        queryFn: async () => {
            const res = await apiCall('/admin/appointments');
            const data = res?.appointments || [];

            // Debug: Log unique statuses
            const uniqueStatuses = [...new Set(data.map((a: any) => a.status))];
            console.log('Unique appointment statuses:', uniqueStatuses);
            console.log('Sample appointments:', data.slice(0, 3));

            return data;
        }
    });

    const filteredAppointments = appointments?.filter((appointment: any) => {
        const matchesSearch = !searchQuery ||
            appointment.patient_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            appointment.doctor_name?.toLowerCase().includes(searchQuery.toLowerCase());

        const matchesStatus = statusFilter === 'all' || appointment.status === statusFilter;

        return matchesSearch && matchesStatus;
    });

    const stats = {
        total: appointments?.length || 0,
        pending: appointments?.filter((a: any) => a.status === 'pending').length || 0,
        confirmed: appointments?.filter((a: any) => a.status === 'confirmed').length || 0,
        completed: appointments?.filter((a: any) => a.status === 'completed').length || 0,
        cancelled: appointments?.filter((a: any) => a.status === 'cancelled').length || 0,
    };

    const getStatusBadge = (status: string) => {
        const variants: any = {
            pending: { color: "bg-yellow-100 text-yellow-700 border-yellow-300", label: "Chờ xác nhận", icon: Clock },
            confirmed: { color: "bg-blue-100 text-blue-700 border-blue-300", label: "Đã xác nhận", icon: CheckCircle2 },
            scheduled: { color: "bg-indigo-100 text-indigo-700 border-indigo-300", label: "Đã lên lịch", icon: Calendar },
            completed: { color: "bg-green-100 text-green-700 border-green-300", label: "Hoàn thành", icon: CheckCircle2 },
            cancelled: { color: "bg-red-100 text-red-700 border-red-300", label: "Đã hủy", icon: XCircle }
        };
        return variants[status] || variants.pending;
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
                    <h1 className="text-3xl font-bold tracking-tight bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">
                        Quản lý Lịch hẹn
                    </h1>
                    <p className="text-muted-foreground mt-2">
                        Quản lý và theo dõi tất cả lịch hẹn khám
                    </p>
                </div>
                <div className="flex items-center gap-3">
                    <Button onClick={() => refetch()} variant="outline" size="icon">
                        <RefreshCw className="h-4 w-4" />
                    </Button>
                </div>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
                <Card className="border-2 border-gray-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Tổng số</p>
                                <p className="text-2xl font-bold">{stats.total}</p>
                            </div>
                            <Calendar className="h-8 w-8 text-gray-600" />
                        </div>
                    </CardContent>
                </Card>
                <Card className="border-2 border-yellow-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Chờ xác nhận</p>
                                <p className="text-2xl font-bold">{stats.pending}</p>
                            </div>
                            <Clock className="h-8 w-8 text-yellow-600" />
                        </div>
                    </CardContent>
                </Card>
                <Card className="border-2 border-blue-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Đã xác nhận</p>
                                <p className="text-2xl font-bold">{stats.confirmed}</p>
                            </div>
                            <CheckCircle2 className="h-8 w-8 text-blue-600" />
                        </div>
                    </CardContent>
                </Card>
                <Card className="border-2 border-green-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Hoàn thành</p>
                                <p className="text-2xl font-bold">{stats.completed}</p>
                            </div>
                            <CheckCircle2 className="h-8 w-8 text-green-600" />
                        </div>
                    </CardContent>
                </Card>
                <Card className="border-2 border-red-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Đã hủy</p>
                                <p className="text-2xl font-bold">{stats.cancelled}</p>
                            </div>
                            <XCircle className="h-8 w-8 text-red-600" />
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Filters */}
            <Card className="border-2">
                <CardContent className="pt-6">
                    <div className="flex flex-col md:flex-row gap-4">
                        <div className="relative flex-1">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                            <Input
                                placeholder="Tìm kiếm theo tên bệnh nhân hoặc bác sĩ..."
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                className="pl-10"
                            />
                        </div>
                        <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                                <Button variant="outline" className="min-w-[180px]">
                                    <Filter className="h-4 w-4 mr-2" />
                                    Trạng thái: {statusFilter === 'all' ? 'Tất cả' : getStatusBadge(statusFilter).label}
                                </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent>
                                <DropdownMenuItem onClick={() => setStatusFilter('all')}>Tất cả</DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setStatusFilter('pending')}>Chờ xác nhận</DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setStatusFilter('confirmed')}>Đã xác nhận</DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setStatusFilter('scheduled')}>Đã lên lịch</DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setStatusFilter('completed')}>Hoàn thành</DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setStatusFilter('cancelled')}>Đã hủy</DropdownMenuItem>
                            </DropdownMenuContent>
                        </DropdownMenu>
                    </div>
                </CardContent>
            </Card>

            {/* Appointments List */}
            <Card className="border-2">
                <CardHeader className="border-b bg-gradient-to-r from-blue-50 to-indigo-50">
                    <CardTitle>Danh sách Lịch hẹn</CardTitle>
                    <CardDescription>Hiển thị {filteredAppointments?.length || 0} lịch hẹn</CardDescription>
                </CardHeader>
                <CardContent className="pt-6">
                    <div className="space-y-4">
                        {filteredAppointments?.length === 0 ? (
                            <div className="text-center py-12">
                                <Calendar className="h-12 w-12 mx-auto text-gray-300 mb-3" />
                                <p className="text-sm text-muted-foreground">Không tìm thấy lịch hẹn nào</p>
                            </div>
                        ) : (
                            filteredAppointments?.map((appointment: any) => {
                                const statusInfo = getStatusBadge(appointment.status);
                                const StatusIcon = statusInfo.icon;

                                return (
                                    <div key={appointment.id} className="flex flex-col md:flex-row items-start gap-4 p-4 rounded-lg border-2 hover:border-blue-300 hover:bg-blue-50/50 transition-all">
                                        <div className={`h-12 w-12 rounded-full flex items-center justify-center shrink-0 ${statusInfo.color}`}>
                                            <StatusIcon className="h-6 w-6" />
                                        </div>

                                        <div className="flex-1 space-y-2 min-w-0">
                                            <div className="flex items-start justify-between gap-4">
                                                <div>
                                                    <div className="flex items-center gap-2 mb-1">
                                                        <Badge className={`${statusInfo.color} border`}>
                                                            {statusInfo.label}
                                                        </Badge>
                                                        <span className="text-sm text-muted-foreground">
                                                            #{appointment.id}
                                                        </span>
                                                    </div>
                                                    <h3 className="font-semibold text-lg">{appointment.patient_name}</h3>
                                                </div>
                                                <Button
                                                    variant="outline"
                                                    size="sm"
                                                    onClick={() => {
                                                        setSelectedAppointment(appointment);
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
                                                    <span className="truncate">{appointment.patient_email}</span>
                                                </div>
                                                <div className="flex items-center gap-2 text-muted-foreground">
                                                    <Stethoscope className="h-4 w-4" />
                                                    <span className="truncate">BS. {appointment.doctor_name}</span>
                                                </div>
                                                <div className="flex items-center gap-2 text-muted-foreground">
                                                    <Calendar className="h-4 w-4" />
                                                    <span>
                                                        {appointment.appointment_date ?
                                                            format(new Date(appointment.appointment_date), 'dd/MM/yyyy HH:mm', { locale: vi })
                                                            : 'N/A'}
                                                    </span>
                                                </div>
                                                {appointment.notes && (
                                                    <div className="flex items-center gap-2 text-muted-foreground">
                                                        <MessageSquare className="h-4 w-4" />
                                                        <span className="truncate">{appointment.notes}</span>
                                                    </div>
                                                )}
                                            </div>

                                            {appointment.cancellation_reason && (
                                                <div className="mt-2 p-2 bg-red-50 border border-red-200 rounded text-sm text-red-700">
                                                    <strong>Lý do hủy:</strong> {appointment.cancellation_reason}
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                );
                            })
                        )}
                    </div>
                </CardContent>
            </Card>

            {/* Detail Modal */}
            {selectedAppointment && (
                <AppointmentDetailModal
                    appointment={selectedAppointment}
                    open={showDetailModal}
                    onClose={() => {
                        setShowDetailModal(false);
                        setSelectedAppointment(null);
                    }}
                />
            )}
        </div>
    );
}
