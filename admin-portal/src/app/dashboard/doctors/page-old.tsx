"use client";

import { useEffect, useState } from "react";
import { apiCall } from "@/utils/api";
import { FaUserMd, FaStethoscope, FaStar, FaUsers, FaPlus, FaEdit, FaTrash, FaEye, FaSyncAlt } from "react-icons/fa";

interface Doctor {
    id: number;
    fullName: string;
    email: string;
    phone: string;
    specialization: string;
    experience: number;
    qualification: string;
    status: string;
    consultationFee: number;
    rating: number;
    totalPatients: number;
    bio: string;
    createdAt: string;
}

const SPECIALIZATIONS = [
    'Nội khoa', 'Ngoại khoa', 'Nhi khoa', 'Sản phụ khoa', 'Tim mạch',
    'Da liễu', 'Tai Mũi Họng', 'Mắt', 'Răng Hàm Mặt', 'Thần kinh',
    'Xương khớp', 'Hô hấp', 'Tiêu hóa', 'Thận - Tiết niệu', 'Nội tiết', 'Tâm thần'
];

export default function DoctorsPage() {
    const [doctors, setDoctors] = useState<Doctor[]>([]);
    const [filteredDoctors, setFilteredDoctors] = useState<Doctor[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState("");
    const [statusFilter, setStatusFilter] = useState("");
    const [specializationFilter, setSpecializationFilter] = useState("");

    // Stats
    const [stats, setStats] = useState({
        total: 0,
        active: 0,
        avgRating: 0,
        totalPatients: 0
    });

    useEffect(() => {
        loadDoctors();
    }, []);

    useEffect(() => {
        filterDoctors();
    }, [searchTerm, statusFilter, specializationFilter, doctors]);

    const loadDoctors = async () => {
        setLoading(true);
        try {
            const response = await apiCall('/admin/doctors');
            let data: Doctor[] = [];
            if (response && response.doctors) {
                data = response.doctors;
            } else if (Array.isArray(response)) {
                data = response;
            }
            setDoctors(data);
            updateStats(data);
        } catch (error) {
            console.error("Error loading doctors", error);
        } finally {
            setLoading(false);
        }
    };

    const updateStats = (data: Doctor[]) => {
        const total = data.length;
        const active = data.filter(d => d.status === 'active').length;
        const avgRating = total > 0
            ? (data.reduce((sum, d) => sum + (d.rating || 0), 0) / total)
            : 0;
        const totalPatients = data.reduce((sum, d) => sum + (d.totalPatients || 0), 0);

        setStats({
            total,
            active,
            avgRating: parseFloat(avgRating.toFixed(2)),
            totalPatients
        });
    };

    const filterDoctors = () => {
        let result = [...doctors];

        if (searchTerm) {
            const lowerTerm = searchTerm.toLowerCase();
            result = result.filter(d =>
                (d.fullName && d.fullName.toLowerCase().includes(lowerTerm)) ||
                (d.email && d.email.toLowerCase().includes(lowerTerm)) ||
                (d.phone && d.phone.includes(lowerTerm))
            );
        }

        if (statusFilter) {
            result = result.filter(d => d.status === statusFilter);
        }

        if (specializationFilter) {
            result = result.filter(d => d.specialization === specializationFilter);
        }

        setFilteredDoctors(result);
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-2xl font-bold text-gray-800">Quản lý Bác sĩ</h1>
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
                        <h3 className="text-gray-500 text-sm font-medium">Tổng Bác sĩ</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.total}</p>
                    </div>
                    <div className="p-3 bg-blue-50 rounded-full text-blue-600">
                        <FaUserMd className="text-xl" />
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Đang hoạt động</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.active}</p>
                    </div>
                    <div className="p-3 bg-green-50 rounded-full text-green-600">
                        <FaStethoscope className="text-xl" />
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Đánh giá TB</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.avgRating} / 5.0</p>
                    </div>
                    <div className="p-3 bg-yellow-50 rounded-full text-yellow-600">
                        <FaStar className="text-xl" />
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Tổng Bệnh nhân</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.totalPatients.toLocaleString()}</p>
                    </div>
                    <div className="p-3 bg-purple-50 rounded-full text-purple-600">
                        <FaUsers className="text-xl" />
                    </div>
                </div>
            </div>

            {/* Table Section */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="p-6 border-b border-gray-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <h2 className="text-lg font-semibold text-gray-800">Danh sách Bác sĩ</h2>
                    <div className="flex gap-2">
                        <button
                            onClick={loadDoctors}
                            className="flex items-center gap-2 px-4 py-2 text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
                        >
                            <FaSyncAlt /> Làm mới
                        </button>
                        <button className="flex items-center gap-2 px-4 py-2 text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition-colors">
                            <FaPlus /> Thêm Bác sĩ
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
                        value={specializationFilter}
                        onChange={(e) => setSpecializationFilter(e.target.value)}
                        className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    >
                        <option value="">Tất cả chuyên khoa</option>
                        {SPECIALIZATIONS.map(spec => (
                            <option key={spec} value={spec}>{spec}</option>
                        ))}
                    </select>
                    <select
                        value={statusFilter}
                        onChange={(e) => setStatusFilter(e.target.value)}
                        className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    >
                        <option value="">Tất cả trạng thái</option>
                        <option value="active">Hoạt động</option>
                        <option value="inactive">Không hoạt động</option>
                    </select>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-gray-50 text-gray-600 text-sm uppercase tracking-wider">
                                <th className="p-4 border-b font-medium">ID</th>
                                <th className="p-4 border-b font-medium">Bác sĩ</th>
                                <th className="p-4 border-b font-medium">Liên hệ</th>
                                <th className="p-4 border-b font-medium">Chuyên khoa</th>
                                <th className="p-4 border-b font-medium">Kinh nghiệm</th>
                                <th className="p-4 border-b font-medium">Đánh giá</th>
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
                            ) : filteredDoctors.length === 0 ? (
                                <tr>
                                    <td colSpan={8} className="p-8 text-center text-gray-500">
                                        Không tìm thấy bác sĩ nào
                                    </td>
                                </tr>
                            ) : (
                                filteredDoctors.map((doctor) => (
                                    <tr key={doctor.id} className="border-b hover:bg-gray-50 transition-colors">
                                        <td className="p-4">#{doctor.id}</td>
                                        <td className="p-4">
                                            <div className="flex items-center gap-3">
                                                <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 font-bold">
                                                    {doctor.fullName.charAt(0)}
                                                </div>
                                                <div>
                                                    <div className="font-medium text-gray-900">{doctor.fullName}</div>
                                                    <div className="text-xs text-gray-500">{doctor.qualification}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="p-4">
                                            <div className="text-sm">{doctor.email}</div>
                                            <div className="text-xs text-gray-500">{doctor.phone}</div>
                                        </td>
                                        <td className="p-4">
                                            <span className="px-2 py-1 bg-blue-50 text-blue-700 rounded text-xs font-medium">
                                                {doctor.specialization}
                                            </span>
                                        </td>
                                        <td className="p-4">{doctor.experience} năm</td>
                                        <td className="p-4">
                                            <div className="flex items-center gap-1">
                                                <FaStar className="text-yellow-400" />
                                                <span>{doctor.rating}</span>
                                            </div>
                                        </td>
                                        <td className="p-4">
                                            <span className={`px-2 py-1 rounded-full text-xs font-medium ${doctor.status === 'active' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-700'
                                                }`}>
                                                {doctor.status === 'active' ? 'Hoạt động' : 'Không hoạt động'}
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
