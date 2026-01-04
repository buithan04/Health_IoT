"use client";

import { useEffect, useState } from "react";
import { apiCall } from "@/utils/api";
import { FaPrescription, FaCalendarDay, FaCalendarWeek, FaCalendarAlt, FaEye, FaSyncAlt } from "react-icons/fa";

interface Prescription {
    id: number;
    patient_name: string;
    doctor_name: string;
    diagnosis: string;
    created_at: string;
    follow_up_date?: string;
    medications?: any[];
}

export default function PrescriptionsPage() {
    const [prescriptions, setPrescriptions] = useState<Prescription[]>([]);
    const [filteredPrescriptions, setFilteredPrescriptions] = useState<Prescription[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState("");
    const [dateFilter, setDateFilter] = useState("");

    // Stats
    const [stats, setStats] = useState({
        total: 0,
        today: 0,
        week: 0,
        month: 0
    });

    useEffect(() => {
        loadPrescriptions();
    }, []);

    useEffect(() => {
        filterPrescriptions();
    }, [searchTerm, dateFilter, prescriptions]);

    const loadPrescriptions = async () => {
        setLoading(true);
        try {
            const response = await apiCall('/admin/prescriptions');
            let data: Prescription[] = [];
            if (response && response.prescriptions) {
                data = response.prescriptions;
            } else if (Array.isArray(response)) {
                data = response;
            }
            setPrescriptions(data);
            updateStats(data);
        } catch (error) {
            console.error("Error loading prescriptions", error);
        } finally {
            setLoading(false);
        }
    };

    const updateStats = (data: Prescription[]) => {
        const total = data.length;

        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const todayCount = data.filter(p => {
            const pDate = new Date(p.created_at);
            pDate.setHours(0, 0, 0, 0);
            return pDate.getTime() === today.getTime();
        }).length;

        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);
        const weekCount = data.filter(p => new Date(p.created_at) >= weekAgo).length;

        const monthStart = new Date(today.getFullYear(), today.getMonth(), 1);
        const monthCount = data.filter(p => new Date(p.created_at) >= monthStart).length;

        setStats({ total, today: todayCount, week: weekCount, month: monthCount });
    };

    const filterPrescriptions = () => {
        let result = [...prescriptions];

        if (searchTerm) {
            const lowerTerm = searchTerm.toLowerCase();
            result = result.filter(p =>
                (p.patient_name && p.patient_name.toLowerCase().includes(lowerTerm)) ||
                (p.doctor_name && p.doctor_name.toLowerCase().includes(lowerTerm)) ||
                (p.diagnosis && p.diagnosis.toLowerCase().includes(lowerTerm))
            );
        }

        if (dateFilter) {
            result = result.filter(p => p.created_at.startsWith(dateFilter));
        }

        setFilteredPrescriptions(result);
    };

    const formatDate = (dateString: string) => {
        return new Date(dateString).toLocaleDateString('vi-VN');
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-2xl font-bold text-gray-800">Quản lý Đơn thuốc</h1>
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
                        <h3 className="text-gray-500 text-sm font-medium">Tổng Đơn thuốc</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.total}</p>
                    </div>
                    <div className="p-3 bg-blue-50 rounded-full text-blue-600">
                        <FaPrescription className="text-xl" />
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Hôm nay</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.today}</p>
                    </div>
                    <div className="p-3 bg-green-50 rounded-full text-green-600">
                        <FaCalendarDay className="text-xl" />
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Tuần này</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.week}</p>
                    </div>
                    <div className="p-3 bg-yellow-50 rounded-full text-yellow-600">
                        <FaCalendarWeek className="text-xl" />
                    </div>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div>
                        <h3 className="text-gray-500 text-sm font-medium">Tháng này</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">{stats.month}</p>
                    </div>
                    <div className="p-3 bg-purple-50 rounded-full text-purple-600">
                        <FaCalendarAlt className="text-xl" />
                    </div>
                </div>
            </div>

            {/* Table Section */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="p-6 border-b border-gray-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <h2 className="text-lg font-semibold text-gray-800">Danh sách Đơn thuốc</h2>
                    <div className="flex gap-2">
                        <button
                            onClick={loadPrescriptions}
                            className="flex items-center gap-2 px-4 py-2 text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
                        >
                            <FaSyncAlt /> Làm mới
                        </button>
                    </div>
                </div>

                <div className="p-4 bg-gray-50 border-b border-gray-100 grid grid-cols-1 md:grid-cols-3 gap-4">
                    <input
                        type="text"
                        placeholder="Tìm kiếm theo tên, chẩn đoán..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    />
                    <input
                        type="date"
                        value={dateFilter}
                        onChange={(e) => setDateFilter(e.target.value)}
                        className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    />
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="bg-gray-50 text-gray-600 text-sm uppercase tracking-wider">
                                <th className="p-4 border-b font-medium">ID</th>
                                <th className="p-4 border-b font-medium">Bệnh nhân</th>
                                <th className="p-4 border-b font-medium">Bác sĩ</th>
                                <th className="p-4 border-b font-medium">Chẩn đoán</th>
                                <th className="p-4 border-b font-medium">Ngày tạo</th>
                                <th className="p-4 border-b font-medium">Tái khám</th>
                                <th className="p-4 border-b font-medium">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody className="text-gray-700 text-sm">
                            {loading ? (
                                <tr>
                                    <td colSpan={7} className="p-8 text-center text-gray-500">
                                        Đang tải dữ liệu...
                                    </td>
                                </tr>
                            ) : filteredPrescriptions.length === 0 ? (
                                <tr>
                                    <td colSpan={7} className="p-8 text-center text-gray-500">
                                        Không tìm thấy đơn thuốc nào
                                    </td>
                                </tr>
                            ) : (
                                filteredPrescriptions.map((pres) => (
                                    <tr key={pres.id} className="border-b hover:bg-gray-50 transition-colors">
                                        <td className="p-4">#{pres.id}</td>
                                        <td className="p-4 font-medium text-gray-900">{pres.patient_name}</td>
                                        <td className="p-4 font-medium text-gray-900">{pres.doctor_name}</td>
                                        <td className="p-4 max-w-xs truncate" title={pres.diagnosis}>
                                            {pres.diagnosis || '-'}
                                        </td>
                                        <td className="p-4">{formatDate(pres.created_at)}</td>
                                        <td className="p-4">
                                            {pres.follow_up_date ? formatDate(pres.follow_up_date) : '-'}
                                        </td>
                                        <td className="p-4">
                                            <button className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg" title="Xem chi tiết">
                                                <FaEye />
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
