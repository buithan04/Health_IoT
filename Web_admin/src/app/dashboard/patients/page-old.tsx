"use client";

import { useEffect, useState } from "react";
import { apiCall } from "@/utils/api";
import { FaHospitalUser, FaUserCheck, FaCalendarCheck, FaUserPlus, FaSyncAlt, FaPlus, FaEdit, FaTrash, FaEye } from "react-icons/fa";

interface Patient {
    id: number;
    fullName: string;
    email: string;
    phone: string;
    gender: string;
    dateOfBirth: string;
    status: string;
    lastAppointment?: string;
    createdAt?: string;
}

export default function PatientsPage() {
    const [patients, setPatients] = useState<Patient[]>([]);
    const [filteredPatients, setFilteredPatients] = useState<Patient[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState("");
    const [statusFilter, setStatusFilter] = useState("");
    const [genderFilter, setGenderFilter] = useState("");

    // Stats
    const [stats, setStats] = useState({
        total: 0,
        active: 0,
        todayAppointments: 0,
        newThisMonth: 0
    });

    useEffect(() => {
        loadPatients();
    }, []);

    useEffect(() => {
        filterPatients();
    }, [searchTerm, statusFilter, genderFilter, patients]);

    const loadPatients = async () => {
        setLoading(true);
        try {
            const response = await apiCall('/admin/patients');
            let data: Patient[] = [];
            if (response && response.patients) {
                data = response.patients;
            } else if (Array.isArray(response)) {
                data = response;
            }
            setPatients(data);
            updateStats(data);
        } catch (error) {
            console.error("Error loading patients", error);
        } finally {
            setLoading(false);
        }
    };

    const updateStats = (data: Patient[]) => {
        const total = data.length;
        const active = data.filter(p => p.status === 'active').length;

        const today = new Date().toISOString().split('T')[0];
        const todayAppointments = data.filter(p =>
            p.lastAppointment && p.lastAppointment.startsWith(today)
        ).length;

        const thisMonth = new Date().toISOString().slice(0, 7);
        const newThisMonth = data.filter(p =>
            p.createdAt && p.createdAt.startsWith(thisMonth)
        ).length;

        setStats({ total, active, todayAppointments, newThisMonth });
    };

    const filterPatients = () => {
        let result = [...patients];

        if (searchTerm) {
            const lowerTerm = searchTerm.toLowerCase();
            result = result.filter(p =>
                (p.fullName && p.fullName.toLowerCase().includes(lowerTerm)) ||
                (p.email && p.email.toLowerCase().includes(lowerTerm)) ||
                (p.phone && p.phone.includes(lowerTerm))
            );
        }

        if (statusFilter) {
            result = result.filter(p => p.status === statusFilter);
        }

        if (genderFilter) {
            result = result.filter(p => p.gender === genderFilter);
        }

        setFilteredPatients(result);
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-2xl font-bold text-gray-800">Quản lý Bệnh nhân</h1>
                <div className="flex items-center gap-4">
                    <div className="relative">
                        <input
                            type="text"
                            placeholder="Tìm kiếm..."
                            className="pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                        />
                        <span className="absolute left-3 top-2.5 text-gray-400">🔍</span>
                    </div>
                </div>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Tổng Bệnh nhân</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.total}</p>
                    </div>
                    <div className="p-3 bg-blue-50 rounded-full text-blue-600">
                        <FaHospitalUser className="text-xl" />
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Đang điều trị</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.active}</p>
                    </div>
                    <div className="p-3 bg-green-50 rounded-full text-green-600">
                        <FaUserCheck className="text-xl" />
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Lịch hẹn hôm nay</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.todayAppointments}</p>
                    </div>
                    <div className="p-3 bg-yellow-50 rounded-full text-yellow-600">
                        <FaCalendarCheck className="text-xl" />
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Bệnh nhân mới</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.newThisMonth}</p>
                    </div>
                    <div className="p-3 bg-cyan-50 rounded-full text-cyan-600">
                        <FaUserPlus className="text-xl" />
                    </div>
                </div>
            </div>

            {/* Table Section */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="p-6 border-b border-gray-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <h2 className="text-lg font-semibold text-gray-800">Danh sách Bệnh nhân</h2>
                    <div className="flex gap-2">
                        <button
                            onClick={loadPatients}
                            className="flex items-center gap-2 px-4 py-2 text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
                        >
                            <FaSyncAlt /> Làm mới
                        </button>
                        <button className="flex items-center gap-2 px-4 py-2 text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition-colors">
                            <FaPlus /> Thêm Bệnh nhân
                        </button>
                    </div>
                </div>

                <div className="p-4 bg-gray-50 border-b border-gray-100 grid grid-cols-1 md:grid-cols-3 gap-4">
                    <input
                        type="text"
                        placeholder="Tìm kiếm theo tên, email, SĐT..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    />
                    <select
                        value={statusFilter}
                        onChange={(e) => setStatusFilter(e.target.value)}
                        className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    >
                        <option value="">Tất cả trạng thái</option>
                        <option value="active">Đang điều trị</option>
                        <option value="inactive">Không hoạt động</option>
                    </select>
                    <select
                        value={genderFilter}
                        onChange={(e) => setGenderFilter(e.target.value)}
                        className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    >
                        <option value="">Tất cả giới tính</option>
                        <option value="male">Nam</option>
                        <option value="female">Nữ</option>
                        <option value="other">Khác</option>
                    </select>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-gray-50 text-gray-600 text-sm uppercase tracking-wider">
                                <th className="p-4 border-b font-medium">ID</th>
                                <th className="p-4 border-b font-medium">Họ và tên</th>
                                <th className="p-4 border-b font-medium">Giới tính</th>
                                <th className="p-4 border-b font-medium">Ngày sinh</th>
                                <th className="p-4 border-b font-medium">Email</th>
                                <th className="p-4 border-b font-medium">Số điện thoại</th>
                                <th className="p-4 border-b font-medium">Trạng thái</th>
                                <th className="p-4 border-b font-medium">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody className="text-gray-700 text-sm">
                            {loading ? (
                                <tr>
                                    <td colSpan={8} className="p-8 text-center text-gray-500">
                                        Đang tải dữ liệu...
                                    </td>
                                </tr>
                            ) : filteredPatients.length === 0 ? (
                                <tr>
                                    <td colSpan={8} className="p-8 text-center text-gray-500">
                                        Không tìm thấy bệnh nhân nào
                                    </td>
                                </tr>
                            ) : (
                                filteredPatients.map((patient) => (
                                    <tr key={patient.id} className="border-b hover:bg-gray-50 transition-colors">
                                        <td className="p-4">#{patient.id}</td>
                                        <td className="p-4 font-medium text-gray-900">{patient.fullName}</td>
                                        <td className="p-4 capitalize">{patient.gender === 'male' ? 'Nam' : patient.gender === 'female' ? 'Nữ' : 'Khác'}</td>
                                        <td className="p-4">{patient.dateOfBirth ? new Date(patient.dateOfBirth).toLocaleDateString('vi-VN') : 'N/A'}</td>
                                        <td className="p-4">{patient.email}</td>
                                        <td className="p-4">{patient.phone}</td>
                                        <td className="p-4">
                                            <span className={`px-2 py-1 rounded-full text-xs font-medium ${patient.status === 'active' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-700'
                                                }`}>
                                                {patient.status === 'active' ? 'Đang điều trị' : 'Không hoạt động'}
                                            </span>
                                        </td>
                                        <td className="p-4 flex gap-2">
                                            <button className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg" title="Xem chi tiết">
                                                <FaEye />
                                            </button>
                                            <button className="p-2 text-yellow-600 hover:bg-yellow-50 rounded-lg" title="Sửa">
                                                <FaEdit />
                                            </button>
                                            <button className="p-2 text-red-600 hover:bg-red-50 rounded-lg" title="Xóa">
                                                <FaTrash />
                                            </button>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}
