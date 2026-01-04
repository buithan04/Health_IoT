"use client";

import { useState, useEffect } from "react";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Pill, Save, Loader2 } from "lucide-react";
import { apiCall } from "@/utils/api";
import { toast } from "sonner";
import { useQuery } from "@tanstack/react-query";

interface MedicationEditModalProps {
    medication: any;
    open: boolean;
    onClose: () => void;
    onSuccess: () => void;
}

export function MedicationEditModal({
    medication,
    open,
    onClose,
    onSuccess,
}: MedicationEditModalProps) {
    const [formData, setFormData] = useState({
        name: "",
        registration_number: "",
        category: "",
        manufacturer: "",
        unit: "",
        usage_route: "",
        packing_specification: "",
        price: "",
        usage_instruction: "",
        stock: "",
        min_stock: "",
        is_active: true,
    });
    const [isSaving, setIsSaving] = useState(false);

    // Fetch reference data (categories, manufacturers)
    const { data: categories } = useQuery({
        queryKey: ['medicationCategories'],
        queryFn: async () => {
            const res = await apiCall('/admin/medication-categories');
            return res?.categories || [];
        }
    });

    const { data: manufacturers } = useQuery({
        queryKey: ['manufacturers'],
        queryFn: async () => {
            const res = await apiCall('/admin/manufacturers');
            return res?.manufacturers || [];
        }
    });

    useEffect(() => {
        if (medication) {
            setFormData({
                name: medication.name || "",
                registration_number: medication.registration_number || "",
                category: medication.category || "",
                manufacturer: medication.manufacturer || "",
                unit: medication.unit || "",
                usage_route: medication.usage_route || "",
                packing_specification: medication.packing_specification || medication.description || "",
                price: medication.price?.toString() || "",
                usage_instruction: medication.usage_instruction || medication.usage_instructions || "",
                stock: medication.stock?.toString() || "0",
                min_stock: medication.min_stock?.toString() || "10",
                is_active: medication.is_active !== undefined ? medication.is_active : true,
            });
        }
    }, [medication]);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();

        if (!formData.name || !formData.price) {
            toast.error("Vui lòng điền tên thuốc và giá");
            return;
        }

        setIsSaving(true);

        try {
            await apiCall(
                `/admin/medications/${medication.id}`,
                'PUT',
                {
                    ...formData,
                    price: parseFloat(formData.price)
                }
            );

            toast.success("Cập nhật thuốc thành công");
            onSuccess();
            onClose();
        } catch (error: any) {
            console.error('Update error:', error);
            toast.error(error.message || "Lỗi khi cập nhật thuốc");
        } finally {
            setIsSaving(false);
        }
    };

    if (!medication) return null;

    return (
        <Dialog open={open} onOpenChange={onClose}>
            <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <div className="flex items-center gap-3">
                        <div className="h-12 w-12 rounded-full bg-gradient-to-br from-green-100 to-teal-100 flex items-center justify-center">
                            <Pill className="h-6 w-6 text-green-600" />
                        </div>
                        <DialogTitle className="text-2xl">Chỉnh sửa Thuốc</DialogTitle>
                        <DialogDescription className="sr-only">
                            Form chỉnh sửa thông tin thuốc
                        </DialogDescription>
                    </div>
                </DialogHeader>

                <form onSubmit={handleSubmit} className="space-y-4 mt-4">
                    <div className="grid grid-cols-2 gap-4">
                        <div className="col-span-2">
                            <Label htmlFor="name">Tên thuốc <span className="text-red-500">*</span></Label>
                            <Input
                                id="name"
                                value={formData.name}
                                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                placeholder="Nhập tên thuốc"
                                required
                            />
                        </div>

                        <div>
                            <Label htmlFor="registration_number">Số đăng ký</Label>
                            <Input
                                id="registration_number"
                                value={formData.registration_number}
                                onChange={(e) => setFormData({ ...formData, registration_number: e.target.value })}
                                placeholder="VD-XXXXX-YY"
                            />
                        </div>

                        <div>
                            <Label htmlFor="category">Danh mục</Label>
                            <Select
                                value={formData.category}
                                onValueChange={(value) => setFormData({ ...formData, category: value })}
                            >
                                <SelectTrigger>
                                    <SelectValue placeholder="Chọn danh mục" />
                                </SelectTrigger>
                                <SelectContent>
                                    {categories?.map((cat: any) => (
                                        <SelectItem key={cat.id} value={cat.name}>
                                            {cat.name}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>

                        <div>
                            <Label htmlFor="manufacturer">Nhà sản xuất</Label>
                            <Select
                                value={formData.manufacturer}
                                onValueChange={(value) => setFormData({ ...formData, manufacturer: value })}
                            >
                                <SelectTrigger>
                                    <SelectValue placeholder="Chọn nhà sản xuất" />
                                </SelectTrigger>
                                <SelectContent>
                                    {manufacturers?.map((manu: any) => (
                                        <SelectItem key={manu.id} value={manu.name}>
                                            {manu.name} {manu.country && `(${manu.country})`}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>

                        <div>
                            <Label htmlFor="unit">Đơn vị</Label>
                            <Input
                                id="unit"
                                value={formData.unit}
                                onChange={(e) => setFormData({ ...formData, unit: e.target.value })}
                                placeholder="Viên, Vỉ, Hộp..."
                            />
                        </div>

                        <div>
                            <Label htmlFor="usage_route">Đường dùng</Label>
                            <Input
                                id="usage_route"
                                value={formData.usage_route}
                                onChange={(e) => setFormData({ ...formData, usage_route: e.target.value })}
                                placeholder="Uống, Tiêm, Bôi ngoài da..."
                            />
                        </div>

                        <div>
                            <Label htmlFor="price">Giá (VNĐ) <span className="text-red-500">*</span></Label>
                            <Input
                                id="price"
                                type="number"
                                value={formData.price}
                                onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                                placeholder="0"
                                required
                                min="0"
                            />
                        </div>

                        <div>
                            <Label htmlFor="stock">Tồn kho</Label>
                            <Input
                                id="stock"
                                type="number"
                                value={formData.stock}
                                onChange={(e) => setFormData({ ...formData, stock: e.target.value })}
                                placeholder="0"
                                min="0"
                            />
                        </div>

                        <div>
                            <Label htmlFor="min_stock">Tồn kho tối thiểu</Label>
                            <Input
                                id="min_stock"
                                type="number"
                                value={formData.min_stock}
                                onChange={(e) => setFormData({ ...formData, min_stock: e.target.value })}
                                placeholder="10"
                                min="0"
                            />
                        </div>

                        <div className="col-span-2">
                            <Label htmlFor="packing_specification">Quy cách đóng gói</Label>
                            <Textarea
                                id="packing_specification"
                                value={formData.packing_specification}
                                onChange={(e) => setFormData({ ...formData, packing_specification: e.target.value })}
                                placeholder="Hộp 10 vỉ x 10 viên"
                                rows={2}
                            />
                        </div>

                        <div className="col-span-2">
                            <Label htmlFor="usage_instruction">Hướng dẫn sử dụng</Label>
                            <Textarea
                                id="usage_instruction"
                                value={formData.usage_instruction}
                                onChange={(e) => setFormData({ ...formData, usage_instruction: e.target.value })}
                                placeholder="Uống 1-2 viên mỗi 4-6 giờ khi cần"
                                rows={3}
                            />
                        </div>

                        <div className="col-span-2 flex items-center space-x-2">
                            <input
                                type="checkbox"
                                id="is_active"
                                checked={formData.is_active}
                                onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                                className="h-4 w-4 rounded border-gray-300 text-green-600 focus:ring-green-500"
                            />
                            <Label htmlFor="is_active" className="text-sm font-normal cursor-pointer">
                                Thuốc đang hoạt động (có thể sử dụng trong đơn thuốc)
                            </Label>
                        </div>
                    </div>

                    <div className="flex justify-end gap-3 pt-4 border-t">
                        <Button type="button" variant="outline" onClick={onClose}>
                            Hủy
                        </Button>
                        <Button
                            type="submit"
                            disabled={isSaving}
                            className="bg-green-600 hover:bg-green-700"
                        >
                            {isSaving ? (
                                <>
                                    <div className="h-4 w-4 mr-2 border-2 border-white border-t-transparent rounded-full animate-spin" />
                                    Đang lưu...
                                </>
                            ) : (
                                <>
                                    <Save className="h-4 w-4 mr-2" />
                                    Lưu thay đổi
                                </>
                            )}
                        </Button>
                    </div>
                </form>
            </DialogContent>
        </Dialog>
    );
}
