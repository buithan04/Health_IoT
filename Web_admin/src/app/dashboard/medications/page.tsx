"use client";

import { useState } from "react";
import { apiCall } from "@/utils/api";
import { useQuery } from "@tanstack/react-query";
import {
    Pill,
    Search,
    Filter,
    Eye,
    Edit,
    Trash2,
    Plus,
    Loader2,
    RefreshCw,
    Package,
    DollarSign,
    Tag,
    FileSpreadsheet,
    AlertTriangle,
    MoreHorizontal
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { ImportMedicationsModal } from "@/components/modals/ImportMedicationsModal";
import { MedicationDetailModal } from "@/components/modals/MedicationDetailModal";
import { MedicationEditModal } from "@/components/modals/MedicationEditModal";
import { MedicationCreateModal } from "@/components/modals/MedicationCreateModal";
import { useMutation } from "@tanstack/react-query";
import { toast } from "sonner";

export default function MedicationsPage() {
    const [searchQuery, setSearchQuery] = useState("");
    const [categoryFilter, setCategoryFilter] = useState("all");
    const [showImportModal, setShowImportModal] = useState(false);
    const [selectedMedication, setSelectedMedication] = useState<any>(null);
    const [showDetailModal, setShowDetailModal] = useState(false);
    const [showEditModal, setShowEditModal] = useState(false);
    const [showDeleteDialog, setShowDeleteDialog] = useState(false);
    const [medicationToDelete, setMedicationToDelete] = useState<any>(null);
    const [showCreateModal, setShowCreateModal] = useState(false);

    const { data: medications, isLoading, refetch } = useQuery({
        queryKey: ['allMedications'],
        queryFn: async () => {
            const res = await apiCall('/admin/medications');
            console.log('Medications API response:', res);
            console.log('Medications data:', res?.medications);
            return res?.medications || [];
        }
    });

    const { data: categories } = useQuery({
        queryKey: ['medicationCategories'],
        queryFn: async () => {
            const res = await apiCall('/admin/medication-categories');
            return res?.categories || [];
        }
    });

    const filteredMedications = medications?.filter((med: any) => {
        const matchesSearch = !searchQuery ||
            med.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            med.active_ingredient?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            med.manufacturer?.toLowerCase().includes(searchQuery.toLowerCase());

        const matchesCategory = categoryFilter === 'all' ||
            med.category?.toLowerCase() === categoryFilter.toLowerCase();

        return matchesSearch && matchesCategory;
    });

    const stats = {
        total: medications?.length || 0,
        categories: categories?.length || 0,
        inStock: medications?.filter((m: any) => m.stock > 0).length || 0,
        lowStock: medications?.filter((m: any) => m.stock > 0 && m.stock < 10).length || 0
    };

    const deleteMutation = useMutation({
        mutationFn: async (id: number) => {
            await apiCall(`/admin/medications/${id}`, 'DELETE');
        },
        onSuccess: () => {
            toast.success('Xóa thuốc thành công');
            refetch();
            setShowDeleteDialog(false);
            setMedicationToDelete(null);
        },
        onError: (error: any) => {
            toast.error(error.message || 'Lỗi khi xóa thuốc');
            setShowDeleteDialog(false);
            setMedicationToDelete(null);
        }
    });

    const handleDelete = (medication: any) => {
        setMedicationToDelete(medication);
        setShowDeleteDialog(true);
    };

    const confirmDelete = () => {
        if (medicationToDelete) {
            deleteMutation.mutate(medicationToDelete.id);
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
                    <h1 className="text-3xl font-bold tracking-tight bg-gradient-to-r from-green-600 to-teal-600 bg-clip-text text-transparent">
                        Quản lý Thuốc
                    </h1>
                    <p className="text-muted-foreground mt-2">
                        Quản lý danh mục thuốc và tồn kho
                    </p>
                </div>
                <div className="flex items-center gap-3">
                    <Button onClick={() => refetch()} variant="outline" size="icon">
                        <RefreshCw className="h-4 w-4" />
                    </Button>
                    <Button
                        onClick={() => setShowImportModal(true)}
                        variant="outline"
                        className="border-green-300 text-green-700 hover:bg-green-50"
                    >
                        <FileSpreadsheet className="h-4 w-4 mr-2" />
                        Import Excel
                    </Button>
                    <Button
                        onClick={() => setShowCreateModal(true)}
                        className="bg-green-600 hover:bg-green-700"
                    >
                        <Plus className="h-4 w-4 mr-2" />
                        Thêm Thuốc
                    </Button>
                </div>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <Card className="border-2 border-green-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Tổng số thuốc</p>
                                <p className="text-2xl font-bold">{stats.total}</p>
                            </div>
                            <Pill className="h-8 w-8 text-green-600" />
                        </div>
                    </CardContent>
                </Card>
                <Card className="border-2 border-teal-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Danh mục</p>
                                <p className="text-2xl font-bold">{stats.categories}</p>
                            </div>
                            <Tag className="h-8 w-8 text-teal-600" />
                        </div>
                    </CardContent>
                </Card>
                <Card className="border-2 border-blue-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Còn hàng</p>
                                <p className="text-2xl font-bold">{stats.inStock}</p>
                            </div>
                            <Package className="h-8 w-8 text-blue-600" />
                        </div>
                    </CardContent>
                </Card>
                <Card className="border-2 border-yellow-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Sắp hết</p>
                                <p className="text-2xl font-bold">{stats.lowStock}</p>
                            </div>
                            <Package className="h-8 w-8 text-yellow-600" />
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
                                placeholder="Tìm kiếm theo tên thuốc..."
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                className="pl-10"
                            />
                        </div>
                        <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                                <Button variant="outline" className="min-w-[200px]">
                                    <Filter className="h-4 w-4 mr-2" />
                                    Danh mục: {categoryFilter === 'all' ? 'Tất cả' : categoryFilter}
                                </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent className="max-h-[300px] overflow-y-auto">
                                <DropdownMenuItem onClick={() => setCategoryFilter('all')}>
                                    Tất cả danh mục
                                </DropdownMenuItem>
                                {categories?.map((cat: any) => (
                                    <DropdownMenuItem key={cat.id} onClick={() => setCategoryFilter(cat.name)}>
                                        {cat.name}
                                    </DropdownMenuItem>
                                ))}
                            </DropdownMenuContent>
                        </DropdownMenu>
                    </div>
                </CardContent>
            </Card>

            {/* Medications Table */}
            <Card>
                <CardContent className="p-0">
                    <Table>
                        <TableHeader>
                            <TableRow className="bg-gradient-to-r from-green-50 to-teal-50">
                                <TableHead className="font-semibold">Tên thuốc</TableHead>
                                <TableHead className="font-semibold">Số ĐK</TableHead>
                                <TableHead className="font-semibold">Danh mục</TableHead>
                                <TableHead className="font-semibold">NSX</TableHead>
                                <TableHead className="font-semibold">Đơn vị</TableHead>
                                <TableHead className="font-semibold">Giá</TableHead>
                                <TableHead className="font-semibold">Tồn kho</TableHead>
                                <TableHead className="font-semibold">Trạng thái</TableHead>
                                <TableHead className="font-semibold text-center">Thao tác</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {filteredMedications?.length === 0 ? (
                                <TableRow>
                                    <TableCell colSpan={9} className="text-center py-12">
                                        <div className="flex flex-col items-center justify-center">
                                            <Pill className="h-12 w-12 text-gray-300 mb-3" />
                                            <p className="text-sm text-muted-foreground">Không tìm thấy thuốc nào</p>
                                        </div>
                                    </TableCell>
                                </TableRow>
                            ) : (
                                filteredMedications?.map((medication: any) => (
                                    <TableRow key={medication.id} className="hover:bg-green-50/50">
                                        <TableCell className="font-medium">
                                            <div className="flex items-center gap-2">
                                                <div className="h-8 w-8 rounded-full bg-gradient-to-br from-green-100 to-teal-100 flex items-center justify-center shrink-0">
                                                    <Pill className="h-4 w-4 text-green-600" />
                                                </div>
                                                <span className="font-semibold">{medication.name}</span>
                                            </div>
                                        </TableCell>
                                        <TableCell>
                                            <span className="text-xs text-muted-foreground">
                                                {medication.registration_number || '-'}
                                            </span>
                                        </TableCell>
                                        <TableCell>
                                            <Badge className="bg-green-100 text-green-700 border-green-300">
                                                {medication.category || 'Chưa phân loại'}
                                            </Badge>
                                        </TableCell>
                                        <TableCell>
                                            <span className="text-sm">
                                                {medication.manufacturer || '-'}
                                            </span>
                                        </TableCell>
                                        <TableCell>
                                            <Badge variant="outline" className="text-xs">
                                                {medication.unit}
                                            </Badge>
                                        </TableCell>
                                        <TableCell>
                                            <span className="font-semibold text-green-700">
                                                {medication.price?.toLocaleString('vi-VN')}đ
                                            </span>
                                        </TableCell>
                                        <TableCell>
                                            <div className="flex items-center gap-2">
                                                <Badge
                                                    variant={(medication.stock || 0) <= (medication.min_stock || 10) ? "destructive" : "outline"}
                                                    className="text-xs"
                                                >
                                                    {medication.stock || 0}
                                                </Badge>
                                                {(medication.stock || 0) <= (medication.min_stock || 10) && (
                                                    <span className="text-xs text-red-500">⚠️</span>
                                                )}
                                            </div>
                                        </TableCell>
                                        <TableCell>
                                            <Badge variant={medication.is_active ? "default" : "secondary"} className="text-xs">
                                                {medication.is_active ? "Hoạt động" : "Tạm ngưng"}
                                            </Badge>
                                        </TableCell>
                                        <TableCell>
                                            <div className="flex items-center justify-center gap-2">
                                                <Button
                                                    size="sm"
                                                    variant="ghost"
                                                    onClick={() => {
                                                        setSelectedMedication(medication);
                                                        setShowDetailModal(true);
                                                    }}
                                                >
                                                    <Eye className="h-4 w-4 text-blue-600" />
                                                </Button>
                                                <Button
                                                    size="sm"
                                                    variant="ghost"
                                                    onClick={() => {
                                                        setSelectedMedication(medication);
                                                        setShowEditModal(true);
                                                    }}
                                                >
                                                    <Edit className="h-4 w-4 text-green-600" />
                                                </Button>
                                                <Button
                                                    size="sm"
                                                    variant="ghost"
                                                    onClick={() => handleDelete(medication)}
                                                >
                                                    <Trash2 className="h-4 w-4 text-red-600" />
                                                </Button>
                                            </div>
                                        </TableCell>
                                    </TableRow>
                                ))
                            )}
                        </TableBody>
                    </Table>
                </CardContent>
            </Card>

            {/* Import Medications Modal */}
            <ImportMedicationsModal
                open={showImportModal}
                onClose={() => setShowImportModal(false)}
                onSuccess={() => {
                    refetch();
                    setShowImportModal(false);
                }}
            />

            {/* Medication Detail Modal */}
            <MedicationDetailModal
                medication={selectedMedication}
                open={showDetailModal}
                onClose={() => {
                    setShowDetailModal(false);
                    setSelectedMedication(null);
                }}
            />

            {/* Medication Edit Modal */}
            <MedicationEditModal
                medication={selectedMedication}
                open={showEditModal}
                onClose={() => {
                    setShowEditModal(false);
                    setSelectedMedication(null);
                }}
                onSuccess={() => {
                    refetch();
                    setShowEditModal(false);
                    setSelectedMedication(null);
                }}
            />

            {/* Delete Confirmation Dialog */}
            <AlertDialog open={showDeleteDialog} onOpenChange={setShowDeleteDialog}>
                <AlertDialogContent>
                    <AlertDialogHeader>
                        <AlertDialogTitle className="flex items-center gap-2">
                            <AlertTriangle className="h-5 w-5 text-red-500" />
                            Xác nhận xóa thuốc
                        </AlertDialogTitle>
                        <AlertDialogDescription>
                            Bạn có chắc chắn muốn xóa thuốc{" "}
                            <span className="font-semibold text-gray-900">
                                {medicationToDelete?.name}
                            </span>
                            ?
                            <br />
                            <br />
                            Thao tác này không thể hoàn tác!
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel>Hủy</AlertDialogCancel>
                        <AlertDialogAction
                            onClick={confirmDelete}
                            className="bg-red-500 hover:bg-red-600"
                        >
                            {deleteMutation.isPending ? (
                                <>
                                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                                    Đang xóa...
                                </>
                            ) : (
                                "Xóa"
                            )}
                        </AlertDialogAction>
                    </AlertDialogFooter>
                </AlertDialogContent>
            </AlertDialog>

            {/* Create Medication Modal */}
            <MedicationCreateModal
                open={showCreateModal}
                onClose={() => setShowCreateModal(false)}
                onSuccess={() => {
                    refetch();
                    setShowCreateModal(false);
                }}
            />
        </div>
    );
}
