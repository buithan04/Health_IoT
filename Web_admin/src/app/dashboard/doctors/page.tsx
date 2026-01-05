"use client";

import { useState } from "react";
import { apiCall } from "@/utils/api";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  Stethoscope,
  Search,
  Filter,
  Eye,
  Edit,
  Trash2,
  Plus,
  Loader2,
  RefreshCw,
  UserCheck,
  Award,
  Phone,
  Mail,
  Calendar,
  MapPin,
  FileText,
  Star,
  Clock,
  Users,
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
import { DoctorModal } from "@/components/modals/DoctorModal";
import { DeleteConfirmModal } from "@/components/modals/DeleteConfirmModal";
import { toast } from "sonner";

export default function DoctorsPage() {
  const [searchQuery, setSearchQuery] = useState("");
  const [specialtyFilter, setSpecialtyFilter] = useState("all");
  const [statusFilter, setStatusFilter] = useState("all");
  const [selectedDoctor, setSelectedDoctor] = useState<any>(null);
  const [modalMode, setModalMode] = useState<'view' | 'edit'>('view');
  const [showModal, setShowModal] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [doctorToDelete, setDoctorToDelete] = useState<any>(null);
  const [showAddModal, setShowAddModal] = useState(false);

  const queryClient = useQueryClient();

  const { data: doctors, isLoading, refetch } = useQuery({
    queryKey: ['allDoctors'],
    queryFn: async () => {
      const res = await apiCall('/admin/doctors');
      return res?.doctors || [];
    },
    refetchInterval: 30000
  });

  const deleteMutation = useMutation({
    mutationFn: async (doctorId: number) => {
      await apiCall(`/admin/doctors/${doctorId}`, 'DELETE');
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['allDoctors'] });
      setShowDeleteModal(false);
      setDoctorToDelete(null);
      toast.success('Xóa bác sĩ thành công', {
        description: 'Đã xóa bác sĩ và tất cả dữ liệu liên quan'
      });
    },
    onError: (error: any) => {
      console.error('Error deleting doctor:', error);
      setShowDeleteModal(false);

      const errorMsg = error?.message || 'Có lỗi xảy ra khi xóa bác sĩ';

      // Parse error message to display constraint details clearly
      if (errorMsg.includes('còn dữ liệu liên quan') || errorMsg.includes('Không thể xóa')) {
        // Extract doctor name from error message
        let doctorName = '';
        const nameMatch = errorMsg.match(/"([^"]+)"/);
        if (nameMatch) {
          doctorName = nameMatch[1];
        }

        // Split message into lines
        const lines = errorMsg.split('\n').map(line => line.trim()).filter(line => line);

        // Extract constraint summary (from first line)
        let constraintSummary = '';
        if (lines[0] && lines[0].includes('còn dữ liệu liên quan:')) {
          const parts = lines[0].split('còn dữ liệu liên quan:');
          if (parts.length > 1) {
            constraintSummary = parts[1].replace(/\.$/, '').trim();
          }
        }

        // Extract detailed breakdown
        const detailsList: string[] = [];
        let inDetailsSection = false;

        for (const line of lines) {
          if (line.includes('Chi tiết:')) {
            inDetailsSection = true;
            continue;
          }
          if (line.includes('Vui lòng xóa')) {
            break;
          }
          if (inDetailsSection && line) {
            // Remove bullet points and extra spaces
            const cleanLine = line.replace(/^•\s*/, '').replace(/^\s*•\s*/, '').trim();
            if (cleanLine) {
              detailsList.push(cleanLine);
            }
          }
        }

        // Build title
        const title = doctorName
          ? `🚫 KHÔNG THỂ XÓA ${doctorName.toUpperCase()}`
          : '🚫 KHÔNG THỂ XÓA BÁC SĨ NÀY';

        // Build formatted description
        let description = '⚠️ Bác sĩ này có dữ liệu liên quan:\n\n';

        if (constraintSummary) {
          description += `📊 ${constraintSummary}\n\n`;
        }

        if (detailsList.length > 0) {
          description += '📋 CHI TIẾT:\n';
          detailsList.forEach(detail => {
            description += `  ▸ ${detail}\n`;
          });
          description += '\n';
        }

        description += '💡 Vui lòng xóa hoặc chuyển giao dữ liệu liên quan trước.';

        toast.error(title, {
          description: description,
          duration: 20000,
          action: {
            label: '✓ Đã hiểu',
            onClick: () => { }
          },
          className: 'max-w-xl',
          style: {
            whiteSpace: 'pre-line',
            lineHeight: '1.6',
            fontSize: '0.95rem'
          }
        });
      } else {
        toast.error('Có lỗi xảy ra khi xóa bác sĩ', {
          description: errorMsg,
          duration: 8000
        });
      }
    }
  });

  // Get unique specialties from doctors data
  const specialties = [...new Set(doctors?.map((d: any) => d.specialty_name).filter(Boolean))]
    .map((name, idx) => ({ id: idx + 1, name }));

  const filteredDoctors = doctors?.filter((doctor: any) => {
    const matchesSearch = !searchQuery ||
      doctor.full_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      doctor.email?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      doctor.specialty_name?.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesSpecialty = specialtyFilter === 'all' || doctor.specialty_name === specialtyFilter;
    const matchesStatus = statusFilter === 'all' ||
      (statusFilter === 'active' && doctor.total_appointments > 0) ||
      (statusFilter === 'inactive' && doctor.total_appointments === 0);

    return matchesSearch && matchesSpecialty && matchesStatus;
  });

  const stats = {
    total: doctors?.length || 0,
    specialties: specialties.length,
    active: doctors?.filter((d: any) => d.total_appointments > 0).length || 0,
    topRated: doctors?.filter((d: any) => d.rating >= 4.5).length || 0
  };

  const getStatusColor = (totalAppointments: number) => {
    if (totalAppointments > 10) return 'bg-green-100 text-green-700 border-green-300';
    if (totalAppointments > 0) return 'bg-blue-100 text-blue-700 border-blue-300';
    return 'bg-gray-100 text-gray-700 border-gray-300';
  };

  const getStatusLabel = (totalAppointments: number) => {
    if (totalAppointments > 10) return 'Bận';
    if (totalAppointments > 0) return 'Đang khám';
    return 'Rảnh';
  };

  const handleView = (doctor: any) => {
    setSelectedDoctor(doctor);
    setModalMode('view');
    setShowModal(true);
  };

  const handleEdit = (doctor: any) => {
    setSelectedDoctor(doctor);
    setModalMode('edit');
    setShowModal(true);
  };

  const handleDelete = (doctor: any) => {
    setDoctorToDelete(doctor);
    setShowDeleteModal(true);
  };

  const confirmDelete = async () => {
    if (doctorToDelete) {
      await deleteMutation.mutateAsync(doctorToDelete.user_id);
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
          <h1 className="text-3xl font-bold tracking-tight bg-gradient-to-r from-teal-600 to-cyan-600 bg-clip-text text-transparent">
            Quản lý Bác sĩ
          </h1>
          <p className="text-muted-foreground mt-2">
            Quản lý thông tin và lịch làm việc của bác sĩ
          </p>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card className="border-2 border-teal-200">
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Tổng bác sĩ</p>
                <p className="text-2xl font-bold">{stats.total}</p>
              </div>
              <Stethoscope className="h-8 w-8 text-teal-600" />
            </div>
          </CardContent>
        </Card>
        <Card className="border-2 border-cyan-200">
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Chuyên khoa</p>
                <p className="text-2xl font-bold">{stats.specialties}</p>
              </div>
              <Award className="h-8 w-8 text-cyan-600" />
            </div>
          </CardContent>
        </Card>
        <Card className="border-2 border-green-200">
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Đang làm việc</p>
                <p className="text-2xl font-bold">{stats.active}</p>
              </div>
              <UserCheck className="h-8 w-8 text-green-600" />
            </div>
          </CardContent>
        </Card>
        <Card className="border-2 border-yellow-200">
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Đánh giá cao</p>
                <p className="text-2xl font-bold">{stats.topRated}</p>
              </div>
              <Star className="h-8 w-8 text-yellow-600" />
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
                placeholder="Tìm kiếm theo tên, email, chuyên khoa..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10"
              />
            </div>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" className="min-w-[200px]">
                  <Filter className="h-4 w-4 mr-2" />
                  Chuyên khoa: {specialtyFilter === 'all' ? 'Tất cả' : specialtyFilter}
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent className="max-h-[300px] overflow-y-auto">
                <DropdownMenuItem key="all" onClick={() => setSpecialtyFilter('all')}>
                  Tất cả chuyên khoa
                </DropdownMenuItem>
                {specialties.map((spec: any) => (
                  <DropdownMenuItem key={spec.id} onClick={() => setSpecialtyFilter(spec.name)}>
                    {spec.name}
                  </DropdownMenuItem>
                ))}
              </DropdownMenuContent>
            </DropdownMenu>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" className="min-w-[150px]">
                  <Filter className="h-4 w-4 mr-2" />
                  Trạng thái: {statusFilter === 'all' ? 'Tất cả' : statusFilter === 'active' ? 'Đang khám' : 'Rảnh'}
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent>
                <DropdownMenuItem onClick={() => setStatusFilter('all')}>
                  Tất cả
                </DropdownMenuItem>
                <DropdownMenuItem onClick={() => setStatusFilter('active')}>
                  Đang khám
                </DropdownMenuItem>
                <DropdownMenuItem onClick={() => setStatusFilter('inactive')}>
                  Rảnh
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </CardContent>
      </Card>

      {/* Doctors Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredDoctors?.length === 0 ? (
          <Card className="col-span-full">
            <CardContent className="flex flex-col items-center justify-center py-12">
              <Stethoscope className="h-12 w-12 text-gray-300 mb-3" />
              <p className="text-sm text-muted-foreground">Không tìm thấy bác sĩ nào</p>
            </CardContent>
          </Card>
        ) : (
          filteredDoctors?.map((doctor: any) => (
            <Card key={doctor.user_id} className="border-2 hover:border-teal-300 hover:shadow-lg transition-all">
              <CardHeader className="pb-3 bg-gradient-to-br from-teal-50 to-cyan-50">
                <div className="flex items-start justify-between gap-2">
                  <div className="flex-1 min-w-0">
                    <CardTitle className="text-lg truncate">
                      {doctor.full_name ? `Bs. ${doctor.full_name}` : 'N/A'}
                    </CardTitle>
                    {doctor.email && (
                      <p className="text-xs text-muted-foreground truncate mt-1 flex items-center gap-1">
                        <Mail className="h-3 w-3" />
                        {doctor.email}
                      </p>
                    )}
                  </div>
                  {doctor.avatar_url ? (
                    <img
                      src={doctor.avatar_url}
                      alt={doctor.full_name || 'Doctor'}
                      className="h-10 w-10 rounded-full object-cover shrink-0 border-2 border-teal-200"
                    />
                  ) : (
                    <div className="h-10 w-10 rounded-full bg-gradient-to-br from-teal-500 to-cyan-500 flex items-center justify-center shrink-0">
                      <UserCircle className="h-6 w-6 text-white" />
                    </div>
                  )}
                </div>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex items-center justify-between">
                  <Badge className="bg-teal-100 text-teal-700 border-teal-300">
                    {doctor.specialty_name || 'Chưa có chuyên khoa'}
                  </Badge>
                  <Badge className={getStatusColor(doctor.total_appointments)}>
                    <Clock className="h-3 w-3 mr-1" />
                    {getStatusLabel(doctor.total_appointments)}
                  </Badge>
                </div>

                {/* Always show phone section - consistent height */}
                <div className="flex items-center gap-2 text-sm min-h-[24px]">
                  <Phone className="h-4 w-4 text-muted-foreground" />
                  <span className="text-muted-foreground">
                    {doctor.phone_number || 'Chưa cập nhật'}
                  </span>
                </div>

                {/* Always show experience section - consistent height */}
                <div className="flex items-center gap-2 text-sm min-h-[24px]">
                  <Award className="h-4 w-4 text-muted-foreground" />
                  <span className="text-muted-foreground">
                    {doctor.experience_years ? `${doctor.experience_years} năm kinh nghiệm` : 'Chưa cập nhật'}
                  </span>
                </div>

                {/* Always show rating section - consistent height */}
                <div className="flex items-center gap-2 text-sm min-h-[24px]">
                  <Star className={`h-4 w-4 ${doctor.rating > 0 ? 'text-yellow-500 fill-yellow-500' : 'text-gray-300'}`} />
                  <span className={doctor.rating > 0 ? 'font-semibold text-yellow-700' : 'text-muted-foreground'}>
                    {doctor.rating > 0 ? `${doctor.rating.toFixed(1)} / 5.0` : 'Chưa có đánh giá'}
                  </span>
                </div>

                {/* Always show bio section - consistent height */}
                <div className="min-h-[32px]">
                  <p className="text-xs text-muted-foreground line-clamp-2">
                    {doctor.bio || 'Chưa có giới thiệu'}
                  </p>
                </div>

                <div className="grid grid-cols-2 gap-2 pt-2 border-t">
                  <div className="text-center">
                    <p className="text-xs text-muted-foreground">Lịch hẹn</p>
                    <p className="text-lg font-semibold text-teal-600">{doctor.total_appointments || 0}</p>
                  </div>
                  <div className="text-center">
                    <p className="text-xs text-muted-foreground">Bệnh nhân</p>
                    <p className="text-lg font-semibold text-cyan-600">{doctor.total_patients || 0}</p>
                  </div>
                </div>

                <div className="flex gap-2 pt-2 border-t">
                  <Button variant="outline" size="sm" className="flex-1" onClick={() => handleView(doctor)}>
                    <Eye className="h-3 w-3 mr-1" />
                    Xem
                  </Button>
                  <Button variant="outline" size="sm" className="flex-1" onClick={() => handleEdit(doctor)}>
                    <Edit className="h-3 w-3 mr-1" />
                    Sửa
                  </Button>
                  <Button variant="outline" size="sm" className="text-red-600" onClick={() => handleDelete(doctor)}>
                    <Trash2 className="h-3 w-3" />
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))
        )}
      </div>

      {/* Modals */}
      {selectedDoctor && (
        <DoctorModal
          doctor={selectedDoctor}
          open={showModal}
          onClose={() => {
            setShowModal(false);
            setSelectedDoctor(null);
          }}
          onSuccess={() => {
            refetch();
          }}
          mode={modalMode}
          specialties={specialties}
        />
      )}

      <DeleteConfirmModal
        open={showDeleteModal}
        onClose={() => {
          setShowDeleteModal(false);
          setDoctorToDelete(null);
        }}
        onConfirm={confirmDelete}
        title="Xóa Bác sĩ"
        description={`Bạn có chắc chắn muốn xóa bác sĩ ${doctorToDelete?.full_name || ''}? Hành động này không thể hoàn tác.`}
      />
    </div>
  );
}
