"use client";

import { useState } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Loader2 } from "lucide-react";
import { apiCall } from "@/utils/api";
import { toast } from "sonner";

interface AddUserModalProps {
    open: boolean;
    onClose: () => void;
    onSuccess: () => void;
}

export function AddUserModal({ open, onClose, onSuccess }: AddUserModalProps) {
    const [loading, setLoading] = useState(false);
    const [formData, setFormData] = useState({
        full_name: '',
        email: '',
        password: '',
        phone_number: '',
        role: 'patient',
        gender: 'male',
    });

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();

        if (!formData.email || !formData.password || !formData.full_name) {
            toast.error('Vui lòng điền đầy đủ thông tin bắt buộc');
            return;
        }

        setLoading(true);
        try {
            const response = await apiCall('/admin/users', 'POST', formData);

            toast.success(response.message || 'Thêm người dùng thành công!', {
                description: response.message?.includes('email')
                    ? 'Email xác thực đã được gửi đến người dùng'
                    : undefined
            });
            onSuccess();
            onClose();
            // Reset form
            setFormData({
                full_name: '',
                email: '',
                password: '',
                phone_number: '',
                role: 'patient',
                gender: 'male',
            });
        } catch (error: any) {
            console.error('Error creating user:', error);
            toast.error(error?.message || 'Có lỗi xảy ra khi thêm người dùng');
        } finally {
            setLoading(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={onClose}>
            <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>Thêm Người dùng mới</DialogTitle>
                    <DialogDescription>
                        Tạo tài khoản người dùng mới. Email xác thực sẽ được gửi tự động đến người dùng.
                    </DialogDescription>
                </DialogHeader>
                <form onSubmit={handleSubmit} className="space-y-4">
                    {/* Thông báo quan trọng */}
                    <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
                        <div className="flex items-start gap-2">
                            <svg className="h-5 w-5 text-blue-600 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            <div className="text-sm text-blue-800">
                                <p className="font-medium">Lưu ý quan trọng:</p>
                                <ul className="mt-1 ml-4 list-disc space-y-1">
                                    <li>Email xác thực sẽ được gửi tự động đến người dùng</li>
                                    <li>Người dùng phải xác thực email trong vòng 15 phút</li>
                                    <li>Tài khoản chỉ hoạt động sau khi đã xác thực</li>
                                </ul>
                            </div>
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="full_name">Họ và tên *</Label>
                            <Input
                                id="full_name"
                                value={formData.full_name}
                                onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
                                required
                                placeholder="Nhập họ tên đầy đủ"
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="email">Email *</Label>
                            <Input
                                id="email"
                                type="email"
                                value={formData.email}
                                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                required
                                placeholder="email@example.com"
                            />
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="password">Mật khẩu *</Label>
                            <Input
                                id="password"
                                type="password"
                                value={formData.password}
                                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                                required
                                placeholder="Nhập mật khẩu"
                                minLength={6}
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="phone_number">Số điện thoại</Label>
                            <Input
                                id="phone_number"
                                type="tel"
                                value={formData.phone_number}
                                onChange={(e) => setFormData({ ...formData, phone_number: e.target.value })}
                                placeholder="0123456789"
                            />
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="role">Vai trò *</Label>
                            <Select
                                value={formData.role}
                                onValueChange={(value) => setFormData({ ...formData, role: value })}
                            >
                                <SelectTrigger>
                                    <SelectValue />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="patient">Bệnh nhân</SelectItem>
                                    <SelectItem value="doctor">Bác sĩ</SelectItem>
                                    <SelectItem value="admin">Admin</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
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
                    </div>

                    <div className="flex justify-end gap-2 pt-4">
                        <Button type="button" variant="outline" onClick={onClose} disabled={loading}>
                            Hủy
                        </Button>
                        <Button type="submit" disabled={loading}>
                            {loading ? (
                                <>
                                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                                    Đang tạo...
                                </>
                            ) : (
                                'Tạo tài khoản'
                            )}
                        </Button>
                    </div>
                </form>
            </DialogContent>
        </Dialog>
    );
}
