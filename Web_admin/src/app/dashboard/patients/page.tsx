"use client";

import { useState } from "react";
import { apiCall } from "@/utils/api";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
    Users,
    Search,
    Filter,
    Eye,
    Edit,
    Trash2,
    Plus,
    Loader2,
    RefreshCw,
    UserCheck,
    UserX,
    Phone,
    Mail,
    Calendar,
    MapPin,
    FileText,
    Activity,
    UserCircle
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
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
import { PatientModal } from "@/components/modals/PatientModal";
import { DeleteConfirmModal } from "@/components/modals/DeleteConfirmModal";
import { toast } from "sonner";

export default function PatientsPage() {
    const [searchQuery, setSearchQuery] = useState("");
    const [genderFilter, setGenderFilter] = useState("all");
    const [statusFilter, setStatusFilter] = useState("all");
    const [selectedPatient, setSelectedPatient] = useState<any>(null);
    const [modalMode, setModalMode] = useState<'view' | 'edit'>('view');
    const [showModal, setShowModal] = useState(false);
    const [showDeleteModal, setShowDeleteModal] = useState(false);
    const [patientToDelete, setPatientToDelete] = useState<any>(null);

    const queryClient = useQueryClient();

    const { data: patients, isLoading, refetch } = useQuery({
        queryKey: ['allPatients'],
        queryFn: async () => {
            const res = await apiCall('/admin/patients');
            return res?.patients || [];
        },
        refetchInterval: 30000
    });

    const deleteMutation = useMutation({
        mutationFn: async (patientId: number) => {
            await apiCall(`/admin/patients/${patientId}`, 'DELETE');
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['allPatients'] });
            setShowDeleteModal(false);
            setPatientToDelete(null);
            toast.success('Xóa bệnh nhân thành công');
        },
        onError: (error: any) => {
            console.error('Error deleting patient:', error);
            console.log('Full error object:', JSON.stringify(error, null, 2));
            setShowDeleteModal(false);

            const errorMessage = error?.message || 'Có lỗi xảy ra';
            console.log('Error message:', errorMessage);

            // Check if it's a constraint violation error
            if (errorMessage.includes('không thể xóa') || errorMessage.includes('vẫn còn')) {
                // Split error message into lines for better display
                const lines = errorMessage.split('\n').filter(line => line.trim());

                // Create formatted description
                const description = (
                    <div className="space-y-2 max-w-2xl">
                        {lines.map((line, idx) => {
                            const trimmedLine = line.trim();

                            // Main error message
                            if (idx === 0) {
                                return (
                                    <div key={idx} className="font-semibold text-red-700 flex items-center gap-2">
                                        <span>🚫</span>
                                        <span>{trimmedLine}</span>
                                    </div>
                                );
                            }

                            // Section headers (Chi tiết:, etc.)
                            if (trimmedLine.endsWith(':')) {
                                return (
                                    <div key={idx} className="font-medium text-gray-700 mt-2 flex items-center gap-1">
                                        <span>⚠️</span>
                                        <span>{trimmedLine}</span>
                                    </div>
                                );
                            }

                            // Detail lines with bullets
                            if (trimmedLine.startsWith('•')) {
                                return (
                                    <div key={idx} className="text-gray-600 flex items-start gap-2 pl-6">
                                        <span className="text-blue-600 mt-0.5">▸</span>
                                        <span>{trimmedLine.replace('•', '').trim()}</span>
                                    </div>
                                );
                            }

                            // Other lines
                            return (
                                <div key={idx} className="text-sm text-gray-600">
                                    {trimmedLine}
                                </div>
                            );
                        })}
                        <div className="pt-2 border-t border-red-200 text-xs text-gray-600 flex items-start gap-2 mt-3">
                            <span>💡</span>
                            <span>Cần xử lý các dữ liệu liên quan trước khi có thể xóa bệnh nhân này.</span>
                        </div>
                    </div>
                );

                toast.error('Không thể xóa bệnh nhân', {
                    description,
                    duration: 20000,
                    action: {
                        label: '✓ Đã hiểu',
                        onClick: () => { }
                    }
                });
            } else {
                toast.error(errorMessage);
            }
        }
    });

    const filteredPatients = patients?.filter((patient: any) => {
        const matchesSearch = !searchQuery ||
            patient.full_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            patient.email?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            patient.phone_number?.includes(searchQuery);

        const matchesGender = genderFilter === 'all' || patient.gender === genderFilter;
        const matchesStatus = statusFilter === 'all' ||
            (statusFilter === 'active' && patient.total_appointments > 0) ||
            (statusFilter === 'inactive' && patient.total_appointments === 0);

        return matchesSearch && matchesGender && matchesStatus;
    });

    const stats = {
        total: patients?.length || 0,
        male: patients?.filter((p: any) => p.gender === 'male').length || 0,
        female: patients?.filter((p: any) => p.gender === 'female').length || 0,
        active: patients?.filter((p: any) => p.total_appointments > 0).length || 0
    };

    const getGenderDisplay = (gender: string) => {
        if (gender === 'male') return 'Nam';
        if (gender === 'female') return 'Nữ';
        return 'Khác';
    };

    const getGenderColor = (gender: string) => {
        if (gender === 'male') return 'bg-blue-100 text-blue-700 border-blue-300';
        if (gender === 'female') return 'bg-pink-100 text-pink-700 border-pink-300';
        return 'bg-gray-100 text-gray-700 border-gray-300';
    };

    const handleView = (patient: any) => {
        setSelectedPatient(patient);
        setModalMode('view');
        setShowModal(true);
    };

    const handleEdit = (patient: any) => {
        setSelectedPatient(patient);
        setModalMode('edit');
        setShowModal(true);
    };

    const handleDelete = (patient: any) => {
        setPatientToDelete(patient);
        setShowDeleteModal(true);
    };

    const confirmDelete = async () => {
        if (patientToDelete) {
            await deleteMutation.mutateAsync(patientToDelete.user_id);
        }
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
                    <h1 className="text-3xl font-bold tracking-tight bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                        Quản lý Bệnh nhân
                    </h1>
                    <p className="text-muted-foreground mt-2">
                        Quản lý thông tin và hồ sơ bệnh nhân
                    </p>
                </div>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <Card key="total-patients" className="border-2 border-blue-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Tổng bệnh nhân</p>
                                <p className="text-2xl font-bold">{stats.total}</p>
                            </div>
                            <Users className="h-8 w-8 text-blue-600" />
                        </div>
                    </CardContent>
                </Card>
                <Card key="male-patients" className="border-2 border-purple-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Nam</p>
                                <p className="text-2xl font-bold">{stats.male}</p>
                            </div>
                            <Users className="h-8 w-8 text-purple-600" />
                        </div>
                    </CardContent>
                </Card>
                <Card key="female-patients" className="border-2 border-pink-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Nữ</p>
                                <p className="text-2xl font-bold">{stats.female}</p>
                            </div>
                            <Users className="h-8 w-8 text-pink-600" />
                        </div>
                    </CardContent>
                </Card>
                <Card key="active-patients" className="border-2 border-green-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Đang điều trị</p>
                                <p className="text-2xl font-bold">{stats.active}</p>
                            </div>
                            <UserCheck className="h-8 w-8 text-green-600" />
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
                                placeholder="Tìm kiếm theo tên, email, số điện thoại..."
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                className="pl-10"
                            />
                        </div>
                        <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                                <Button variant="outline" className="min-w-[150px]">
                                    <Filter className="h-4 w-4 mr-2" />
                                    Giới tính: {genderFilter === 'all' ? 'Tất cả' : getGenderDisplay(genderFilter)}
                                </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent>
                                <DropdownMenuItem onClick={() => setGenderFilter('all')}>
                                    Tất cả
                                </DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setGenderFilter('male')}>
                                    Nam
                                </DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setGenderFilter('female')}>
                                    Nữ
                                </DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setGenderFilter('other')}>
                                    Khác
                                </DropdownMenuItem>
                            </DropdownMenuContent>
                        </DropdownMenu>
                        <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                                <Button variant="outline" className="min-w-[150px]">
                                    <Filter className="h-4 w-4 mr-2" />
                                    Trạng thái: {statusFilter === 'all' ? 'Tất cả' : statusFilter === 'active' ? 'Đang điều trị' : 'Chưa khám'}
                                </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent>
                                <DropdownMenuItem onClick={() => setStatusFilter('all')}>
                                    Tất cả
                                </DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setStatusFilter('active')}>
                                    Đang điều trị
                                </DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setStatusFilter('inactive')}>
                                    Chưa khám
                                </DropdownMenuItem>
                            </DropdownMenuContent>
                        </DropdownMenu>
                    </div>
                </CardContent>
            </Card>

            {/* Patients Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {filteredPatients?.length === 0 ? (
                    <Card key="empty-state" className="col-span-full">
                        <CardContent className="flex flex-col items-center justify-center py-12">
                            <Users className="h-12 w-12 text-gray-300 mb-3" />
                            <p className="text-sm text-muted-foreground">Không tìm thấy bệnh nhân nào</p>
                        </CardContent>
                    </Card>
                ) : (
                    filteredPatients?.map((patient: any) => (
                        <Card key={patient.user_id} className="border-2 hover:border-blue-300 hover:shadow-lg transition-all">
                            <CardHeader className="pb-3 bg-gradient-to-br from-blue-50 to-purple-50">
                                <div className="flex items-start justify-between gap-2">
                                    <div className="flex-1 min-w-0">
                                        <CardTitle className="text-lg truncate">{patient.full_name || 'N/A'}</CardTitle>
                                        {patient.email && (
                                            <p className="text-xs text-muted-foreground truncate mt-1 flex items-center gap-1">
                                                <Mail className="h-3 w-3" />
                                                {patient.email}
                                            </p>
                                        )}
                                    </div>
                                    {patient.avatar_url ? (
                                        <img
                                            src={patient.avatar_url}
                                            alt={patient.full_name || 'Patient'}
                                            className="h-10 w-10 rounded-full object-cover shrink-0 border-2 border-blue-200"
                                        />
                                    ) : (
                                        <div className="h-10 w-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-500 flex items-center justify-center shrink-0">
                                            <UserCircle className="h-6 w-6 text-white" />
                                        </div>
                                    )}
                                </div>
                            </CardHeader>
                            <CardContent className="space-y-3">
                                <div className="flex items-center justify-between">
                                    <Badge className={getGenderColor(patient.gender)}>
                                        {getGenderDisplay(patient.gender)}
                                    </Badge>
                                    {patient.total_appointments > 0 ? (
                                        <Badge className="bg-green-100 text-green-700 border-green-300">
                                            <Activity className="h-3 w-3 mr-1" />
                                            Đang điều trị
                                        </Badge>
                                    ) : (
                                        <Badge variant="outline" className="text-gray-600">
                                            <UserX className="h-3 w-3 mr-1" />
                                            Chưa khám
                                        </Badge>
                                    )}
                                </div>

                                {patient.phone_number && (
                                    <div className="flex items-center gap-2 text-sm">
                                        <Phone className="h-4 w-4 text-muted-foreground" />
                                        <span className="text-muted-foreground">{patient.phone_number}</span>
                                    </div>
                                )}

                                {patient.date_of_birth && (
                                    <div className="flex items-center gap-2 text-sm">
                                        <Calendar className="h-4 w-4 text-muted-foreground" />
                                        <span className="text-muted-foreground">
                                            {format(new Date(patient.date_of_birth), 'dd/MM/yyyy', { locale: vi })}
                                        </span>
                                    </div>
                                )}

                                {patient.address && (
                                    <div className="flex items-start gap-2 text-sm">
                                        <MapPin className="h-4 w-4 text-muted-foreground shrink-0 mt-0.5" />
                                        <span className="text-muted-foreground line-clamp-2">{patient.address}</span>
                                    </div>
                                )}

                                <div className="grid grid-cols-2 gap-2 pt-2 border-t">
                                    <div className="text-center">
                                        <p className="text-xs text-muted-foreground">Lịch hẹn</p>
                                        <p className="text-lg font-semibold text-blue-600">{patient.total_appointments || 0}</p>
                                    </div>
                                    <div className="text-center">
                                        <p className="text-xs text-muted-foreground">Đơn thuốc</p>
                                        <p className="text-lg font-semibold text-purple-600">{patient.total_prescriptions || 0}</p>
                                    </div>
                                </div>

                                <div className="flex gap-2 pt-2 border-t">
                                    <Button variant="outline" size="sm" className="flex-1" onClick={() => handleView(patient)}>
                                        <Eye className="h-3 w-3 mr-1" />
                                        Xem
                                    </Button>
                                    <Button variant="outline" size="sm" className="flex-1" onClick={() => handleEdit(patient)}>
                                        <Edit className="h-3 w-3 mr-1" />
                                        Sửa
                                    </Button>
                                    <Button variant="outline" size="sm" className="text-red-600" onClick={() => handleDelete(patient)}>
                                        <Trash2 className="h-3 w-3" />
                                    </Button>
                                </div>
                            </CardContent>
                        </Card>
                    ))
                )}
            </div>

            {/* Modals */}
            {selectedPatient && (
                <PatientModal
                    patient={selectedPatient}
                    open={showModal}
                    onClose={() => {
                        setShowModal(false);
                        setSelectedPatient(null);
                    }}
                    onSuccess={() => {
                        refetch();
                    }}
                    mode={modalMode}
                />
            )}

            <DeleteConfirmModal
                open={showDeleteModal}
                onClose={() => {
                    setShowDeleteModal(false);
                    setPatientToDelete(null);
                }}
                onConfirm={confirmDelete}
                title="Xóa Bệnh nhân"
                description={`Bạn có chắc chắn muốn xóa bệnh nhân ${patientToDelete?.full_name || ''}? Hành động này không thể hoàn tác.`}
            />
        </div>
    );
}
