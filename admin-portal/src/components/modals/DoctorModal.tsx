"use client";

import { useState, useEffect } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Loader2, Mail, Phone, Calendar, MapPin, Award, Briefcase, User, Stethoscope, Star } from "lucide-react";
import { apiCall } from "@/utils/api";
import { toast } from "sonner";
import { format } from "date-fns";
import { vi } from "date-fns/locale";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";

interface DoctorModalProps {
    doctor: any;
    open: boolean;
    onClose: () => void;
    onSuccess: () => void;
    mode: 'view' | 'edit';
    specialties: any[];
}

export function DoctorModal({ doctor, open, onClose, onSuccess, mode, specialties }: DoctorModalProps) {
    const [loading, setLoading] = useState(false);
    const [formData, setFormData] = useState({
        full_name: '',
        email: '',
        phone_number: '',
        date_of_birth: '',
        gender: 'male',
        address: '',
        specialty_id: '',
        bio: '',
        experience_years: '',
        consultation_fee: '',
    });
    const [errors, setErrors] = useState<Record<string, string>>({});

    useEffect(() => {
        if (doctor) {
            setFormData({
                full_name: doctor.full_name || '',
                email: doctor.email || '',
                phone_number: doctor.phone_number || '',
                date_of_birth: doctor.date_of_birth ? new Date(doctor.date_of_birth).toISOString().split('T')[0] : '',
                gender: doctor.gender || 'male',
                address: doctor.address || '',
                specialty_id: doctor.specialty_id?.toString() || '',
                bio: doctor.bio || '',
                experience_years: doctor.experience_years?.toString() || '',
                consultation_fee: doctor.consultation_fee?.toString() || '',
            });
        }
        setErrors({});
    }, [doctor]);

    const validateForm = () => {
        const newErrors: Record<string, string> = {};

        // Validate phone number
        if (formData.phone_number && formData.phone_number.trim() !== '') {
            const phoneRegex = /^[0-9+\-\s()]{9,15}$/;
            if (!phoneRegex.test(formData.phone_number.trim())) {
                newErrors.phone_number = 'Số điện thoại không hợp lệ (9-15 ký tự, chỉ chứa số và +, -, (), khoảng trắng)';
            }
        }

        // Validate experience years
        if (formData.experience_years && formData.experience_years.trim() !== '') {
            const years = parseInt(formData.experience_years);
            if (isNaN(years) || years < 0) {
                newErrors.experience_years = 'Số năm kinh nghiệm phải là số không âm';
            } else if (years > 100) {
                newErrors.experience_years = 'Số năm kinh nghiệm không thể vượt quá 100 năm';
            }
        }

        // Validate consultation fee
        if (formData.consultation_fee && formData.consultation_fee.trim() !== '') {
            const fee = parseFloat(formData.consultation_fee);
            if (isNaN(fee) || fee < 0) {
                newErrors.consultation_fee = 'Phí khám phải là số không âm';
            } else if (fee > 100000000) {
                newErrors.consultation_fee = 'Phí khám quá lớn (tối đa 100,000,000 VNĐ)';
            }
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (mode === 'view') {
            onClose();
            return;
        }

        // Validate form
        if (!validateForm()) {
            toast.error('Vui lòng kiểm tra lại thông tin nhập vào', {
                description: 'Có một số trường không hợp lệ'
            });
            return;
        }

        setLoading(true);
        try {
            // Prepare data, convert empty strings to null
            // NOTE: Email is intentionally excluded (cannot be updated)
            const updateData: any = {
                full_name: formData.full_name || null,
                phone_number: formData.phone_number || null,
                date_of_birth: formData.date_of_birth && formData.date_of_birth.trim() !== '' ? formData.date_of_birth : null,
                gender: formData.gender || null,
                address: formData.address || null,
                specialty: doctor.specialty_name || null, // Send specialty name, not ID
                bio: formData.bio || null,
                experience_years: formData.experience_years ? parseInt(formData.experience_years) : null,
                consultation_fee: formData.consultation_fee ? parseFloat(formData.consultation_fee) : null,
            };

            await apiCall(`/admin/doctors/${doctor.user_id}`, 'PUT', updateData);
            toast.success('Cập nhật bác sĩ thành công!');
            onSuccess();
            onClose();
        } catch (error: any) {
            console.error('Error updating doctor:', error);
            const errorMessage = error?.message || 'Có lỗi xảy ra khi cập nhật bác sĩ';
            toast.error(errorMessage);
        } finally {
            setLoading(false);
        }
    };

    const isView = mode === 'view';

    // View mode with beautiful design
    if (isView) {
        return (
            <Dialog open={open} onOpenChange={onClose}>
                <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto" aria-describedby="doctor-view-description">
                    <DialogHeader className="space-y-3 border-b pb-4">
                        <div className="flex items-center gap-4">
                            {doctor.avatar_url ? (
                                <img
                                    src={doctor.avatar_url}
                                    alt={doctor.full_name}
                                    className="h-16 w-16 rounded-full object-cover border-4 border-teal-200"
                                />
                            ) : (
                                <div className="h-16 w-16 rounded-full bg-gradient-to-br from-teal-500 to-cyan-500 flex items-center justify-center">
                                    <User className="h-8 w-8 text-white" />
                                </div>
                            )}
                            <div className="flex-1">
                                <DialogTitle className="text-2xl bg-gradient-to-r from-teal-600 to-cyan-600 bg-clip-text text-transparent">
                                    Bs. {doctor.full_name}
                                </DialogTitle>
                                <div className="flex items-center gap-2 mt-1">
                                    <Badge className="bg-teal-100 text-teal-700 border-teal-300">
                                        {doctor.specialty_name || 'Chưa có chuyên khoa'}
                                    </Badge>
                                    {doctor.rating && (
                                        <div className="flex items-center gap-1 text-sm text-yellow-600">
                                            <Star className="h-4 w-4 fill-yellow-500" />
                                            <span className="font-semibold">{doctor.rating.toFixed(1)}</span>
                                        </div>
                                    )}
                                </div>
                            </div>
                        </div>
                        <DialogDescription id="doctor-view-description" className="sr-only">
                            Xem chi tiết thông tin của bác sĩ {doctor.full_name}
                        </DialogDescription>
                    </DialogHeader>

                    <div className="space-y-6 py-4">
                        {/* Contact Information */}
                        <Card className="border-2 border-teal-100">
                            <CardContent className="pt-6 space-y-4">
                                <h3 className="font-semibold text-lg text-teal-700 flex items-center gap-2">
                                    <Mail className="h-5 w-5" />
                                    Thông tin liên hệ
                                </h3>
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                        <Mail className="h-5 w-5 text-gray-500" />
                                        <div>
                                            <p className="text-xs text-gray-500">Email</p>
                                            <p className="text-sm font-medium">{doctor.email}</p>
                                        </div>
                                    </div>
                                    {doctor.phone_number && (
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                            <Phone className="h-5 w-5 text-gray-500" />
                                            <div>
                                                <p className="text-xs text-gray-500">Số điện thoại</p>
                                                <p className="text-sm font-medium">{doctor.phone_number}</p>
                                            </div>
                                        </div>
                                    )}
                                </div>
                            </CardContent>
                        </Card>

                        {/* Personal Information */}
                        <Card className="border-2 border-cyan-100">
                            <CardContent className="pt-6 space-y-4">
                                <h3 className="font-semibold text-lg text-cyan-700 flex items-center gap-2">
                                    <User className="h-5 w-5" />
                                    Thông tin cá nhân
                                </h3>
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    {doctor.date_of_birth && (
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                            <Calendar className="h-5 w-5 text-gray-500" />
                                            <div>
                                                <p className="text-xs text-gray-500">Ngày sinh</p>
                                                <p className="text-sm font-medium">
                                                    {format(new Date(doctor.date_of_birth), 'dd/MM/yyyy', { locale: vi })}
                                                </p>
                                            </div>
                                        </div>
                                    )}
                                    <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                        <User className="h-5 w-5 text-gray-500" />
                                        <div>
                                            <p className="text-xs text-gray-500">Giới tính</p>
                                            <p className="text-sm font-medium">
                                                {doctor.gender === 'male' ? 'Nam' : doctor.gender === 'female' ? 'Nữ' : 'Khác'}
                                            </p>
                                        </div>
                                    </div>
                                    {doctor.address && (
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg md:col-span-2">
                                            <MapPin className="h-5 w-5 text-gray-500" />
                                            <div>
                                                <p className="text-xs text-gray-500">Địa chỉ</p>
                                                <p className="text-sm font-medium">{doctor.address}</p>
                                            </div>
                                        </div>
                                    )}
                                </div>
                            </CardContent>
                        </Card>

                        {/* Professional Information */}
                        <Card className="border-2 border-purple-100">
                            <CardContent className="pt-6 space-y-4">
                                <h3 className="font-semibold text-lg text-purple-700 flex items-center gap-2">
                                    <Stethoscope className="h-5 w-5" />
                                    Thông tin chuyên môn
                                </h3>
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    {doctor.hospital_name && (
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg md:col-span-2">
                                            <Briefcase className="h-5 w-5 text-gray-500" />
                                            <div>
                                                <p className="text-xs text-gray-500">Bệnh viện</p>
                                                <p className="text-sm font-medium">{doctor.hospital_name}</p>
                                            </div>
                                        </div>
                                    )}
                                    {doctor.license_number && (
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                            <Award className="h-5 w-5 text-gray-500" />
                                            <div>
                                                <p className="text-xs text-gray-500">Số giấy phép hành nghề</p>
                                                <p className="text-sm font-medium">{doctor.license_number}</p>
                                            </div>
                                        </div>
                                    )}
                                    <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                        <Briefcase className="h-5 w-5 text-gray-500" />
                                        <div>
                                            <p className="text-xs text-gray-500">Kinh nghiệm</p>
                                            <p className="text-sm font-medium">{doctor.experience_years || 0} năm</p>
                                        </div>
                                    </div>
                                    {doctor.education && (
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg md:col-span-2">
                                            <Award className="h-5 w-5 text-gray-500" />
                                            <div>
                                                <p className="text-xs text-gray-500">Học vấn</p>
                                                <p className="text-sm font-medium">{doctor.education}</p>
                                            </div>
                                        </div>
                                    )}
                                    {doctor.consultation_fee && (
                                        <div className="flex items-center gap-3 p-3 bg-gradient-to-br from-green-50 to-emerald-50 rounded-lg border border-green-200">
                                            <Award className="h-5 w-5 text-green-600" />
                                            <div>
                                                <p className="text-xs text-green-600 font-semibold">Phí khám</p>
                                                <p className="text-sm font-bold text-green-700">{doctor.consultation_fee.toLocaleString('vi-VN')} VNĐ</p>
                                            </div>
                                        </div>
                                    )}
                                </div>

                                {/* Statistics */}
                                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 pt-4 border-t">
                                    <div className="flex items-center gap-3 p-3 bg-gradient-to-br from-blue-50 to-cyan-50 rounded-lg border border-blue-200">
                                        <Award className="h-5 w-5 text-blue-600" />
                                        <div>
                                            <p className="text-xs text-blue-600 font-semibold">Tổng lịch hẹn</p>
                                            <p className="text-lg font-bold text-blue-700">{doctor.total_appointments || 0}</p>
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-3 p-3 bg-gradient-to-br from-purple-50 to-pink-50 rounded-lg border border-purple-200">
                                        <User className="h-5 w-5 text-purple-600" />
                                        <div>
                                            <p className="text-xs text-purple-600 font-semibold">Tổng bệnh nhân</p>
                                            <p className="text-lg font-bold text-purple-700">{doctor.total_patients || 0}</p>
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-3 p-3 bg-gradient-to-br from-yellow-50 to-orange-50 rounded-lg border border-yellow-200">
                                        <Star className="h-5 w-5 text-yellow-600" />
                                        <div>
                                            <p className="text-xs text-yellow-600 font-semibold">Đánh giá</p>
                                            <p className="text-lg font-bold text-yellow-700">
                                                {doctor.rating ? `${doctor.rating.toFixed(1)} ⭐` : 'Chưa có'}
                                                {doctor.review_count > 0 && <span className="text-xs font-normal ml-1">({doctor.review_count})</span>}
                                            </p>
                                        </div>
                                    </div>
                                </div>

                                {doctor.bio && (
                                    <div className="p-4 bg-gradient-to-br from-purple-50 to-pink-50 rounded-lg border border-purple-200 mt-4">
                                        <p className="text-xs text-purple-600 font-semibold mb-2">Tiểu sử</p>
                                        <p className="text-sm text-gray-700 leading-relaxed">{doctor.bio}</p>
                                    </div>
                                )}
                            </CardContent>
                        </Card>
                    </div>

                    <div className="flex justify-end gap-2 pt-4 border-t">
                        <Button type="button" variant="outline" onClick={onClose}>
                            Đóng
                        </Button>
                    </div>
                </DialogContent>
            </Dialog >
        );
    }

    // Edit mode
    return (
        <Dialog open={open} onOpenChange={onClose}>
            <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>Chỉnh sửa Bác sĩ</DialogTitle>
                    <DialogDescription>Cập nhật thông tin bác sĩ</DialogDescription>
                </DialogHeader>
                <form onSubmit={handleSubmit} className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="full_name">Họ và tên *</Label>
                            <Input
                                id="full_name"
                                value={formData.full_name}
                                onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
                                required
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="email">Email * <span className="text-xs text-muted-foreground">(không thể sửa)</span></Label>
                            <Input
                                id="email"
                                type="email"
                                value={formData.email}
                                disabled
                                className="bg-muted cursor-not-allowed"
                                title="Email là định danh duy nhất và không thể thay đổi"
                            />
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="phone_number">Số điện thoại</Label>
                            <Input
                                id="phone_number"
                                value={formData.phone_number}
                                onChange={(e) => {
                                    setFormData({ ...formData, phone_number: e.target.value });
                                    if (errors.phone_number) {
                                        setErrors({ ...errors, phone_number: '' });
                                    }
                                }}
                                className={errors.phone_number ? 'border-red-500' : ''}
                            />
                            {errors.phone_number && (
                                <p className="text-xs text-red-500">{errors.phone_number}</p>
                            )}
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="date_of_birth">Ngày sinh</Label>
                            <Input
                                id="date_of_birth"
                                type="date"
                                value={formData.date_of_birth}
                                onChange={(e) => setFormData({ ...formData, date_of_birth: e.target.value })}
                            />
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="gender">Giới tính</Label>
                            <Select
                                value={formData.gender}
                                onValueChange={(value) => setFormData({ ...formData, gender: value })}
                            >
                                <SelectTrigger>
                                    <SelectValue />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="male">Nam</SelectItem>
                                    <SelectItem value="female">Nữ</SelectItem>
                                    <SelectItem value="other">Khác</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="specialty_id">Chuyên khoa</Label>
                            <Select
                                value={formData.specialty_id}
                                onValueChange={(value) => setFormData({ ...formData, specialty_id: value })}
                            >
                                <SelectTrigger>
                                    <SelectValue placeholder="Chọn chuyên khoa" />
                                </SelectTrigger>
                                <SelectContent>
                                    {specialties.map((spec) => (
                                        <SelectItem key={spec.id} value={spec.id.toString()}>
                                            {spec.name}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="experience_years">Số năm kinh nghiệm</Label>
                            <Input
                                id="experience_years"
                                type="number"
                                min="0"
                                max="100"
                                value={formData.experience_years}
                                onChange={(e) => {
                                    setFormData({ ...formData, experience_years: e.target.value });
                                    if (errors.experience_years) {
                                        setErrors({ ...errors, experience_years: '' });
                                    }
                                }}
                                className={errors.experience_years ? 'border-red-500' : ''}
                            />
                            {errors.experience_years && (
                                <p className="text-xs text-red-500">{errors.experience_years}</p>
                            )}
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="consultation_fee">Phí khám (VNĐ)</Label>
                            <Input
                                id="consultation_fee"
                                type="number"
                                min="0"
                                max="100000000"
                                value={formData.consultation_fee}
                                onChange={(e) => {
                                    setFormData({ ...formData, consultation_fee: e.target.value });
                                    if (errors.consultation_fee) {
                                        setErrors({ ...errors, consultation_fee: '' });
                                    }
                                }}
                                className={errors.consultation_fee ? 'border-red-500' : ''}
                                placeholder="Nhập phí khám"
                            />
                            {errors.consultation_fee && (
                                <p className="text-xs text-red-500">{errors.consultation_fee}</p>
                            )}
                        </div>
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="address">Địa chỉ</Label>
                        <Input
                            id="address"
                            value={formData.address}
                            onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                        />
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="bio">Tiểu sử</Label>
                        <Textarea
                            id="bio"
                            value={formData.bio}
                            onChange={(e) => setFormData({ ...formData, bio: e.target.value })}
                            rows={3}
                        />
                    </div>

                    <div className="flex justify-end gap-2 pt-4">
                        <Button type="button" variant="outline" onClick={onClose}>
                            Hủy
                        </Button>
                        <Button type="submit" disabled={loading}>
                            {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                            Lưu thay đổi
                        </Button>
                    </div>
                </form>
            </DialogContent>
        </Dialog>
    );
}
