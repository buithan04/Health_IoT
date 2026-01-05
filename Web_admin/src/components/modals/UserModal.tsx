"use client";

import { useState, useEffect } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Loader2 } from "lucide-react";
import { apiCall } from "@/utils/api";
import { toast } from "sonner";

interface UserModalProps {
    user: any;
    open: boolean;
    onClose: () => void;
    onSuccess: () => void;
    mode: 'view' | 'edit';
}

export function UserModal({ user, open, onClose, onSuccess, mode }: UserModalProps) {
    const [loading, setLoading] = useState(false);
    const [formData, setFormData] = useState({
        full_name: '',
        email: '',
        phone_number: '',
        role: 'patient',
        is_verified: false,
    });

    useEffect(() => {
        if (user) {
            setFormData({
                full_name: user.full_name || '',
                email: user.email || '',
                phone_number: user.phone_number || '',
                role: user.role || 'patient',
                is_verified: user.is_verified || false,
            });
        }
    }, [user]);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (mode === 'view') {
            onClose();
            return;
        }

        setLoading(true);
        try {
            await apiCall(`/admin/users/${user.id}`, 'PUT', formData);

            toast.success('Cập nhật người dùng thành công!');
            onSuccess();
            onClose();
        } catch (error) {
            console.error('Error updating user:', error);
            toast.error('Có lỗi xảy ra khi cập nhật người dùng');
        } finally {
            setLoading(false);
        }
    };

    const isView = mode === 'view';

    return (
        <Dialog open={open} onOpenChange={onClose}>
            <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>
                        {isView ? 'Thông tin Người dùng' : 'Chỉnh sửa Người dùng'}
                    </DialogTitle>
                    <DialogDescription>
                        {isView ? 'Xem chi tiết thông tin người dùng' : 'Cập nhật thông tin người dùng'}
                    </DialogDescription>
                </DialogHeader>
                <form onSubmit={handleSubmit} className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="full_name">Họ và tên *</Label>
                            <Input
                                id="full_name"
                                value={formData.full_name}
                                onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
                                disabled={isView}
                                required
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="email">Email *</Label>
                            <Input
                                id="email"
                                type="email"
                                value={formData.email}
                                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                disabled={true}
                                required
                            />
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <Label htmlFor="phone_number">Số điện thoại</Label>
                            <Input
                                id="phone_number"
                                type="tel"
                                value={formData.phone_number}
                                onChange={(e) => setFormData({ ...formData, phone_number: e.target.value })}
                                disabled={isView}
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="role">Vai trò *</Label>
                            <Select
                                value={formData.role}
                                onValueChange={(value) => setFormData({ ...formData, role: value })}
                                disabled={isView}
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
                    </div>

                    {/* Hiển thị trạng thái xác thực (chỉ đọc) */}
                    <div className="space-y-2 bg-gray-50 p-3 rounded-md">
                        <Label>Trạng thái xác thực</Label>
                        <div className="flex items-center gap-2">
                            {formData.is_verified ? (
                                <>
                                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                                        <svg className="mr-1.5 h-2 w-2 text-green-400" fill="currentColor" viewBox="0 0 8 8">
                                            <circle cx="4" cy="4" r="3" />
                                        </svg>
                                        Đã xác thực
                                    </span>
                                </>
                            ) : (
                                <>
                                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                                        <svg className="mr-1.5 h-2 w-2 text-yellow-400" fill="currentColor" viewBox="0 0 8 8">
                                            <circle cx="4" cy="4" r="3" />
                                        </svg>
                                        Chưa xác thực
                                    </span>
                                    <span className="text-xs text-gray-500">
                                        (Người dùng cần xác thực qua email)
                                    </span>
                                </>
                            )}
                        </div>
                    </div>

                    <div className="flex justify-end gap-2 pt-4">
                        <Button type="button" variant="outline" onClick={onClose} disabled={loading}>
                            {isView ? 'Đóng' : 'Hủy'}
                        </Button>
                        {!isView && (
                            <Button type="submit" disabled={loading}>
                                {loading ? (
                                    <>
                                        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                                        Đang lưu...
                                    </>
                                ) : (
                                    'Lưu thay đổi'
                                )}
                            </Button>
                        )}
                    </div>
                </form>
            </DialogContent>
        </Dialog>
    );
}
