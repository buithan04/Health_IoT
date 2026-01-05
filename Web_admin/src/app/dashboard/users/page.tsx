"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { apiCall } from "@/utils/api";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
    Users,
    Search,
    Filter,
    UserPlus,
    Edit,
    Trash2,
    Mail,
    Phone,
    Shield,
    CheckCircle2,
    XCircle,
    Loader2,
    RefreshCw,
    Eye,
    UserCircle
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar } from "@/components/ui/avatar";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { UserModal } from "@/components/modals/UserModal";
import { AddUserModal } from "@/components/modals/AddUserModal";
import { DeleteConfirmModal } from "@/components/modals/DeleteConfirmModal";
import { toast } from "sonner";

export default function UsersPage() {
    const router = useRouter();
    const queryClient = useQueryClient();
    const [searchQuery, setSearchQuery] = useState("");
    const [roleFilter, setRoleFilter] = useState<string>("all");
    const [statusFilter, setStatusFilter] = useState<string>("all");

    // Modal state
    const [selectedUser, setSelectedUser] = useState<any>(null);
    const [modalMode, setModalMode] = useState<'view' | 'edit'>('view');
    const [showModal, setShowModal] = useState(false);
    const [userToDelete, setUserToDelete] = useState<any>(null);
    const [showDeleteModal, setShowDeleteModal] = useState(false);
    const [showAddModal, setShowAddModal] = useState(false);

    const { data: users, isLoading, refetch } = useQuery({
        queryKey: ['allUsers', roleFilter, statusFilter, searchQuery],
        queryFn: async () => {
            let endpoint = '/admin/users?';
            if (roleFilter !== 'all') endpoint += `role=${roleFilter}&`;
            if (statusFilter !== 'all') endpoint += `isVerified=${statusFilter === 'verified'}&`;
            if (searchQuery) endpoint += `search=${searchQuery}`;

            const res = await apiCall(endpoint);
            return res?.users || [];
        }
    });

    // Delete mutation
    const deleteMutation = useMutation({
        mutationFn: async (userId: number) => {
            return await apiCall(`/admin/users/${userId}`, 'DELETE');
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['allUsers'] });
            setShowDeleteModal(false);
            setUserToDelete(null);
            toast.success('Xóa người dùng thành công!');
        },
        onError: (error: any) => {
            console.error('Error deleting user:', error);
            const errorMessage = error?.message || 'Có lỗi xảy ra khi xóa người dùng';
            toast.error(errorMessage);
        }
    });

    const handleView = (user: any) => {
        setSelectedUser(user);
        setModalMode('view');
        setShowModal(true);
    };

    const handleEdit = (user: any) => {
        setSelectedUser(user);
        setModalMode('edit');
        setShowModal(true);
    };

    const handleDelete = (user: any) => {
        setUserToDelete(user);
        setShowDeleteModal(true);
    };

    const confirmDelete = async () => {
        if (userToDelete) {
            await deleteMutation.mutateAsync(userToDelete.id);
        }
    };

    const getRoleBadge = (role: string) => {
        const variants: any = {
            admin: { color: "bg-purple-100 text-purple-700 border-purple-300", label: "Admin" },
            doctor: { color: "bg-blue-100 text-blue-700 border-blue-300", label: "Bác sĩ" },
            patient: { color: "bg-green-100 text-green-700 border-green-300", label: "Bệnh nhân" }
        };
        return variants[role] || variants.patient;
    };

    const filteredUsers = users?.filter((user: any) => {
        const matchesSearch = !searchQuery ||
            user.full_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            user.email?.toLowerCase().includes(searchQuery.toLowerCase());

        return matchesSearch;
    });

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
                        Quản lý Người dùng
                    </h1>
                    <p className="text-muted-foreground mt-2">
                        Quản lý tất cả người dùng trong hệ thống
                    </p>
                </div>
                <div className="flex items-center gap-3">
                    <Button onClick={() => refetch()} variant="outline" size="icon">
                        <RefreshCw className="h-4 w-4" />
                    </Button>
                    <Button
                        className="bg-blue-600 hover:bg-blue-700"
                        onClick={() => setShowAddModal(true)}
                    >
                        <UserPlus className="h-4 w-4 mr-2" />
                        Thêm Người dùng
                    </Button>
                </div>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <Card key="total-users" className="border-2 border-blue-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Tổng số</p>
                                <p className="text-2xl font-bold">{users?.length || 0}</p>
                            </div>
                            <Users className="h-8 w-8 text-blue-600" />
                        </div>
                    </CardContent>
                </Card>
                <Card key="admin-users" className="border-2 border-purple-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Admin</p>
                                <p className="text-2xl font-bold">{users?.filter((u: any) => u.role === 'admin').length || 0}</p>
                            </div>
                            <Shield className="h-8 w-8 text-purple-600" />
                        </div>
                    </CardContent>
                </Card>
                <Card key="doctor-users" className="border-2 border-blue-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Bác sĩ</p>
                                <p className="text-2xl font-bold">{users?.filter((u: any) => u.role === 'doctor').length || 0}</p>
                            </div>
                            <Users className="h-8 w-8 text-blue-600" />
                        </div>
                    </CardContent>
                </Card>
                <Card key="patient-users" className="border-2 border-green-200">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-gray-600">Bệnh nhân</p>
                                <p className="text-2xl font-bold">{users?.filter((u: any) => u.role === 'patient').length || 0}</p>
                            </div>
                            <Users className="h-8 w-8 text-green-600" />
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Filters and Search */}
            <Card className="border-2">
                <CardContent className="pt-6">
                    <div className="flex flex-col md:flex-row gap-4">
                        <div className="relative flex-1">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                            <Input
                                placeholder="Tìm kiếm theo tên hoặc email..."
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                className="pl-10"
                            />
                        </div>
                        <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                                <Button variant="outline">
                                    <Filter className="h-4 w-4 mr-2" />
                                    Vai trò: {roleFilter === 'all' ? 'Tất cả' : roleFilter}
                                </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent>
                                <DropdownMenuItem onClick={() => setRoleFilter('all')}>Tất cả</DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setRoleFilter('admin')}>Admin</DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setRoleFilter('doctor')}>Bác sĩ</DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setRoleFilter('patient')}>Bệnh nhân</DropdownMenuItem>
                            </DropdownMenuContent>
                        </DropdownMenu>
                        <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                                <Button variant="outline">
                                    <Filter className="h-4 w-4 mr-2" />
                                    Trạng thái: {statusFilter === 'all' ? 'Tất cả' : statusFilter === 'verified' ? 'Đã xác thực' : 'Chưa xác thực'}
                                </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent>
                                <DropdownMenuItem onClick={() => setStatusFilter('all')}>Tất cả</DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setStatusFilter('verified')}>Đã xác thực</DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setStatusFilter('unverified')}>Chưa xác thực</DropdownMenuItem>
                            </DropdownMenuContent>
                        </DropdownMenu>
                    </div>
                </CardContent>
            </Card>

            {/* Users Table */}
            <Card className="border-2">
                <CardHeader className="border-b bg-gradient-to-r from-blue-50 to-purple-50">
                    <CardTitle>Danh sách Người dùng</CardTitle>
                    <CardDescription>Hiển thị {filteredUsers?.length || 0} người dùng</CardDescription>
                </CardHeader>
                <CardContent className="pt-6">
                    <div className="space-y-4">
                        {filteredUsers?.length === 0 ? (
                            <div className="text-center py-12">
                                <Users className="h-12 w-12 mx-auto text-gray-300 mb-3" />
                                <p className="text-sm text-muted-foreground">Không tìm thấy người dùng nào</p>
                            </div>
                        ) : (
                            filteredUsers?.map((user: any) => (
                                <div key={user.id} className="flex items-center gap-4 p-4 rounded-lg border hover:border-blue-300 hover:bg-blue-50/50 transition-all">
                                    {user.avatar_url ? (
                                        <img
                                            src={user.avatar_url}
                                            alt={user.full_name || 'User'}
                                            className="h-12 w-12 rounded-full object-cover border-2 border-blue-200"
                                        />
                                    ) : (
                                        <div className="h-12 w-12 rounded-full bg-gradient-to-br from-blue-500 to-purple-500 flex items-center justify-center">
                                            <UserCircle className="h-8 w-8 text-white" />
                                        </div>
                                    )}
                                    <div className="flex-1 min-w-0">
                                        <div className="flex items-center gap-2 mb-1">
                                            <p className="font-semibold text-gray-900">{user.full_name}</p>
                                            <Badge className={`${getRoleBadge(user.role).color} border`}>
                                                {getRoleBadge(user.role).label}
                                            </Badge>
                                            {user.is_verified ? (
                                                <CheckCircle2 className="h-4 w-4 text-green-600" />
                                            ) : (
                                                <XCircle className="h-4 w-4 text-red-600" />
                                            )}
                                        </div>
                                        <div className="flex items-center gap-4 text-sm text-muted-foreground">
                                            <span className="flex items-center gap-1">
                                                <Mail className="h-3 w-3" />
                                                {user.email}
                                            </span>
                                            {user.phone_number && (
                                                <span className="flex items-center gap-1">
                                                    <Phone className="h-3 w-3" />
                                                    {user.phone_number}
                                                </span>
                                            )}
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <Button variant="outline" size="sm" onClick={() => handleView(user)}>
                                            <Eye className="h-3 w-3 mr-1" />
                                            Xem
                                        </Button>
                                        <Button variant="outline" size="sm" onClick={() => handleEdit(user)}>
                                            <Edit className="h-3 w-3 mr-1" />
                                            Sửa
                                        </Button>
                                        <Button
                                            variant="outline"
                                            size="sm"
                                            className="text-red-600 hover:text-red-700"
                                            onClick={() => handleDelete(user)}
                                        >
                                            <Trash2 className="h-3 w-3 mr-1" />
                                            Xóa
                                        </Button>
                                    </div>
                                </div>
                            ))
                        )}
                    </div>
                </CardContent>
            </Card>

            {/* User Modal */}
            {selectedUser && (
                <UserModal
                    user={selectedUser}
                    open={showModal}
                    onClose={() => {
                        setShowModal(false);
                        setSelectedUser(null);
                    }}
                    onSuccess={() => {
                        refetch();
                    }}
                    mode={modalMode}
                />
            )}

            {/* Delete Confirmation Modal */}
            <DeleteConfirmModal
                open={showDeleteModal}
                onClose={() => {
                    setShowDeleteModal(false);
                    setUserToDelete(null);
                }}
                onConfirm={confirmDelete}
                title={`Xóa người dùng ${userToDelete?.full_name || ''}?`}
                description="Hành động này không thể hoàn tác. Người dùng sẽ bị xóa vĩnh viễn khỏi hệ thống."
            />

            {/* Add User Modal */}
            <AddUserModal
                open={showAddModal}
                onClose={() => setShowAddModal(false)}
                onSuccess={() => {
                    refetch();
                }}
            />
        </div>
    );
}
