"use client";

import { useState, useEffect } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Loader2, User, Mail, Phone, Calendar, MapPin, Activity, Heart, Clock, UserCircle, Scale, Ruler } from "lucide-react";
import { apiCall } from "@/utils/api";
import { toast } from "sonner";
import { format } from "date-fns";
import { vi } from "date-fns/locale";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";

interface PatientModalProps {
    patient: any;
    open: boolean;
    onClose: () => void;
    onSuccess: () => void;
    mode: 'view' | 'edit';
}

export function PatientModal({ patient, open, onClose, onSuccess, mode }: PatientModalProps) {
    const [loading, setLoading] = useState(false);
    const [formData, setFormData] = useState({
        full_name: '',
        email: '',
        phone_number: '',
        date_of_birth: '',
        gender: 'male',
        address: '',
        blood_type: undefined as string | undefined,
        medical_history: '',
        height: '',
        weight: '',
        allergies: '',
        insurance_number: '',
    });
    const [errors, setErrors] = useState<Record<string, string>>({});

    useEffect(() => {
        if (patient) {
            setFormData({
                full_name: patient.full_name || '',
                email: patient.email || '',
                phone_number: patient.phone_number || '',
                date_of_birth: patient.date_of_birth ? new Date(patient.date_of_birth).toISOString().split('T')[0] : '',
                gender: patient.gender || 'male',
                address: patient.address || '',
                blood_type: patient.blood_type || undefined,
                medical_history: patient.medical_history || '',
                height: patient.height?.toString() || '',
                weight: patient.weight?.toString() || '',
                allergies: patient.allergies || '',
                insurance_number: patient.insurance_number || '',
            });
        }
        setErrors({});
    }, [patient]);

    const validateForm = () => {
        const newErrors: Record<string, string> = {};

        // Validate phone number
        if (formData.phone_number && formData.phone_number.trim() !== '') {
            const phoneRegex = /^[0-9+\-\s()]{9,15}$/;
            if (!phoneRegex.test(formData.phone_number.trim())) {
                newErrors.phone_number = 'Số điện thoại không hợp lệ (9-15 ký tự, chỉ chứa số và +, -, (), khoảng trắng)';
            }
        }

        // Validate height
        if (formData.height && formData.height.trim() !== '') {
            const height = parseFloat(formData.height);
            if (isNaN(height) || height < 0 || height > 300) {
                newErrors.height = 'Chiều cao không hợp lệ (0-300 cm)';
            }
        }

        // Validate weight
        if (formData.weight && formData.weight.trim() !== '') {
            const weight = parseFloat(formData.weight);
            if (isNaN(weight) || weight < 0 || weight > 500) {
                newErrors.weight = 'Cân nặng không hợp lệ (0-500 kg)';
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
            // NOTE: Email is intentionally excluded (cannot be updated)
            const updateData: any = {
                full_name: formData.full_name || null,
                phone_number: formData.phone_number || null,
                date_of_birth: formData.date_of_birth && formData.date_of_birth.trim() !== '' ? formData.date_of_birth : null,
                gender: formData.gender || null,
                address: formData.address || null,
                blood_type: formData.blood_type && formData.blood_type !== 'none' ? formData.blood_type : null,
                medical_history: formData.medical_history || null,
                height: formData.height ? parseFloat(formData.height) : null,
                weight: formData.weight ? parseFloat(formData.weight) : null,
                allergies: formData.allergies || null,
                insurance_number: formData.insurance_number || null,
            };

            await apiCall(`/admin/patients/${patient.user_id}`, 'PUT', updateData);
            toast.success('Cập nhật bệnh nhân thành công!');
            onSuccess();
            onClose();
        } catch (error: any) {
            console.error('Error updating patient:', error);
            const errorMessage = error?.message || 'Có lỗi xảy ra khi cập nhật bệnh nhân';
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
                <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto" aria-describedby="patient-view-description">
                    <DialogHeader className="space-y-3 border-b pb-4">
                        <div className="flex items-center gap-4">
                            {patient.avatar_url ? (
                                <img
                                    src={patient.avatar_url}
                                    alt={patient.full_name}
                                    className="h-16 w-16 rounded-full object-cover border-4 border-blue-200"
                                />
                            ) : (
                                <div className="h-16 w-16 rounded-full bg-gradient-to-br from-blue-500 to-purple-500 flex items-center justify-center">
                                    <UserCircle className="h-8 w-8 text-white" />
                                </div>
                            )}
                            <div className="flex-1">
                                <DialogTitle className="text-2xl bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                                    {patient.full_name}
                                </DialogTitle>
                                <div className="flex items-center gap-2 mt-1">
                                    <Badge className="bg-blue-100 text-blue-700 border-blue-300">
                                        Bệnh nhân
                                    </Badge>
                                    {patient.blood_type && (
                                        <Badge className="bg-red-100 text-red-700 border-red-300">
                                            <Heart className="h-3 w-3 mr-1" />
                                            Nhóm máu {patient.blood_type}
                                        </Badge>
                                    )}
                                </div>
                            </div>
                        </div>
                        <DialogDescription id="patient-view-description" className="sr-only">
                            Xem chi tiết thông tin của bệnh nhân {patient.full_name}
                        </DialogDescription>
                    </DialogHeader>

                    <div className="space-y-6 py-4">
                        {/* Contact Information */}
                        <Card className="border-2 border-blue-100">
                            <CardContent className="pt-6 space-y-4">
                                <h3 className="font-semibold text-lg text-blue-700 flex items-center gap-2">
                                    <Mail className="h-5 w-5" />
                                    Thông tin liên hệ
                                </h3>
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                        <Mail className="h-5 w-5 text-gray-500" />
                                        <div>
                                            <p className="text-xs text-gray-500">Email</p>
                                            <p className="text-sm font-medium">{patient.email}</p>
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                        <Phone className="h-5 w-5 text-gray-500" />
                                        <div>
                                            <p className="text-xs text-gray-500">Số điện thoại</p>
                                            <p className="text-sm font-medium">{patient.phone_number || 'Chưa cập nhật'}</p>
                                        </div>
                                    </div>
                                </div>
                            </CardContent>
                        </Card>

                        {/* Personal Information */}
                        <Card className="border-2 border-purple-100">
                            <CardContent className="pt-6 space-y-4">
                                <h3 className="font-semibold text-lg text-purple-700 flex items-center gap-2">
                                    <User className="h-5 w-5" />
                                    Thông tin cá nhân
                                </h3>
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    {patient.date_of_birth && (
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                            <Calendar className="h-5 w-5 text-gray-500" />
                                            <div>
                                                <p className="text-xs text-gray-500">Ngày sinh</p>
                                                <p className="text-sm font-medium">
                                                    {format(new Date(patient.date_of_birth), 'dd/MM/yyyy', { locale: vi })}
                                                </p>
                                            </div>
                                        </div>
                                    )}
                                    <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                        <User className="h-5 w-5 text-gray-500" />
                                        <div>
                                            <p className="text-xs text-gray-500">Giới tính</p>
                                            <p className="text-sm font-medium">
                                                {patient.gender === 'male' ? 'Nam' : patient.gender === 'female' ? 'Nữ' : 'Khác'}
                                            </p>
                                        </div>
                                    </div>
                                    {patient.address && (
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg md:col-span-2">
                                            <MapPin className="h-5 w-5 text-gray-500" />
                                            <div>
                                                <p className="text-xs text-gray-500">Địa chỉ</p>
                                                <p className="text-sm font-medium">{patient.address}</p>
                                            </div>
                                        </div>
                                    )}
                                </div>
                            </CardContent>
                        </Card>

                        {/* Medical Information */}
                        <Card className="border-2 border-green-100">
                            <CardContent className="pt-6 space-y-4">
                                <h3 className="font-semibold text-lg text-green-700 flex items-center gap-2">
                                    <Activity className="h-5 w-5" />
                                    Thông tin y tế
                                </h3>
                                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                    <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                        <Heart className="h-5 w-5 text-gray-500" />
                                        <div>
                                            <p className="text-xs text-gray-500">Nhóm máu</p>
                                            <p className="text-sm font-medium">{patient.blood_type || 'Chưa xác định'}</p>
                                        </div>
                                    </div>
                                    {patient.height && (
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                            <Ruler className="h-5 w-5 text-gray-500" />
                                            <div>
                                                <p className="text-xs text-gray-500">Chiều cao</p>
                                                <p className="text-sm font-medium">{patient.height} cm</p>
                                            </div>
                                        </div>
                                    )}
                                    {patient.weight && (
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                            <Scale className="h-5 w-5 text-gray-500" />
                                            <div>
                                                <p className="text-xs text-gray-500">Cân nặng</p>
                                                <p className="text-sm font-medium">{patient.weight} kg</p>
                                            </div>
                                        </div>
                                    )}
                                </div>
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    {patient.insurance_number && (
                                        <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                            <Activity className="h-5 w-5 text-gray-500" />
                                            <div>
                                                <p className="text-xs text-gray-500">Số BHYT</p>
                                                <p className="text-sm font-medium">{patient.insurance_number}</p>
                                            </div>
                                        </div>
                                    )}
                                    <div className="flex items-center gap-3 p-3 bg-gradient-to-br from-blue-50 to-cyan-50 rounded-lg border border-blue-200">
                                        <Activity className="h-5 w-5 text-blue-600" />
                                        <div>
                                            <p className="text-xs text-blue-600 font-semibold">Tổng lịch khám</p>
                                            <p className="text-lg font-bold text-blue-700">{patient.total_appointments || 0}</p>
                                        </div>
                                    </div>
                                </div>
                                {patient.allergies && (
                                    <div className="p-4 bg-gradient-to-br from-orange-50 to-red-50 rounded-lg border border-orange-200">
                                        <p className="text-xs text-orange-600 font-semibold mb-2">Dị ứng</p>
                                        <p className="text-sm text-gray-700 leading-relaxed">{patient.allergies}</p>
                                    </div>
                                )}
                                {patient.medical_history && (
                                    <div className="p-4 bg-gradient-to-br from-green-50 to-emerald-50 rounded-lg border border-green-200">
                                        <p className="text-xs text-green-600 font-semibold mb-2">Tiền sử bệnh</p>
                                        <p className="text-sm text-gray-700 leading-relaxed">{patient.medical_history}</p>
                                    </div>
                                )}
                            </CardContent>
                        </Card>

                        {/* Account Information */}
                        {patient.created_at && (
                            <Card className="border-2 border-gray-100">
                                <CardContent className="pt-6">
                                    <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                                        <Clock className="h-5 w-5 text-gray-500" />
                                        <div>
                                            <p className="text-xs text-gray-500">Ngày tạo tài khoản</p>
                                            <p className="text-sm font-medium">
                                                {format(new Date(patient.created_at), 'dd/MM/yyyy HH:mm', { locale: vi })}
                                            </p>
                                        </div>
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

    // Edit mode
    return (
        <Dialog open={open} onOpenChange={onClose}>
            <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>Chỉnh sửa Bệnh nhân</DialogTitle>
                    <DialogDescription>Cập nhật thông tin bệnh nhân</DialogDescription>
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

                    <div className="grid grid-cols-3 gap-4">
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
                            <Label htmlFor="height">Chiều cao (cm)</Label>
                            <Input
                                id="height"
                                type="number"
                                min="0"
                                max="300"
                                step="0.1"
                                value={formData.height}
                                onChange={(e) => {
                                    setFormData({ ...formData, height: e.target.value });
                                    if (errors.height) {
                                        setErrors({ ...errors, height: '' });
                                    }
                                }}
                                className={errors.height ? 'border-red-500' : ''}
                            />
                            {errors.height && (
                                <p className="text-xs text-red-500">{errors.height}</p>
                            )}
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="weight">Cân nặng (kg)</Label>
                            <Input
                                id="weight"
                                type="number"
                                min="0"
                                max="500"
                                step="0.1"
                                value={formData.weight}
                                onChange={(e) => {
                                    setFormData({ ...formData, weight: e.target.value });
                                    if (errors.weight) {
                                        setErrors({ ...errors, weight: '' });
                                    }
                                }}
                                className={errors.weight ? 'border-red-500' : ''}
                            />
                            {errors.weight && (
                                <p className="text-xs text-red-500">{errors.weight}</p>
                            )}
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="blood_type">Nhóm máu</Label>
                            <Select
                                value={formData.blood_type || "none"}
                                onValueChange={(value) => setFormData({ ...formData, blood_type: value === "none" ? undefined : value })}
                            >
                                <SelectTrigger>
                                    <SelectValue placeholder="Chọn nhóm máu" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="none">Chưa xác định</SelectItem>
                                    <SelectItem value="A">A</SelectItem>
                                    <SelectItem value="B">B</SelectItem>
                                    <SelectItem value="AB">AB</SelectItem>
                                    <SelectItem value="O">O</SelectItem>
                                    <SelectItem value="A+">A+</SelectItem>
                                    <SelectItem value="A-">A-</SelectItem>
                                    <SelectItem value="B+">B+</SelectItem>
                                    <SelectItem value="B-">B-</SelectItem>
                                    <SelectItem value="AB+">AB+</SelectItem>
                                    <SelectItem value="AB-">AB-</SelectItem>
                                    <SelectItem value="O+">O+</SelectItem>
                                    <SelectItem value="O-">O-</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="insurance_number">Số BHYT</Label>
                            <Input
                                id="insurance_number"
                                value={formData.insurance_number}
                                onChange={(e) => setFormData({ ...formData, insurance_number: e.target.value })}
                                placeholder="Nhập số bảo hiểm y tế"
                            />
                        </div>
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="address">Địa chỉ</Label>
                        <Textarea
                            id="address"
                            value={formData.address}
                            onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                            rows={2}
                        />
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="allergies">Dị ứng</Label>
                        <Textarea
                            id="allergies"
                            value={formData.allergies}
                            onChange={(e) => setFormData({ ...formData, allergies: e.target.value })}
                            rows={2}
                            placeholder="Nhập thông tin dị ứng của bệnh nhân..."
                        />
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="medical_history">Tiền sử bệnh</Label>
                        <Textarea
                            id="medical_history"
                            value={formData.medical_history}
                            onChange={(e) => setFormData({ ...formData, medical_history: e.target.value })}
                            rows={3}
                            placeholder="Nhập thông tin tiền sử bệnh của bệnh nhân..."
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
